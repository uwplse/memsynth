#lang rosette

(provide (all-defined-out))

;; programs --------------------------------------------------------------------

; a program (actually an execution) is a list of actions.
; a thread is a list of actions.
(struct Program (workgroups) #:transparent)
(struct WorkGroup (threads) #:transparent)
(struct Thread (wgid tid actions) #:transparent)  ; actions, thread ID, work group id
(struct Action (gid wg thd lid deps addr val) #:transparent)  ; global ID, thread-local ID(action index), thread ID, local deps
(struct Read Action () #:transparent)
(struct Write Action () #:transparent)
(struct RMW Action () #:transparent)
;(struct Fence Action (type) #:transparent)
(struct AtomicExchg RMW () #:transparent)
(struct AtomicAdd RMW () #:transparent)
(struct AtomicWrite Write () #:transparent)
(struct AtomicRead Read () #:transparent)

; get all actions in a program
(define (all-actions P)
  (for*/list ([wg (Program-workgroups P)] [thd (WorkGroup-threads wg)][act (Thread-actions thd)]) act))


;; tests -----------------------------------------------------------------------

; A litmus test consists of a test name, a program? struct, a postcondition
; and list of models that allow the test.
(struct litmus-test (name program post allowed) #:transparent)


(define-syntax define-litmus-test
  (syntax-rules ()
    [(_ name (wg ...))
     (define-litmus-test name (wg ...) #:post () #:allowed)]
    [(_ name (wg ...) #:allowed a ...)
     (define-litmus-test name (wg ...) #:post () #:allowed a ...)]
    [(_ name (wg ...) #:post p)
     (define-litmus-test name (wg ...) #:post p #:allowed)]
    [(_ name (wg ...) #:post p #:allowed a ...)
      (define name (litmus-test 'name (read-test (list 'wg ...)) 'p (list 'a ...)))]
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
    (for/list ([wg T] [wgid (length T)])
      (WorkGroup
        (for/list ([thd wg][tid (length wg)])
          (Thread wgid tid
            (for/list ([a thd][lid (length thd)])
              (define deps (match a
                            [(list _ _ _ d) d]
                            [_ '()]
                          )
              )
              (begin0
                (match a
                  [(list 'R addr val _ ...)   (Read  gid wgid tid lid deps addr val)]
                  [(list 'W addr val _ ...)   (Write gid wgid tid lid deps addr val)]
                ;  [(list 'F type)           (Fence gid lid tid '()  0    0   type)]
                ;  [(list 'F)                (Fence gid lid tid '()  0    0   'sync)]
                  [(list 'AE  addr val _ ...) (AtomicWrite gid wgid tid lid deps addr val)]
                  [(list 'AA  addr val _ ...) (AtomicAdd gid wgid tid lid deps addr val)]
                  [(list 'AR  addr val _ ...) (AtomicRead gid wgid tid lid deps addr val)]
                  [(list 'AW  addr val _ ...) (AtomicWrite gid wgid tid lid deps addr val)]
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
  (define acts (all-actions prog))
  ; (define locs
  ;   (remove-duplicates (for/list ([a acts]) (Action-addr a))))
  (define post '())

  (define fresh-reg
    (let ([regs '(r0 r1 r2 r3 r4 r5 r6 r7 r8 r9 r10 r11 r12 r13 r14 r15 r16 r17 r18 r19 r20)])
      (lambda () (begin0 (car regs) (set! regs (cdr regs))))))
  (define insns
    (for/list ([(t tidx) (in-indexed (Program-workgroups prog))])
      (for/list ([(wg wgid) (in-indexed (WorkGroup-threads t))])
        (define dsts (make-hash))
        (for/fold ([is '()]) ([a (Thread-actions wg)])
          (match a
            [(AtomicRead _ _ _ lid deps addr val)
            (cond [(null? deps)
                    (define dst (fresh-reg))
                    (set! post (cons (list dst val) post))
                    (hash-set! dsts lid dst)
                    (append is (list (format "~a <- ~a[~a]" dst "LOCK " addr)))]
                  [else
                    (define dep (first deps))
                    (define dep-src (hash-ref dsts dep))
                    (define dep-dst (fresh-reg))
                    (define dst (fresh-reg))
                    (set! post (cons (list dst val) post))
                    (hash-set! dsts lid dst)
                    (append is (list (format "~a <- ~a ^ ~a" dep-dst dep-src dep-src)
                                     (format "~a <- ~a[~a+~a]" dst "LOCK " addr dep-dst)))])]
            [(AtomicWrite _ _ _ _ deps addr val)
            (cond [(null? deps)
                    (append is (list (format "~a[~a] <- ~a" "LOCK " addr val)))]
                  [else
                    (define dep (first deps))
                    (define dep-src (hash-ref dsts dep))
                    (define dep-dst (fresh-reg))
                    (append is (list (format "~a <- ~a ^ ~a" dep-dst dep-src dep-src)
                                     (format "~a[~a+~a] <- ~a" "LOCK " addr dep-dst val)))])]
            [(AtomicAdd _ _ _ lid deps addr val) ; Same as atomic read
            (cond [(null? deps)
                    (define dst (fresh-reg))
                    (set! post (cons (list dst val) post))
                    (hash-set! dsts lid dst)
                    (append is (list (format "~a <- ~a[~a]" dst "LOCK " addr)))]
                  [else
                    (define dep (first deps))
                    (define dep-src (hash-ref dsts dep))
                    (define dep-dst (fresh-reg))
                    (define dst (fresh-reg))
                    (set! post (cons (list dst val) post))
                    (hash-set! dsts lid dst)
                    (append is (list (format "~a <- ~a ^ ~a" dep-dst dep-src dep-src)
                                     (format "~a <- ~a[~a+~a]" dst "LOCK " addr dep-dst)))])]
            [(AtomicExchg _ _ _ _ deps addr val) ; Same as atomic write
            (cond [(null? deps)
                    (append is (list (format "~a[~a] <- ~a" "LOCK " addr val)))]
                  [else
                    (define dep (first deps))
                    (define dep-src (hash-ref dsts dep))
                    (define dep-dst (fresh-reg))
                    (append is (list (format "~a <- ~a ^ ~a" dep-dst dep-src dep-src)
                                     (format "~a[~a+~a] <- ~a" "LOCK " addr dep-dst val)))])]
            [(Read _ _ _ lid deps addr val)
            (cond [(null? deps)
                    (define dst (fresh-reg))
                    (set! post (cons (list dst val) post))
                    (hash-set! dsts lid dst)
                    (append is (list (format "~a <- [~a]" dst addr)))]
                  [else
                    (define dep (first deps))
                    (define dep-src (hash-ref dsts dep))
                    (define dep-dst (fresh-reg))
                    (define dst (fresh-reg))
                    (set! post (cons (list dst val) post))
                    (hash-set! dsts lid dst)
                    (append is (list (format "~a <- ~a ^ ~a" dep-dst dep-src dep-src)
                                    (format "~a <- [~a+~a]" dst addr dep-dst)))])]
            [(Write _ _ _ _ deps addr val)
            (cond [(null? deps)
                    (append is (list (format "[~a] <- ~a" addr val)))]
                  [else
                    (define dep (first deps))
                    (define dep-src (hash-ref dsts dep))
                    (define dep-dst (fresh-reg))
                    (append is (list (format "~a <- ~a ^ ~a" dep-dst dep-src dep-src)
                                    (format "[~a+~a] <- ~a" addr dep-dst val)))])]
            ; [(Fence _ _ _ _ _ _ type)
            ; (append is (list (symbol->string type)))]
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
                 " || ")
  )
  (define thds
    (string-join  (for/list ([(w i) (in-indexed (Program-workgroups prog))])
                    (string-join  
                      (for/list ([(t j) (in-indexed (WorkGroup-threads w))])
                        (string-append (format "T~a" j) (make-string (- max-width 2) #\ ))
                      )
                      " | ")
                  )
                  " || ")
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
            " | ")
        )
        " || ")
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
    (let ([lines (append (list header wgs thds) insn-lines (list post-cond))])
      (apply max (map string-length lines))))
  (define ====== (make-string max-line-width #\=))
  (define ------ (make-string max-line-width #\-))
  (define ****** (make-string max-line-width #\*))
  (string-join (append (list header
                             ******
                             wgs
                             ======
                             thds
                             ------)
                       insn-lines
                       (list ****** 
                             post-cond))
               "\n")
)
