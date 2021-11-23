#lang rosette

(require "../models.rkt" "../mnr.rkt" "tests.rkt"
         rackunit rackunit/text-ui)

(define vacuous-tests
  (test-suite
   "vacuous tests"
   #:before (thunk (printf "-----running vacuous tests-----\n"))
   (run-verify-tests (model-number->model 0000) 'vacuous)))

(define SC-tests
  (test-suite
   "SC tests"
   #:before (thunk (printf "-----running SC tests-----\n"))
   (run-verify-tests (model-number->model 4444) 'SC)))

(define IBM370-tests
  (test-suite
   "IBM370 tests"
   #:before (thunk (printf "-----running IBM370 tests-----\n"))
   (run-verify-tests (model-number->model 4144) 'IBM370)))

(define TSO-tests
  (test-suite
   "TSO tests"
   #:before (thunk (printf "-----running TSO tests-----\n"))
   (run-verify-tests (model-number->model 4044) 'TSO)))

; Note: in Fig. 4 of the paper, RMO is specified as 1010, but that's *without*
; data dependencies. RMO does not allow read-read and read-write dependencies to
; be reordered, so add 2 to the RW and RR digits to get 1032.
(define RMO-tests
  (test-suite
   "RMO tests"
   #:before (thunk (printf "-----running RMO tests-----\n"))
   (run-verify-tests (model-number->model 1032) 'RMO)))

(time (run-tests vacuous-tests))
(time (run-tests SC-tests))
(time (run-tests IBM370-tests))
(time (run-tests TSO-tests))
(time (run-tests RMO-tests))
