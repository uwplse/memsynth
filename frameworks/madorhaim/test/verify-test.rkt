#lang s-exp "../../../rosette/rosette/main.rkt"

(require "../models.rkt" "tests.rkt"
         rackunit rackunit/text-ui)

(define vacuous-tests
  (test-suite
   "vacuous tests"
   #:before (thunk (printf "-----running vacuous tests-----\n"))
   (run-verify-tests vacuous)))

(define SC-tests
  (test-suite
   "SC tests"
   #:before (thunk (printf "-----running SC tests-----\n"))
   (run-verify-tests SC)))

(define IBM370-tests
  (test-suite
   "IBM370 tests"
   #:before (thunk (printf "-----running IBM370 tests-----\n"))
   (run-verify-tests IBM370)))

(define TSO-tests
  (test-suite
   "TSO tests"
   #:before (thunk (printf "-----running TSO tests-----\n"))
   (run-verify-tests TSO)))

(define RMO-tests
  (test-suite
   "RMO tests"
   #:before (thunk (printf "-----running RMO tests-----\n"))
   (run-verify-tests RMO)))

(time (run-tests vacuous-tests))
(time (run-tests SC-tests))
(time (run-tests IBM370-tests))
(time (run-tests TSO-tests))
(time (run-tests RMO-tests))
