#lang s-exp "../../../rosette/rosette/main.rkt"

(require "../../../memsynth/log.rkt"
         "../../../litmus/tests/ppc-all.rkt"
         "../synthesis.rkt"
         "sketch.rkt")
(provide synthesize-PPC_0)


;; The reference model to use
(define spec 'PPCalglave)

;; The tests to use
(define tests (sort all-ppc-tests < #:key (lambda (T) (length (all-actions (litmus-test-program T))))))

;; The sketch to use
(define sketch ppc-sketch)


;; Synthesize PPC_0
(define (synthesize-PPC_0)
  (run-synthesis-experiment spec tests sketch))


;; Run the synthesis
(module+ main
  (when (vector-member "-v" (current-command-line-arguments))
    (log-types '(synth)))
  (printf "===== PPC_0: synthesis experiment =====\n")
  (define PPC_0 (synthesize-PPC_0)))
