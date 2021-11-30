#lang rosette

(require "../../../memsynth/log.rkt"
         "../../../litmus/tests/uhd630.rkt"
         "../synthesis.rkt"
         "sketch.rkt")
(provide synthesize-UHD_0)


;; The reference model to use
(define spec 'uhd630)

;; The litmus tests to use
(define tests (sort uhd630-coherence-tests < #:key (lambda (T) (length (all-actions (litmus-test-program T))))))

;; Show litmus test
(define (show-test tests) (for ([T tests]) (displayln (test->string T))))

;; The framework sketch to use
(define sketch intel-gpu-sketch)

;; Synthesize UHD_0
(define (synthesize-UHD_0)
  (run-synthesis-experiment spec tests sketch))

;; Run the synthesis
(module+ main
  (when (vector-member "-v" (current-command-line-arguments))
    (log-types '(synth)))
  (show-test tests)
  (printf "===== UHD_0: synthesis experiment =====\n")
  (define UHD_0 (synthesize-UHD_0))
)
