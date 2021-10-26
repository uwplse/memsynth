#lang s-exp "../../../../rosette/rosette/main.rkt"

(require "../../models.rkt"
         "../../../../litmus/tests/x86.rkt"
         "../tests.rkt"
         rackunit rackunit/text-ui)

(define verify-tests
  (test-suite
   "x86 tests"
   #:before (thunk (printf "\n\n-----running x86 tests-----\n"))
   (run-verify-tests TSO x86-tests 'x86)))

(time (run-tests verify-tests))
