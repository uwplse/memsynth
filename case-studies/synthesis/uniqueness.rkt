#lang rosette

(require racket/require
         (multi-in "../../frameworks/alglave" ("models.rkt" "framework.rkt"))
         "../../litmus/litmus.rkt"
         (only-in ocelot ast->datum simplify))
(provide run-uniqueness-experiment)

;; Takes as input the name of a reference memory model (used for litmus-test-allowed?),
;; a list of litmus tests, and a memory model sketch.
;; Returns a synthesized model or #f.
(define (run-uniqueness-experiment oracle-model tests model-sketch litmus-sketch first-model
                                   #:threads [nthd 1])
  ;; synth takes as input a list of (test, outcome) pairs
  (define test-outcomes (for/list ([T tests]) (cons T (allowed? alglave T first-model))))
  
  (match-define (litmus-test-sketch threads ops _ _ _ _ _ _) litmus-sketch)
  (printf "Litmus test sketch:\n")
  (printf "  Up to ~v threads, with up to ~v total instructions.\n" threads ops)

  (printf "\nMaking model unique...\n")

  ;; Run the uniqueness engine
  
  (define num-dist-tests 0)
  (define (oracle T)
    (set! num-dist-tests (add1 num-dist-tests))
    (printf "New distinguishing test [#~v]:\n" num-dist-tests)
    (displayln (test->string T))
    (define ret
      (if (procedure? oracle-model)
          (oracle-model T)
          (allowed? alglave T oracle-model)))
    (printf "Allowed by oracle? ~v\n\n" ret)
    ret
  )
        
  (define t0 (current-inexact-milliseconds))
  (define model (make-unique alglave first-model test-outcomes model-sketch litmus-sketch oracle
                             #:threads nthd))
  (define t (- (current-inexact-milliseconds) t0))

  (printf "\nModel is now unique!\n")
  (printf "time: ~a ms\n" (~r t #:precision 0))
  (printf "new tests: ~v\n\n" num-dist-tests)

  (cond
    [model
     (printf "solution: ppo: ~a\n" (ast->datum (simplify (model-ppo model))))
     (printf "          grf: ~a\n" (ast->datum (simplify (model-grf model))))
     (printf "           ab: ~a\n" (ast->datum (simplify (model-ab model))))]
    [else
     (printf "no solution found\n")])

  model)
