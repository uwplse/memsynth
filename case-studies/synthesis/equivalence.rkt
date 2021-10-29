#lang s-exp "../../rosette/rosette/main.rkt"

(require racket/require
         (multi-in "../../frameworks/alglave" ("models.rkt" "framework.rkt"))
         "../../litmus/litmus.rkt"
         (only-in ocelot ast->datum simplify))
(provide run-equivalence-experiment)

;; Takes as input the name of a reference memory model (used for litmus-test-allowed?),
;; a list of litmus tests, and a memory model sketch.
;; Returns a synthesized model or #f.
(define (run-equivalence-experiment modelA modelAname modelB modelBname litmus-sketch)
  (printf "\nChecking for equivalence...\n")

  (define t0 (current-inexact-milliseconds))
  (define T (equivalent? alglave modelA modelB litmus-sketch))
  (define td (- (current-inexact-milliseconds) t0))
  (cond
    [T (printf "Models are not equivalent.\n")
       (printf "Distinguishing test:\n")
       (displayln (test->string T))
       (printf "Allowed by ~a: ~v\n" modelAname (allowed? alglave T modelA))
       (printf "Allowed by ~a: ~v\n" modelBname (allowed? alglave T modelB))]
    [else
     (printf "Models are equivalent.\n")])
  (printf "time: ~ams\n" (~r td #:precision 0))
  T)
