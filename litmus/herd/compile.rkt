#lang racket

(require "parse.rkt" "../lang.rkt")
(provide compile/ppc)


;; Given a string containing a Herd-formatting litmus test,
;; convert it into our litmus-test struct.
;; This won't populate the litmus-test's allowed list.
(define (litmus-file->test contents)
  (define ltest (parse-litmus-test contents))
  (match (string-upcase (litmus-file-cpu ltest))
    ["PPC" (compile/ppc ltest)]
    [_ (error 'litmus-file->test "unknown architecture ~a" (litmus-file-cpu ltest))]))


(define (ssplit s [sep #px"\\s+"])
  (map string-trim (string-split s sep)))

(define (ssubstr s n [k (string-length s)])
  (string-trim (substring s n k)))


;; Compile a litmus-file struct into a litmus test,
;; treating the litmus-file as a PowerPC litmus test.
(define (compile/ppc test)
  (define pre (litmus-file-pre test))
  (define insns (litmus-file-insns test))
  (define post (litmus-file-post test))

  (define procs (sort (hash-keys insns) <))
  (define gid (let ([g 0]) (thunk (begin0 g (set! g (add1 g))))))

  (define prog
    (Program
     (for/list ([(p tid) (in-indexed procs)])
       (define code (hash-ref insns p))
       (define lid (let ([g 0]) (thunk (begin0 g (set! g (add1 g))))))

       (define regs ; my registers
         (make-hash (for/list ([(r v) (hash-ref pre p '())]) (cons r (list v '() #f)))))
       (define mem (make-hash)) ; local memory
       (Thread tid
               (for/fold ([ir '()]) ([insn code])
                 (match-define (list op args)
                   (map string-trim
                        (let ([i (string-index insn #\ )])
                          (if i
                              (list (substring insn 0 i) (substring insn (add1 i)))
                              (list insn "")))))

                 (match op
                   ["li" (match-define (list reg val) (ssplit args ","))
                         (hash-set! regs reg (list val '() #f))
                         ir]
                   [(or "stw" "stwx")
                    (define-values (addr val deps)
                      (case op
                        [("stw")  (match-define (list src dst) (ssplit args ","))
                                  (define n (string-index dst #\())
                                  (define off (ssubstr dst 0 n))
                                  (define dst* (ssubstr dst (add1 n) (- (string-length dst) 1)))
                                  ; get src and dst
                                  (match-define (list val sdeps _) (hash-ref regs src))
                                  (match-define (list addr ddeps _) (hash-ref regs dst*))
                                  (values addr val (append sdeps ddeps))]
                        [("stwx") (match-define (list rs ra rb) (ssplit args ","))
                                  (match-define (list addra adeps _) (hash-ref regs ra))
                                  (match-define (list addrb bdeps _) (hash-ref regs rb))
                                  (when (and (not (equal? addra 0)) (not (equal? addrb 0)))
                                    (error 'compile/ppc "don't know how to add addresses"))
                                  (define addr (if (equal? addra 0) addrb addra))
                                  (define ddeps (append adeps bdeps))
                                  (match-define (list val sdeps _) (hash-ref regs rs))
                                  (values addr val (append sdeps ddeps))]))
                    (hash-set! mem addr val)
                    (append ir
                            (list (Write (gid) (lid) p deps (string->symbol addr) (string->number val))))]
                   [(or "lwz" "lwzx")
                    (define-values (dst addr sdeps)
                      (case op
                        [("lwz")  (match-define (list dst src) (ssplit args ","))
                                  (define n (string-index src #\())
                                  (define off (ssubstr src n))
                                  (define src* (ssubstr src (add1 n) (- (string-length src) 1)))
                                  ; get src
                                  (match-define (list addr sdeps _) (hash-ref regs src*))
                                  (values dst addr sdeps)]
                        [("lwzx") (match-define (list rt ra rb) (ssplit args ","))
                                  (match-define (list addra adeps _) (hash-ref regs ra))
                                  (match-define (list addrb bdeps _) (hash-ref regs rb))
                                  (when (and (not (equal? addra 0)) (not (equal? addrb 0)))
                                    (error 'compile/ppc "don't know how to add addresses"))
                                  (define addr (if (equal? addra 0) addrb addra))
                                  (define sdeps (append adeps bdeps))
                                  (values rt addr sdeps)]))
                    (define val
                      (cond [(hash-has-key? (hash-ref post p) dst)
                             (hash-ref (hash-ref post p) dst)]
                            [(hash-has-key? mem addr)
                             (hash-ref mem addr)]
                            [else #f]))
                    (cond [val
                           (define l (lid))
                           (hash-set! regs dst (list val sdeps l))
                           (append ir
                                   (list (Read (gid) l p sdeps (string->symbol addr) (string->number val))))]
                          [else ir])]
                   ["xor" (match-define (list rd ra rb) (ssplit args ","))
                          (match-define (list addra adeps asrc) (hash-ref regs ra))
                          (match-define (list addrb bdeps bsrc) (hash-ref regs rb))
                          (unless (equal? addra addrb)
                            (error 'compile/ppc "don't know how to xor different addrs"))
                          (define deps (append adeps bdeps (or (list asrc) '())))
                          (hash-set! regs rd (list 0 deps #f))
                          ir]
                   ["sync" (append ir (list (Fence (gid) (lid) p '() 0 0 'sync)))]
                   ["lwsync" (append ir (list (Fence (gid) (lid) p '() 0 0 'lwsync)))]
                   [_ (error 'compile/ppc "unknown instruction ~v" insn)]))))))
  (define postcond
    (for/list ([(var val) post] #:unless (hash? val))
      (list (string->symbol var) (string->number val))))

  (litmus-test (litmus-file-name test) prog postcond '()))


(module+ main
  (require racket/cmdline racket/pretty)
  (define path
    (command-line
     #:args (filename)
     filename))
  (pretty-print (litmus-file->test (file->string path))))


(module+ test
  (require "../tests/ppc-all.rkt" rackunit)
  (define lwswr000.litmus #<<TEST
PPC lwswr000
"DpdR Fre LwSyncsWR Fre LwSyncsWR DpdR Fre LwSyncsWR Fre LwSyncsWR"
Cycle=DpdR Fre LwSyncsWR Fre LwSyncsWR DpdR Fre LwSyncsWR Fre LwSyncsWR
Relax=LwSyncsWR
Safe=Fre DpdR
{
0:r2=x;
1:r2=x; 1:r6=y;
2:r2=y;
3:r2=y; 3:r6=x;
}
 P0           | P1            | P2           | P3            ;
 li r1,1      | li r1,2       | li r1,1      | li r1,2       ;
 stw r1,0(r2) | stw r1,0(r2)  | stw r1,0(r2) | stw r1,0(r2)  ;
 lwsync       | lwsync        | lwsync       | lwsync        ;
 lwz r3,0(r2) | lwz r3,0(r2)  | lwz r3,0(r2) | lwz r3,0(r2)  ;
              | xor r4,r3,r3  |              | xor r4,r3,r3  ;
              | lwzx r5,r4,r6 |              | lwzx r5,r4,r6 ;
exists
(x=2 /\ y=2 /\ 0:r3=1 /\ 1:r3=2 /\ 1:r5=0 /\ 2:r3=1 /\ 3:r3=2 /\ 3:r5=0)
TEST
    )
  (define parsed (compile/ppc (parse-litmus-test lwswr000.litmus)))
  (check-equal? (litmus-test-program parsed)
                (litmus-test-program test/ppc/lwswr000)))
