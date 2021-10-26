#lang s-exp "../../../rosette/rosette/main.rkt"

(require "../model.rkt" "../framework.rkt"
         "../../../litmus/tests/madorhaim.rkt"
         (only-in "../../../ocelot/ocelot.rkt" simplify ast->datum)
         rackunit)

(provide (all-defined-out))

(current-bitwidth #f)

(define (clear-most-state!)
;  (current-oracle (oracle))
  (clear-vc!)
  (clear-terms!)
  (gc-terms!)
  (solver-clear (current-solver)))

(define (run-verify-tests M [spec #f])
  (define specname (or spec (model-name M)))
  (for ([T madorhaim-tests])
    (test-case (symbol->string (litmus-test-name T))
      (printf "~a(~a) " (litmus-test-name T) (litmus-test-allowed? specname T))
      (define-values (sol cpu real gc) (time-apply allowed? (list mador-haim T M)))
      (check-equal? (litmus-test-allowed? specname T) (first sol))
      (printf "~ams\n" real)
      (clear-most-state!))))

(define (run-synth-tests model-name tests sketch [sat? #t])
  (test-begin
   (printf "synthesizing...\n")
   (define TOs (for/list ([T tests]) (cons T (litmus-test-allowed? model-name T))))
   (define M (time (synth mador-haim TOs sketch)))
   (cond [sat?
          (check-not-false M)
          (printf "solution: ~a\n" (ast->datum (simplify (model-mnr M))))
          (printf "\nverifying...\n")
          (for ([TO TOs])
            (match-define (cons T O) TO)
            (printf "~a(~a) " (litmus-test-name T) O)
            (define-values (sol cpu real gc) (time-apply allowed? (list mador-haim T M)))
            (check-equal? (first sol) O)
            (printf "~ams\n" real)
            (clear-most-state!))]
         [else
          (printf "no soln\n")
          (check-false M)])
   (clear-most-state!)))
