#lang racket

(require "../../../../frameworks/alglave/framework.rkt"
         "../../../../frameworks/alglave/model.rkt"
         "../../../../litmus/litmus.rkt"
         ocelot
         "../models/models.rkt"
         racket/sandbox)

(file-stream-buffer-mode (current-output-port) 'none)
(current-subprocess-custodian-mode 'kill)


(define (check-equivalent? m1 m2 timeout)
  (define T_s (litmus-test-sketch 2 6 2 #t #t #f #f #f))
  (with-handlers ([exn:fail:resource? (lambda (e) 'timeout)])
    (with-deep-time-limit timeout
      (equivalent? alglave m1 m2 T_s))
    'success))


(define (check-pairwise-equivalence models timeout)
  (define model-pairs
    (for*/list ([(m1 i) (in-indexed models)][m2 (drop models (add1 i))])
      (cons m1 m2)))
  (define output-path (path->complete-path "memsynth.csv"))
  (printf "Writing results to ~a\n" output-path)
  (define f (open-output-file output-path #:exists 'replace))
  (printf "0/~v\n" (length model-pairs))
  (for ([(m1m2 i) (in-indexed model-pairs)])
    (match-define (cons m1 m2) m1m2)
    (define t0 (current-inexact-milliseconds))
    (define result (check-equivalent? m1 m2 timeout))
    (define t (- (current-inexact-milliseconds) t0))
    (fprintf f "~a_~a,~v,~a\n" (model-name m1) (model-name m2) t result)
    (flush-output f)
    (printf "~v/~v\n" (+ i 1) (length model-pairs)))
  (close-output-port f))
  
(module+ main
  (check-pairwise-equivalence models 120))
