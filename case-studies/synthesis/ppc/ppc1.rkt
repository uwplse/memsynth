#lang s-exp "../../../rosette/rosette/main.rkt"

(require "../../../memsynth/log.rkt"
         "../../../litmus/litmus.rkt" "../../../litmus/tests/ppc-all.rkt"
         "../synthesis.rkt" "../equivalence.rkt"
         "ppc0.rkt" "sketch.rkt")
(provide synthesize-PPC_0)


;; The reference model to use
(define spec 'PPCalglave)

;; The tests to use
(define hw-tests (filter (lambda (T) (or (litmus-test-allowed? 'PPChw T)
                                     (string-contains? (symbol->string (litmus-test-name T)) "safe")))
                         all-ppc-tests))
(define tests (sort hw-tests < #:key (lambda (T) (length (all-actions (litmus-test-program T))))))

;; The sketch to use
(define sketch ppc-sketch)

;; The litmus test sketch to use for equivalence
(define litmus-sketch (litmus-test-sketch 4 6 2 #t #t #t #t #f))


;; Synthesize PPC_1
(define (synthesize-PPC_1)
  (run-synthesis-experiment spec tests sketch))


;; Run the synthesis
(module+ main
  (when (vector-member "-v" (current-command-line-arguments))
    (log-types '(synth)))
  (printf "===== PPC_1: synthesis experiment =====\n")
  (printf "\n\n----- synthesizing PPC_0 -----\n")
  (define PPC_0 (synthesize-PPC_0))
  (printf "\n\n----- synthesizing PPC_1 -----\n")
  (define PPC_1 (synthesize-PPC_1))
  (printf "\n\n----- checking equivalence -----\n")
  (define T (run-equivalence-experiment PPC_0 'PPC_0 PPC_1 'PPC_1 litmus-sketch)))

