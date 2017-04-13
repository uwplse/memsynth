#lang racket

(require "lang.rkt")
(provide export/x86 export/ppc)

(define x86-regs '(EAX EBX ECX EDX))
(define ppc-regs '(r1 r2 r3 r4 r5 r6 r7 r8 r9 r10 r11 r12 r13 r14 r15 r16))

(define (export/x86 t)
  (match-define (litmus-test name prog final _) t)
  (define header (format "X86 ~a" name))
  (define acts (all-actions prog))
  (define locs
    (remove-duplicates (for/list ([a acts] #:unless (Fence? a)) (Action-addr a))))
  (define pre (for/list ([l locs]) (list #f l 0)))
  (define post '())
  (define insns
    (for/list ([(t tidx) (in-indexed (Program-threads prog))])
      (define next-reg 0)
      (for/list ([a (Thread-actions t)])
        (match a
          [(Read _ _ _ _ addr val)
           (define reg (list-ref x86-regs next-reg))
           (set! next-reg (add1 next-reg))
           (set! post (cons (list tidx reg val) post))
           (format "MOV ~a,[~a]" reg addr)]
          [(Atomic _ _ _ _ addr val)
           (define reg (list-ref x86-regs next-reg))
           (set! next-reg (add1 next-reg))
           (set! pre (cons (list tidx reg val) pre))
           (format "XCHG [~a],~a" addr reg)]
          [(Write _ _ _ _ addr val)
           (format "MOV [~a],$~a" addr val)]
          [(Fence _ _ _ _ _ _ _)
           "MFENCE"]))))
  (define max-length (apply max (map length insns)))
  (define max-width (apply max (for*/list ([t insns][i t]) (string-length i))))
  (define thds
    (format "~a ;"
            (string-join (for/list ([(t i) (in-indexed (Program-threads prog))])
                           (string-append (format "P~a" i) (make-string (- max-width 2) #\ )))
                         " | ")))
  (define insn-lines
    (for/list ([i max-length])
      (string-append
       (string-join (for/list ([t insns])
                      (if (< i (length t))
                          (let ([insn (list-ref t i)])
                            (string-append insn (make-string (- max-width (string-length insn)) #\ )))
                          (make-string max-width #\ )))
                    " | ")
       " ;")))
  (define init
    (format "{ ~a }" 
            (string-join 
              (for/list ([p (reverse pre)]) 
                (match-define (list thd loc val) p)
                (if (false? thd)
                    (format "~a=~a;" loc val)
                    (format "~a:~a=~a;" thd loc val))))))
  (define post-cond
    (format "exists (~a)"
            (string-join (for/list ([p (reverse post)])
                           (match-define (list thd reg val) p)
                           (format "~a:~a = ~a" thd reg val))
                         " /\\ ")))
  (string-join (append (list header init thds) insn-lines (list post-cond)) "\n"))

(define (export/ppc t)
  (match-define (litmus-test name prog final _) t)
  (define header (format "PPC ~a" name))
  (define acts (all-actions prog))
  (define locs
    (remove-duplicates (for/list ([a acts] #:unless (Fence? a)) (Action-addr a))))
  (define post '())
  (define pre '())
  (define insns
    (for/list ([(t tidx) (in-indexed (Program-threads prog))])
      (define next-reg
        (let ([n 0])
          (thunk (begin0 (list-ref ppc-regs n) (set! n (add1 n))))))
      (define addrs (make-hash))
      (define consts (make-hash))
      (define dsts (make-hash))
      (for/fold ([is '()]) ([a (Thread-actions t)])
        (match a
          [(Read _ lid _ deps addr val)
           (cond [(null? deps)
                  (define dst (next-reg))
                  (unless (hash-has-key? addrs addr)
                    (define reg (next-reg))
                    (hash-set! addrs addr reg)
                    (set! pre (cons (list tidx reg addr) pre)))
                  (define src (hash-ref addrs addr))
                  (set! post (cons (list tidx dst val) post))
                  (hash-set! dsts lid dst)
                  (append is (list (format "lwz ~a,0(~a)" dst src)))]
                 [else
                  (define dep (first deps))
                  (define dep-src (hash-ref dsts dep))
                  (define dep-dst (next-reg))
                  (define dst (next-reg))
                  (unless (hash-has-key? addrs addr)
                    (define reg (next-reg))
                    (hash-set! addrs addr reg)
                    (set! pre (cons (list tidx reg addr) pre)))
                  (define src (hash-ref addrs addr))
                  (set! post (cons (list tidx dst val) post))
                  (hash-set! dsts lid dst)
                  (append is (list (format "xor ~a,~a,~a" dep-dst dep-src dep-src)
                                   (format "lwzx ~a,~a,~a" dst dep-dst src)))])]
          [(Write _ _ _ deps addr val)
           (cond [(null? deps)
                  (define src (next-reg))
                  (unless (hash-has-key? addrs addr)
                    (define reg (next-reg))
                    (hash-set! addrs addr reg)
                    (set! pre (cons (list tidx reg addr) pre)))
                  (define dst (hash-ref addrs addr))
                  (append is (list (format "li ~a,~a" src val)
                                   (format "stw ~a,0(~a)" src dst)))]
                 [else
                  (define dep (first deps))
                  (define dep-src (hash-ref dsts dep))
                  (define dep-dst (next-reg))
                  (define src (next-reg))
                  (unless (hash-has-key? addrs addr)
                    (define reg (next-reg))
                    (hash-set! addrs addr reg)
                    (set! pre (cons (list tidx reg addr) pre)))
                  (define dst (hash-ref addrs addr))
                  (append is (list (format "xor ~a,~a,~a" dep-dst dep-src dep-src)
                                   (format "li ~a,~a" src val)
                                   (format "stwx ~a,~a,~a" src dep-dst dst)))])]
          [(Fence _ _ _ _ _ _ type)
           (append is (list (symbol->string type)))]))))
  (define max-length (apply max (map length insns)))
  (define max-width (apply max (for*/list ([t insns][i t]) (string-length i))))
  (define thds
    (format "~a ;"
            (string-join (for/list ([(t i) (in-indexed (Program-threads prog))])
                           (string-append (format "P~a" i) (make-string (- max-width 2) #\ )))
                         " | ")))
  (define insn-lines
    (for/list ([i max-length])
      (string-append
       (string-join (for/list ([t insns])
                      (if (< i (length t))
                          (let ([insn (list-ref t i)])
                            (string-append insn (make-string (- max-width (string-length insn)) #\ )))
                          (make-string max-width #\ )))
                    " | ")
       " ;")))
  (define init-mem (for/list ([l (sort locs symbol<?)]) (format "~a=0;" l)))
  (define init-reg (for/list ([p (reverse pre)])
                     (match-define (list thd reg val) p)
                     (format "~a:~a=~a;" thd reg val)))
  (define init (format "{ ~a }" (string-join (append init-mem init-reg))))
  (define post-mem (for/list ([p final])
                     (format "~a=~a" (first p) (second p))))
  (define post-reg (for/list ([p (reverse post)])
                     (match-define (list thd reg val) p)
                     (format "~a:~a=~a" thd reg val)))
  (define post-cond
    (format "exists (~a)"
            (string-join (append post-mem post-reg)
                         " /\\ ")))
  (string-join (append (list header init thds) insn-lines (list post-cond)) "\n"))
