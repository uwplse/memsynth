#lang s-exp "../../../../rosette/rosette/main.rkt"

(require "../../../../litmus/litmus.rkt" "../../framework.rkt"
         "../../sketch-model.rkt" "../../models.rkt"
         "../../../../ocelot/ocelot.rkt"
         "../../../../litmus/tests/ppc.rkt"
         "../tests.rkt"
         rackunit rackunit/text-ui)

(define tests 
  (sort ppc-tests < #:key (lambda (T) (length (all-actions (litmus-test-program T))))))
(define tests/no-lwsync 
  (sort ppc-tests/no-lwsync < #:key (lambda (T) (length (all-actions (litmus-test-program T))))))

;; trivial tests ---------------------------------------------------------------

(define (make-trivial-grammar)
  (trivial-sketch PPC SC TSO PSO Alpha RMO vacuous))

(define vacuous-tests/trivial
  (test-suite
   "synthesis: vacuous trivial"
   #:before (thunk (printf "\n\n-----running trivial synthesis tests for vacuous-----\n"))
   (let ([sketch (make-trivial-grammar)])
     (run-synth-tests 'vacuous tests sketch))))

(define PPC-tests/trivial
  (test-suite
   "synthesis: PPC trivial"
   #:before (thunk (printf "\n\n-----running trivial synthesis tests for PPC-----\n"))
   (let ([sketch (make-trivial-grammar)])
     (run-synth-tests 'PPC tests sketch))))

;; grammar tests ---------------------------------------------------------------

(define (make-grammar)
  (let ([rf (declare-relation 2 "rf")])
    (make-model
      (make-ppo-sketch 2 (list + - -> & SameAddr)
                         (list po dp MemoryEvent Reads Writes))
      (make-grf-sketch 2 (list + - ->)
                         (list rfi rfe none univ))
      (make-ab-sketch 4 (list ^ + join)
                        (list rf (join (:> po Syncs) po))))))

(define PPC-tests
  (test-suite
   "synthesis: PPC"
   #:before (thunk (printf "\n\n-----running synthesis tests for PPC-----\n"))
   (let ([sketch (make-grammar)])
     (run-synth-tests 'PPC tests/no-lwsync sketch))))


(time (run-tests vacuous-tests/trivial))
(time (run-tests PPC-tests/trivial))

(time (run-tests PPC-tests))
