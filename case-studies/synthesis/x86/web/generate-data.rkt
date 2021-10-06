#lang racket

(require racket/require
         json
         (multi-in "../../../../frameworks/alglave"
                   ("framework.rkt" "models.rkt" "sketch-model.rkt"))
         "../ocelot/ocelot.rkt"
         (multi-in "../../../../litmus"
                   ("litmus.rkt" "export.rkt" "tests/x86.rkt")))

(file-stream-buffer-mode (current-output-port) 'none)

(log-types '(synth unique))

;; MemSynth stuff ------------------------------------------------------------

; grammar
(define rf (declare-relation 2 "rf"))
(define ppo (make-ppo-sketch 4 (list + - -> & SameAddr)
                               (list po MemoryEvent Reads Writes)))
(define grf (make-grf-sketch 4 (list + - -> & SameAddr)
                               (list rf rfi rfe none univ)))
(define ab (-> none none))
(define sketch (make-model ppo grf ab))

; initial model
(define M (make-model po rf (-> none none)))

; litmus test sketch
(define T_s (litmus-test-sketch 2 6 2 #f #f #f #f #f))


; Solve for a single sequence of oracle choices
(define (explore-sequence seq)
  (define used-seq '())
  (define tests '()) 
  (define (oracle T)
    (when (null? seq)
      (eprintf "error: ran out of seq; inventing #t\n")
      (set! seq '(#t)))
    (set! tests (append tests (list T)))
    (define ret (car seq))
    (set! used-seq (append used-seq (list ret)))
    (set! seq (cdr seq))
    ret)
  (define M1 (make-unique alglave M '() sketch T_s oracle))
  (displayln "final model:")
  (println M1)
  (values M1 tests used-seq))


; Explore all sequences of oracle choices up to a given depth
(define (explore-all-sequences [depth 5])
  (define seqs (apply cartesian-product (make-list depth '(#t #f))))
  (for/fold ([results (hash)]) ([seq seqs])
    (if (for/or ([i (length seq)])
          (hash-has-key? results (take seq i)))
        results
        (let ()
          (printf "trying seq: ~v\n" seq)
          (define-values (M tests used) (explore-sequence seq))
          (hash-set results used (cons tests M))))))


; Look up a litmus test corresponding to a given sequence (or prefix) of choices
(define (prefix-lookup thash key)
  (define key-len (length key))
  (define choices (first (filter (lambda (k) (and (>= (length k) key-len)
                                                  (equal? (take k key-len) key)))
                                 (hash-keys thash))))
  (define tests (car (hash-ref thash choices)))
  (if (< key-len (length tests))
      (hash 'test (export/x86 (list-ref tests key-len))
            'x86 (allowed? alglave (list-ref tests key-len) TSO))
      #f))


; Generate the search tree of a given depth
(define (generate-tree [depth 5])
  (define results (explore-all-sequences depth))
  (define first-test (first (car (first (hash-values results)))))
  (define (tree choices)
    (if (hash-has-key? results choices)
        (let ([m (cdr (hash-ref results choices))])
          (hash 'ppo (~a (ast->datum (simplify (memory-model-ppo m))))
                'grf (~a (ast->datum (simplify (memory-model-grf m))))
                'x86 (for/list ([t x86-tests/no-atomics]) (list (~a (litmus-test-name t)) (allowed? alglave t m)))))
        (hash 'true (list (prefix-lookup results (append choices (list #t)))
                          (tree (append choices (list #t))))
              'false (list (prefix-lookup results (append choices (list #f)))
                           (tree (append choices (list #f)))))))
  (define ret (tree '()))
  (hash 'first_test (hash 'test (export/x86 first-test)
                          'x86 (allowed? alglave first-test TSO))
        'choices ret
        'x86 (for/list ([t x86-tests/no-atomics]) (list (~a (litmus-test-name t)) (allowed? alglave t TSO)))))
   

(module+ main
  (define T (generate-tree 7))
  (displayln "======")
  (write-json T))
