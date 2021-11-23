#lang rosette

(require "../../models.rkt"
         "../../../../litmus/tests/ppc-all.rkt" 
         "../tests.rkt"
         rackunit rackunit/text-ui)

(define PPC-tests
  (test-suite
   "PPC tests"
   #:before (thunk (printf "\n\n-----running PPC tests-----\n"))
   (run-verify-tests PPC all-ppc-tests 'PPCalglave)))

(time (run-tests PPC-tests))
