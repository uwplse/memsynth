#lang rosette

(require "../framework.rkt" "../models.rkt" "../mnr.rkt"
         "../../../litmus/litmus.rkt"
         rackunit rackunit/text-ui)

(define (run-equivalent-test mA mB [equiv? #f])
  (test-begin
   (printf "~a ≡ ~a? " (model-name mA) (model-name mB))
   (define T_s (litmus-test-sketch 2 4 2 #f #f #f #f #f))
   (define-values (lR cpu real gc) (time-apply (thunk (equivalent? mador-haim mA mB T_s)) '()))
   (define R (first lR))
   (cond [equiv? (check-equal? R #t)
                 (printf "#t (~v ms)\n" real)]
         [else   (check-pred  litmus-test? R)
                 (printf "#f (~v ms) " real)
                 (define vA (allowed? mador-haim R mA))
                 (define vB (allowed? mador-haim R mB))
                 (printf "~a=~v, ~a=~v\n" (model-name mA) vA (model-name mB) vB)])))

(define equivalent-tests
  (test-suite
   "equivalent tests"
   #:before (thunk (printf "-----testing equivalence-----\n"))
   (run-equivalent-test TSO SC)
   (run-equivalent-test SC (model-number->model 4444) #t)
   (run-equivalent-test TSO RMO)
   (run-equivalent-test RMO (model-number->model 1010) #t)
   ))

(time (run-tests equivalent-tests))
