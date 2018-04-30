#lang rosette

(require "axioms.rkt" "enumerate.rkt" "allowed.rkt"
         "../../frameworks/madorhaim/execution.rkt"
         "../../memsynth/framework.rkt"
         "../../frameworks/madorhaim/models.rkt"
         "../../litmus/tests/madorhaim.rkt"
         "../../litmus/litmus.rkt"
         ocelot
         rosette/solver/smt/z3)
(provide (all-defined-out)
         (all-from-out rosette/solver/smt/z3)
         (all-from-out "../../litmus/tests/madorhaim.rkt")
         TSO RMO sketch
         assert-allowed)

;; -----------------------------------------------------------------------------
;; This file demonstrates repairing a rule in the Mador-Haim formalism.
;; It uses a copy of the Mador-Haim axioms (in ./axioms.rkt), which has a
;; hole for the broken rule.
;; A repair is correct if it gives the correct results for the 9 given tests on
;; the RMO and TSO memory models.
;; -----------------------------------------------------------------------------

;; basic framework -------------------------------------------------------------

(struct repair-framework ()
  #:methods gen:memsynth-framework
  [(define (instantiate-execution f test)
     (make-execution test))
   (define (allow f M)
     (match-define (memory-model _ F) M)
     (Allowed hb rf F))])


;; Here we define three versions of the Mador-Haim framework:
;; * `original` includes the axiom as written in the paper
;; * `omitted` omits the axiom entirely (by constructing a false precondition)
;; * `sketched` includes a sketch for the axiom's precondition

; Original says "if x is after y in program order, x cannot happen before y"
(define original (repair-framework))


(define (allowed? model test)
  (assert-allowed original model test #t))