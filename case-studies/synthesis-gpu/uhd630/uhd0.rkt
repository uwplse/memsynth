#lang rosette

(require "../../../memsynth/log.rkt"
         "../../../litmus/tests/uhd630.rkt"
         "../synthesis.rkt"
         "sketch.rkt")
(provide synthesize-UHD_0)


;; The reference model to use
(define spec 'uhd630)

;; The litmus tests to use
(define tests (sort uhd630-tests < #:key (lambda (T) (length (all-actions (litmus-test-program T))))))

;; The sketch to use
(define sketch ppc-sketch)


;; Synthesize UHD_0
(define (synthesize-UHD_0)
  (run-synthesis-experiment spec tests sketch))


;; Run the synthesis
(module+ main
  (when (vector-member "-v" (current-command-line-arguments))
    (log-types '(synth)))
  (printf "===== UHD_0: synthesis experiment =====\n")
  (define UHD_0 (synthesize-UHD_0)))
