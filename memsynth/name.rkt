#lang racket

(require "../litmus/litmus.rkt")
(provide next-name rename-test)

; Utilities for generating litmus test names
(define names (make-hash))

(define (next-name key)
  (define idx (hash-ref names key 0))
  (begin0
    (string->symbol (format "~a~a" key idx))
    (hash-set! names key (add1 idx))))

(define (rename-test t [key 'T])
  (match-define (litmus-test _ prog post allow) t)
  (litmus-test (next-name key) prog post allow))
