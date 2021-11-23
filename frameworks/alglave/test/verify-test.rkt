#lang rosette

(require "../models.rkt" "../framework.rkt"
         "../../../litmus/tests/alglave.rkt" "tests.rkt"
         rackunit rackunit/text-ui)

(define vacuous-tests
  (test-suite
   "vacuous tests"
   #:before (thunk (printf "\n\n-----running vacuous tests-----\n"))
   (run-verify-tests vacuous alglave-tests)))

(define SC-tests
  (test-suite
   "SC tests"
   #:before (thunk (printf "\n\n-----running SC tests-----\n"))
   (run-verify-tests SC alglave-tests)))

(define TSO-tests
  (test-suite
   "TSO tests"
   #:before (thunk (printf "\n\n-----running TSO tests-----\n"))
   (run-verify-tests TSO alglave-tests)))

(define PSO-tests
  (test-suite
   "PSO tests"
   #:before (thunk (printf "\n\n-----running PSO tests-----\n"))
   (run-verify-tests PSO alglave-tests)))

(define Alpha-tests
  (test-suite
   "Alpha tests"
   #:before (thunk (printf "\n\n-----running Alpha tests-----\n"))
   (run-verify-tests Alpha alglave-tests)))

(define RMO-tests
  (test-suite
   "RMO tests"
   #:before (thunk (printf "\n\n-----running RMO tests-----\n"))
   (run-verify-tests RMO alglave-tests)))

(time (run-tests vacuous-tests))
(time (run-tests SC-tests))
(time (run-tests TSO-tests))
(time (run-tests PSO-tests))
(time (run-tests Alpha-tests))
(time (run-tests RMO-tests))
