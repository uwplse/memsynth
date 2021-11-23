#lang rosette

(require "../framework.rkt" "../models.rkt" "../../../litmus/litmus.rkt"
         ocelot
         "../../../memsynth/strategy/threads.rkt"
         "../../../memsynth/strategy/none.rkt"
         "../../../memsynth/strategy/first.rkt"
         rackunit rackunit/text-ui)

(define rf (declare-relation 2 "rf"))
(define TSO* (make-model (- po (-> Writes Reads)) (rfe rf) (-> none none)))

(define-syntax-rule (make-equiv-tests name options ...)
  (test-suite
   name
   #:before (thunk (printf "\n\n-----running ~a-----\n" name))
   (let ([T_s (litmus-test-sketch 2 4 2 #f #f #f #f #f)])
     (printf "TSO ≡ TSO?\n")
     (check-true (time (equivalent? alglave TSO TSO T_s options ...)))
     (printf "TSO ≡ SC?\n")
     (check-pred litmus-test? (time (equivalent? alglave TSO SC T_s options ...)))
     (printf "TSO stronger than SC?\n")
     (check-pred litmus-test? (time (equivalent? alglave TSO SC T_s 'stronger options ...)))
     (printf "TSO weaker than SC?\n")
     (check-true (time (equivalent? alglave TSO SC T_s 'weaker options ...)))
     (printf "TSO vs TSO*\n")
     (check-true (time (equivalent? alglave TSO TSO* T_s options ...))))))

(define equiv-tests
  (make-equiv-tests "Equivalence tests"))
(define equiv-tests/threads
  (make-equiv-tests "Equivalence tests (thread strategy)" #:strategy make-threads-strategy))
(define equiv-tests/none
  (make-equiv-tests "Equivalence tests (none strategy)" #:strategy make-none-strategy))
(define equiv-tests/first
  (make-equiv-tests "Equivalence tests (first strategy)" #:strategy make-first-strategy))
(define equiv-tests/parallel
  (make-equiv-tests "Equivalence tests (parallel)" #:threads 2))

(time (run-tests equiv-tests))
(time (run-tests equiv-tests/threads))
(time (run-tests equiv-tests/none))
(time (run-tests equiv-tests/first))
(time (run-tests equiv-tests/parallel))
