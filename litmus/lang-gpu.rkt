#lang rosette

(provide (all-defined-out))

;; programs --------------------------------------------------------------------

; a program (actually an execution) is a list of events.
; a thread is a list of events.
(struct Program (workgroups) #:transparent)
(struct WorkGroup (threads) #:transparent)
(struct Thread (wgid tid events) #:transparent)  ; events, thread ID, work group id
(struct Event (gid wgid tid lid addr val) #:transparent)  ; global ID, thread-local ID(event index), thread ID, local 
(struct Read Event () #:transparent)
(struct Write Event () #:transparent)
(struct Fence Event (type) #:transparent)
(struct RMW Event (r/w) #:transparent) ; r/w: #t => read, #f => write
(struct AWrite Event () #:transparent)
(struct ARead Event () #:transparent)


; get all events in a program
(define (all-events P)
  (for*/list ([wgid (Program-workgroups P)] [tid (WorkGroup-threads wgid)][act (Thread-events tid)]) act)
)


;; tests -----------------------------------------------------------------------

; A litmus test consists of a test name, a program? struct, a postcondition
; and list of models that allow the test.
(struct litmus-test (name program post allowed) #:transparent)


(define-syntax define-litmus-test
  (syntax-rules ()
    [(_ name (wgid ...))
     (define-litmus-test name (wgid ...) #:post () #:allowed)]
    [(_ name (wgid ...) #:allowed a ...)
     (define-litmus-test name (wgid ...) #:post () #:allowed a ...)]
    [(_ name (wgid ...) #:post p)
     (define-litmus-test name (wgid ...) #:post p #:allowed)]
    [(_ name (wgid ...) #:post p #:allowed a ...)
      (define name (litmus-test 'name (read-test (list 'wgid ...)) 'p (list 'a ...)))]
  )
)


; litmus-test-allowed? (model, test)
; (1) if model == 'any return true
; (2) if test is allowed ruturn true
(define (litmus-test-allowed? model test)
  (or (equal? model 'any)
      (not (false? (member model (litmus-test-allowed test))))))


; parse a test into a program struct
(define (read-test T)
  (define gid 0) ; global id
  (Program
    (for/list ([wgid T] [wgidx (length T)])
      (WorkGroup
        (for/list ([tid wgid][tidx (length wgid)])
          (Thread wgid tid
            (for/list ([a tid][lid (length tid)])
              (begin0
                (match a
                  [(list 'R addr val _ ...)   (Read  gid wgidx tidx lid  addr val)]
                  [(list 'W addr val _ ...)   (Write gid wgidx tidx lid  addr val)]
                  [(list 'F)                  (Fence gid wgidx tidx lid '()  0    0   'sync)]
                  [(list 'AE  addr val _ ...) (RMW gid wgidx tidx lid  addr val #f)]
                  [(list 'AA  addr val _ ...) (RMW gid wgidx tidx lid  addr val #t)]
                  ; [(list 'AA  addr val _ ...) (ARead gid wgidx tidx lid  addr val)]
                  ; [(list 'AE  addr val _ ...) (AWrite gid wgidx tidx lid  addr val)]
                  [(list 'AR  addr val _ ...) (ARead gid wgidx tidx lid  addr val)]
                  [(list 'AW  addr val _ ...) (AWrite gid wgidx tidx lid  addr val)]
                )
                (set! gid (add1 gid))
              )
            )
          )
        )
      )
    )
  )
)

; export a test into a human-readable string
(define (test->string t)
  (match-define (litmus-test name prog final _) t)
  (define header (format "Test ~a" name))
  (define acts (all-events prog))
  (define addrs
    (remove-duplicates (for/list ([a acts] #:unless (Fence? a)) (Event-addr a))))
  (define post '())

  (define fresh-reg
    (let ([regs '(r0 r1 r2 r3 r4 r5 r6 r7 r8 r9 r10 r11 r12 r13 r14 r15 r16 r17 r18 r19 r20)])
      (lambda () (begin0 (car regs) (set! regs (cdr regs))))))
  (define insns
    (for/list ([(t tidx) (in-indexed (Program-workgroups prog))])
      (for/list ([(wgid wgidx) (in-indexed (WorkGroup-threads t))])
        (define dsts (make-hash))
        (for/fold ([is '()]) ([a (Thread-events wgid)])
          (match a
            [(ARead _ _ _ lid  addr val)
            (cond [(null? )
                    (define dst (fresh-reg))
                    (set! post (cons (list dst val) post))
                    (hash-set! dsts lid dst)
                    (append is (list (format "~a <- ~a[~a]" dst "LOCK " addr)))]
                  [else
                    (define dep (first ))
                    (define dep-src (hash-ref dsts dep))
                    (define dep-dst (fresh-reg))
                    (define dst (fresh-reg))
                    (set! post (cons (list dst val) post))
                    (hash-set! dsts lid dst)
                    (append is (list (format "~a <- ~a ^ ~a" dep-dst dep-src dep-src)
                                     (format "~a <- ~a[~a+~a]" dst "LOCK " addr dep-dst)))])]
            [(AWrite _ _ _ _  addr val)
            (cond [(null? )
                    (append is (list (format "~a[~a] <- ~a" "LOCK " addr val)))]
                  [else
                    (define dep (first ))
                    (define dep-src (hash-ref dsts dep))
                    (define dep-dst (fresh-reg))
                    (append is (list (format "~a <- ~a ^ ~a" dep-dst dep-src dep-src)
                                     (format "~a[~a+~a] <- ~a" "LOCK " addr dep-dst val)))])]
            [(RMW _ _ _ lid  addr val r/w) 
            (if r/w
              ; Same as atomic read
              (cond [(null? ) 
                    (define dst (fresh-reg))
                    (set! post (cons (list dst val) post))
                    (hash-set! dsts lid dst)
                    (append is (list (format "~a <- ~a[~a]" dst "LOCK " addr)))]
                  [else
                    (define dep (first ))
                    (define dep-src (hash-ref dsts dep))
                    (define dep-dst (fresh-reg))
                    (define dst (fresh-reg))
                    (set! post (cons (list dst val) post))
                    (hash-set! dsts lid dst)
                    (append is (list (format "~a <- ~a ^ ~a" dep-dst dep-src dep-src)
                                     (format "~a <- ~a[~a+~a]" dst "LOCK " addr dep-dst)))])
              ; Same as atomic write
              (cond [(null? )
                    (append is (list (format "~a[~a] <- ~a" "LOCK " addr val)))]
                  [else
                    (define dep (first ))
                    (define dep-src (hash-ref dsts dep))
                    (define dep-dst (fresh-reg))
                    (append is (list (format "~a <- ~a ^ ~a" dep-dst dep-src dep-src)
                                     (format "~a[~a+~a] <- ~a" "LOCK " addr dep-dst val)))])
            )]
            [(Read _ _ _ lid  addr val)
            (cond [(null? )
                    (define dst (fresh-reg))
                    (set! post (cons (list dst val) post))
                    (hash-set! dsts lid dst)
                    (append is (list (format "~a <- [~a]" dst addr)))]
                  [else
                    (define dep (first ))
                    (define dep-src (hash-ref dsts dep))
                    (define dep-dst (fresh-reg))
                    (define dst (fresh-reg))
                    (set! post (cons (list dst val) post))
                    (hash-set! dsts lid dst)
                    (append is (list (format "~a <- ~a ^ ~a" dep-dst dep-src dep-src)
                                    (format "~a <- [~a+~a]" dst addr dep-dst)))])]
            [(Write _ _ _ _  addr val)
            (cond [(null? )
                    (append is (list (format "[~a] <- ~a" addr val)))]
                  [else
                    (define dep (first ))
                    (define dep-src (hash-ref dsts dep))
                    (define dep-dst (fresh-reg))
                    (append is (list (format "~a <- ~a ^ ~a" dep-dst dep-src dep-src)
                                    (format "[~a+~a] <- ~a" addr dep-dst val)))])]
            [(Fence _ _ _ _ _ _ type)
            (append is (list (symbol->string type)))]
          )
        )
      )
    )
  )
  (define-values (max-length) (apply max (map length (for*/list ([w insns][t w]) t))))
  (define-values (max-width) (apply max (for*/list ([w insns][t w][a t]) (string-length a))))
  (define wgs
    (string-join (for/list ([(w i) (in-indexed (Program-workgroups prog))])
                   (string-append (format "P~a" i) (make-string (- max-width 2) #\ )))
                 " ||| ")
  )
  (define tids
    (string-join  (for/list ([(w i) (in-indexed (Program-workgroups prog))])
                    (string-join  
                      (for/list ([(t j) (in-indexed (WorkGroup-threads w))])
                        (string-append (format "T~a" j) (make-string (- max-width 2) #\ ))
                      )
                      " || ")
                  )
                  " ||| ")
  )
  (define insn-lines
    (for/list ([i max-length])
      (string-join 
        (for/list ([w insns])
          (string-join
            (for/list ([t w])
                      (if (< i (length t))
                          (let ([insn (list-ref t i)])
                            (string-append insn (make-string (- max-width (string-length insn)) #\ ))
                          )
                          (make-string max-width #\ )
                      )
            )
            " || ")
        )
        " ||| ")
    )
  )

  (define post-mem (for/list ([p final])
                     (format "[~a]=~a" (first p) (second p))))
  (define post-reg (for/list ([p (reverse post)])
                     (match-define (list reg val) p)
                     (format "~a=~a" reg val)))
  (define post-cond
    (string-join (append post-mem post-reg)
                 " /\\ "))
  (define max-line-width
    (let ([lines (append (list header wgs tids) insn-lines (list post-cond))])
      (apply max (map string-length lines))))
  (define ====== (make-string max-line-width #\=))
  (define ------ (make-string max-line-width #\-))
  (define ****** (make-string max-line-width #\*))
  (string-join (append (list header
                             ******
                             wgs
                             ======
                             tids
                             ------)
                       insn-lines
                       (list ****** 
                             post-cond))
               "\n")
)
