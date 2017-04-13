#lang racket

(provide log log-types new-log-phase)

(define log-types (make-parameter '()))

(define start (current-inexact-milliseconds))
(define (new-log-phase)
  (set! start (current-inexact-milliseconds))
  (set! last start))
(define last start)

(define (seconds-since t)
  (~r (/ (- (current-inexact-milliseconds) t) 1000) #:precision 2))
(define (msec-since t)
  (~r (- (current-inexact-milliseconds) t) #:precision 0))

(define (log type msg . args)
  (when (memq type (log-types))
    (let ([total (seconds-since start)][la (msec-since last)])
      (printf "[~as; ~ams][~a] ~a\n" total la type (apply format msg args)))
    (set! last (current-inexact-milliseconds))))
