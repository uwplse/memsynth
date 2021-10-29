#lang s-exp "../../../rosette/rosette/main.rkt"

(require "../../../frameworks/alglave/models.rkt" "../../../memsynth/log.rkt"
         "../../../litmus/litmus.rkt" "../../../litmus/tests/x86.rkt"
         "../synthesis.rkt" "../uniqueness.rkt"
         "sketch.rkt")


;; The reference spec to use
(define spec 'x86)

;; The tests to use
(define all-tests (sort x86-tests < #:key (lambda (T) (length (all-actions (litmus-test-program T))))))
; Filter out the two tests from 8.2.3.9.
(define tests (filter (lambda (T) (false? (memq (litmus-test-name T) '(test/x86/8-9 test/x86/8-10))))
                      all-tests))

;; The sketch to use
(define sketch x86-sketch)

;; The litmus test sketch to use
(define litmus-sketch (litmus-test-sketch 4 6 2 #f #f #f #f #t))
(define litmus-sketch-small (litmus-test-sketch 2 5 2 #f #f #f #f #t))

;; The oracle memory model to use for uniqueness
(define oracle TSO)

;; Synthesize TSO_0
(define (synthesize-TSO)
  (run-synthesis-experiment spec tests sketch))

(module+ main
  (when (vector-member "-v" (current-command-line-arguments))
    (log-types '(unique)))
  (define litsketch (if (vector-member "-s" (current-command-line-arguments))
                        litmus-sketch-small
                        litmus-sketch))
  (printf "===== x86 potential redundancy experiment =====\n\n")

  (printf "----- Generating TSO model without P8 tests... -----\n\n")
  (define TSO (synthesize-TSO))
  
  (printf "\n\n----- Making that model unique... -----\n")
  (define TSO* (run-uniqueness-experiment oracle tests sketch litsketch TSO)))
