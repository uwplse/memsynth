#lang rosette

(require "../../../memsynth/log.rkt"
         "../../../litmus/tests/x86.rkt"
         "../synthesis.rkt"
         "sketch.rkt")
(provide synthesize-TSO_0)


;; The reference spec to use
(define spec 'x86)

;; The tests to use
(define tests (sort x86-tests < #:key (lambda (T) (length (all-actions (litmus-test-program T))))))

;; The sketch to use
(define sketch x86-sketch)


;; Synthesize TSO_0
(define (synthesize-TSO_0)
  (run-synthesis-experiment spec tests sketch))


;; Run the synthesis
(module+ main
  (when (vector-member "-v" (current-command-line-arguments))
    (log-types '(synth)))
  (printf "===== TSO_0: synthesis experiment =====\n")
  (define TSO_0 (synthesize-TSO_0)))
