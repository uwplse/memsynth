#lang rosette

(require "../framework.rkt" "../sketch-model.rkt" "../models.rkt"
         "../../../ocelot/ocelot.rkt"
         "../../../litmus/tests/alglave.rkt" "../../../litmus/litmus.rkt" 
         "tests.rkt"
         rackunit rackunit/text-ui)

(define tests (sort alglave-tests < #:key (lambda (T) (length (all-actions (litmus-test-program T))))))

;; trivial tests ---------------------------------------------------------------

(define (make-trivial-grammar)
  (trivial-sketch SC TSO PSO Alpha RMO vacuous))

(define SC-tests/trivial
  (test-suite
   "synthesis: SC trivial"
   #:before (thunk (printf "\n\n-----running trivial synthesis tests for SC-----\n"))
   (let ([sketch (make-trivial-grammar)])
     (run-synth-tests 'SC tests sketch))))

(define TSO-tests/trivial
  (test-suite
   "synthesis: TSO trivial"
   #:before (thunk (printf "\n\n-----running trivial synthesis tests for TSO-----\n"))
   (let ([sketch (make-trivial-grammar)])
     (run-synth-tests 'TSO tests sketch))))

(define PSO-tests/trivial
  (test-suite
   "synthesis: PSO trivial"
   #:before (thunk (printf "\n\n-----running trivial synthesis tests for PSO-----\n"))
   (let ([sketch (make-trivial-grammar)])
     (run-synth-tests 'PSO tests sketch))))

(define Alpha-tests/trivial
  (test-suite
   "synthesis: Alpha trivial"
   #:before (thunk (printf "\n\n-----running trivial synthesis tests for Alpha-----\n"))
   (let ([sketch (make-trivial-grammar)])
     (run-synth-tests 'Alpha tests sketch))))

(define RMO-tests/trivial
  (test-suite
   "synthesis: RMO trivial"
   #:before (thunk (printf "\n\n-----running trivial synthesis tests for RMO-----\n"))
   (let ([sketch (make-trivial-grammar)])
     (run-synth-tests 'RMO tests sketch))))

(define vacuous-tests/trivial
  (test-suite
   "synthesis: vacuous trivial"
   #:before (thunk (printf "\n\n-----running trivial synthesis tests for vacuous-----\n"))
   (let ([sketch (make-trivial-grammar)])
     (run-synth-tests 'vacuous tests sketch))))

(define unsat-tests/trivial
  (test-suite
   "synthesis: unsat trivial"
   #:before (thunk (printf "\n\n-----running trivial synthesis tests for unsat-----\n"))
   (let ([sketch (make-trivial-grammar)])
     (run-synth-tests 'any tests sketch #f))))

;; grammar tests ---------------------------------------------------------------

(define (make-grammar)
  (define-symbolic* llh? boolean?)
  (make-model
    (make-ppo-sketch 2 (list + - -> & SameAddr)
                       (list po dp MemoryEvent Reads Writes))
    (make-grf-sketch 2 (list + - ->)
                       (list rfi rfe none univ))
    (-> none none)
    llh?))

(define SC-tests
  (test-suite
   "synthesis: SC"
   #:before (thunk (printf "\n\n-----running synthesis tests for SC-----\n"))
   (let ([sketch (make-grammar)])
     (run-synth-tests 'SC tests sketch))))

(define TSO-tests
  (test-suite
   "synthesis: TSO"
   #:before (thunk (printf "\n\n-----running synthesis tests for TSO-----\n"))
   (let ([sketch (make-grammar)])
     (run-synth-tests 'TSO tests sketch))))

(define PSO-tests
  (test-suite
   "synthesis: PSO"
   #:before (thunk (printf "\n\n-----running synthesis tests for PSO-----\n"))
   (let ([sketch (make-grammar)])
     (run-synth-tests 'PSO tests sketch))))

(define Alpha-tests
  (test-suite
   "synthesis: Alpha"
   #:before (thunk (printf "\n\n-----running synthesis tests for Alpha-----\n"))
   (let ([sketch (make-grammar)])
     (run-synth-tests 'Alpha tests sketch))))

(define RMO-tests
  (test-suite
   "synthesis: RMO"
   #:before (thunk (printf "\n\n-----running synthesis tests for RMO-----\n"))
   (let ([sketch (make-grammar)])
     (run-synth-tests 'RMO tests sketch))))

(define vacuous-tests
  (test-suite
   "synthesis: vacuous"
   #:before (thunk (printf "\n\n-----running synthesis tests for vacuous-----\n"))
   (let ([sketch (make-grammar)])
     (run-synth-tests 'vacuous tests sketch))))

(define unsat-tests
  (test-suite
   "synthesis: unsat"
   #:before (thunk (printf "\n\n-----running synthesis tests for unsat-----\n"))
   (let ([sketch (make-grammar)])
     (run-synth-tests 'any tests sketch #f))))


(time (run-tests SC-tests/trivial))
(time (run-tests TSO-tests/trivial))
(time (run-tests PSO-tests/trivial))
(time (run-tests Alpha-tests/trivial))
(time (run-tests RMO-tests/trivial))
(time (run-tests vacuous-tests/trivial))
(time (run-tests unsat-tests/trivial))

(time (run-tests SC-tests))
(time (run-tests TSO-tests))
(time (run-tests PSO-tests))
(time (run-tests Alpha-tests))
(time (run-tests RMO-tests))
(time (run-tests vacuous-tests))
(time (run-tests unsat-tests))
