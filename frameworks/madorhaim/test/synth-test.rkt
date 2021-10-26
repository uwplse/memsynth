#lang s-exp "../../../rosette/rosette/main.rkt"

(require "../models.rkt" "../mnr.rkt" "tests.rkt"
         "../../../litmus/tests/madorhaim.rkt"
         rackunit rackunit/text-ui)

(define vacuous-tests
  (test-suite
   "vacuous tests"
   #:before (thunk (printf "-----running synthesis tests for vacuous-----\n"))
   (run-synth-tests 'vacuous madorhaim-tests (madorhaim-sketch))))

(define SC-tests
  (test-suite
   "SC tests"
   #:before (thunk (printf "-----running synthesis tests for SC-----\n"))
   (run-synth-tests 'SC madorhaim-tests (madorhaim-sketch))))

(define IBM370-tests
  (test-suite
   "IBM370 tests"
   #:before (thunk (printf "-----running synthesis tests for IBM370-----\n"))
   (run-synth-tests 'IBM370 madorhaim-tests (madorhaim-sketch))))

(define TSO-tests
  (test-suite
   "TSO tests"
   #:before (thunk (printf "-----running synthesis tests for TSO-----\n"))
   (run-synth-tests 'TSO madorhaim-tests (madorhaim-sketch))))

(define RMO-tests
  (test-suite
   "RMO tests"
   #:before (thunk (printf "-----running synthesis tests for RMO-----\n"))
   (run-synth-tests 'RMO madorhaim-tests (madorhaim-sketch))))

(time (run-tests vacuous-tests))
(time (run-tests SC-tests))
(time (run-tests IBM370-tests))
(time (run-tests TSO-tests))
(time (run-tests RMO-tests))
