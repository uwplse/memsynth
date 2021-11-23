#lang rosette

(require "../framework.rkt" "../model.rkt"
         "../../../litmus/litmus.rkt"
         ocelot
         rackunit)

(provide (all-defined-out))

(current-bitwidth #f)

; clear state but without restarting the solver
(define (clear-most-state!)
;  (current-oracle (oracle))
  (clear-vc!)
  (clear-terms!)
  (gc-terms!)
  (solver-clear (current-solver)))

(define (run-verify-tests M tests [spec #f])
  (define specname (or spec (model-name M)))
  (for ([T tests])
    (test-case (symbol->string (litmus-test-name T))
      ; Judge postcondition of litmus test
      (define-values (is_allowed) (litmus-test-allowed? specname T))
      (printf "~a(~a) " (litmus-test-name T) is_allowed)
      ; Judge whether memory model can satisfy litmus test
      (define-values (sol cpu real gc) (time-apply allowed? (list alglave T M)))
      ; Check the result
      (check-equal? is_allowed (first sol))
      (printf "~ams\n" real)
      (clear-most-state!)
    )
  )
)


(define (run-synth-tests model-name tests sketch [sat? #t])
  (test-begin
   (printf "synthesizing...\n")
   (define TOs (for/list ([T tests]) (cons T (litmus-test-allowed? model-name T))))
   (define M (time (synth alglave TOs sketch)))
   (cond [sat?
          (check-not-false M)
          (printf "solution: ppo: ~a\n" (ast->datum (simplify (model-ppo M))))
          (printf "          grf: ~a\n" (ast->datum (simplify (model-grf M))))
          (printf "           ab: ~a\n" (ast->datum (simplify (model-ab M))))
          (printf "\nverifying...\n")
          (for ([TO TOs])
            (match-define (cons T O) TO)
            (printf "~a(~a) " (litmus-test-name T) O)
            (define-values (sol cpu real gc) (time-apply allowed? (list alglave T M)))
            (check-equal? (first sol) O)
            (printf "~ams\n" real)
            (clear-most-state!))]
         [else
          (printf "no soln\n")
          (check-false M)])
   (clear-most-state!)
   M))
