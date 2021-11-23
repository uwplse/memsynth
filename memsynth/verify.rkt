#lang racket

(require "framework.rkt" "../litmus/litmus.rkt"
         (only-in ocelot interpret bounds-union)
         (only-in rosette solve assert sat?))

(provide allowed?)

; is test T allowed by model M?
(define (allowed? f T M)
  (define bTest (instantiate-test T))
  (define bExec (instantiate-execution f bTest))

  (define Allow (allow f M))
  (define Allow* (interpret Allow (bounds-union bTest bExec)))

  (match Allow*
    [#t #t]
    [#f #f]
    [_ (sat? (solve (assert Allow*)))]))
