#lang rosette

(require racket/require
         "../../frameworks/alglave/framework.rkt"
         "../../litmus/litmus.rkt"
         ocelot)
(provide assert-allowed)

;; Return an assertion that the outcome of `test` under `model` with the given
;; `framework` is equal to `outcome`.
(define (assert-allowed framework model test outcome)
  (define bTest (instantiate-test test))
  (define bExec (instantiate-execution framework bTest))
  (define iTest (instantiate-bounds bTest))
  (define iExec (instantiate-bounds bExec))
  (define interp (interpretation-union iTest iExec))
  (define VE (allow framework model))
  (define VE* (interpret* VE interp #:cache? #t))
  (define xs (symbolics iExec))
  (if outcome 
      VE*
      (forall xs (! VE*))))
