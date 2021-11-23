#lang rosette

(require racket/require
         (multi-in "../../frameworks/alglave" ("models.rkt" "framework.rkt"))
         "../../litmus/litmus.rkt"
         (only-in ocelot ast->datum simplify)
         (only-in "../../memsynth/synth.rkt" synth-tests-used))
(provide run-synthesis-experiment)

;; Takes as input the name of a reference memory model (used for litmus-test-allowed?),
;; a list of litmus tests, and a memory model sketch.
;; Returns a synthesized model or #f.
(define (run-synthesis-experiment spec tests sketch)
  (printf "Tests: ~v\n" (length tests))
  (printf "  positive: ~v\n" (length (filter (lambda (T) (litmus-test-allowed? spec T)) tests)))
  (printf "  negative: ~v\n" (length (filter (lambda (T) (not (litmus-test-allowed? spec T))) tests)))

  (printf "\nSketch state space: 2^~v\n" (length (symbolics sketch)))

  ;; synth takes as input a list of (test, outcome) pairs
  (define test-outcomes (for/list ([T tests]) (cons T (litmus-test-allowed? spec T))))

  ;; Run the synthesis engine
  (printf "\nSynthesizing...\n")
  (define t0 (current-inexact-milliseconds))
  (define model (synth alglave test-outcomes sketch))
  (define t (- (current-inexact-milliseconds) t0))

  (printf "\nSynthesis complete!\n")
  (printf "time: ~a ms\n" (~r t #:precision 0))
  (printf "tests used: ~v/~v\n\n" synth-tests-used (length tests))

  (cond
    [model
     (printf "solution: ppo: ~a\n" (ast->datum (simplify (model-ppo model))))
     (printf "          grf: ~a\n" (ast->datum (simplify (model-grf model))))
     (printf "           ab: ~a\n" (ast->datum (simplify (model-ab model))))]
    [else
     (printf "no solution found\n")]
  )

  ;; Verify the solution
  (when model
    (printf "\nVerifying solution...\n")
    (define successes
      (for/sum ([T tests])
        (define ret (allowed? alglave T model))
        (if (eq? ret (litmus-test-allowed? spec T))
            1
            (begin
              (printf "ERROR: wrong outcome for test ~v\n" (litmus-test-name T))
              0))))
    (printf "Verified ~v litmus tests\n" successes)
  )

  model
)
