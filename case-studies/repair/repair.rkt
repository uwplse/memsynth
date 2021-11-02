#lang s-exp "../../rosette/rosette/main.rkt"

(require racket/require
         "axioms.rkt" "enumerate.rkt" "allowed.rkt"
         (multi-in "../../frameworks/madorhaim" ("models.rkt" "execution.rkt" "mnr.rkt"))
         "../../frameworks/alglave/framework.rkt"
         (prefix-in alglave: (only-in "../../frameworks/alglave/models.rkt" TSO RMO))
         "../../litmus/litmus.rkt" "../../litmus/tests/madorhaim.rkt"
         "../../ocelot/ocelot.rkt"
         "../../rosette/rosette/solver/smt/z3.rkt")

;; -----------------------------------------------------------------------------
;; This file demonstrates repairing a rule in the Mador-Haim formalism.
;; It uses a copy of the Mador-Haim axioms (in ./axioms.rkt), which has a
;; hole for the broken rule.
;; A repair is correct if it gives the correct results for the 9 given tests on
;; the RMO and TSO memory models.
;; -----------------------------------------------------------------------------

;; basic framework -------------------------------------------------------------

(struct repair-framework (X)
  #:methods gen:memsynth-framework
  [(define (instantiate-execution f test)
     (make-execution test))
   (define (allow f M)
     (match-define (repair-framework X) f)
     (match-define (memory-model _ F) M)
     (AllowedRepair hb rf F X))])


;; Here we define three versions of the Mador-Haim framework:
;; * `original` includes the axiom as written in the paper
;; * `omitted` omits the axiom entirely (by constructing a false precondition)
;; * `sketched` includes a sketch for the axiom's precondition

; Original says "if x is after y in program order, x cannot happen before y"
(define original (repair-framework (~ po)))

; Omitted says "if #f, x cannot happen before y"
(define omitted (repair-framework (-> none none)))

; Sketched says "if X, x cannot happen before y"
(define rf (declare-relation 2 "rf"))
(define X (expression-sketch 3 2 (list + - & -> SameAddr ~)
                                 (list MemoryEvent Reads Writes po rf)))
(define sketched (repair-framework X))


;; testing ---------------------------------------------------------------------

(printf "===== Testing incorrect axioms =====\n\n")
(printf "The paper says there should be 82 distinct models.\n\n")

; enumerate returns a hash, where each key is a distinct model

(define original-classes
  (enumerate original madorhaim-tests madorhaim-90-allowed?))
(printf "Original axiom, as stated in paper: ~v distinct models\n" (hash-count original-classes))

(define omitted-classes
  (enumerate omitted madorhaim-tests madorhaim-90-allowed?))
(printf "With axiom omitted: ~v distinct models\n" (hash-count omitted-classes))

(printf "\nThe paper also says test L2 should be allowed by some models (e.g. RMO).\n")
(define testL2-classes
  (enumerate original (list test/madorhaim/L2) madorhaim-90-allowed?))
(printf "Models that allow test/madorhaim/L2: ~v\n"  (length (hash-ref testL2-classes '(#t) '())))
(printf "Models that forbid test/madorhaim/L2: ~v\n" (length (hash-ref testL2-classes '(#f) '())))


;; repair ----------------------------------------------------------------------

(printf "\n===== Synthesizing a repaired axiom =====\n\n")

(define t0 (current-inexact-milliseconds))

(define solver (z3))

(for ([T madorhaim-tests])
  ; Ask the Alglave model what the correct outcome should be
  (define TSO? (allowed? alglave T alglave:TSO))
  (define RMO? (allowed? alglave T alglave:RMO))
  (printf "Correct outcomes for test ~a: TSO ~v, RMO ~v\n" (litmus-test-name T) TSO? RMO?)
  ; Assert the correct outcomes for TSO and RMO on the sketched framework
  (solver-assert solver (list (assert-allowed sketched TSO T TSO?)
                              (assert-allowed sketched RMO T RMO?))))

(printf "\n----- Solving... -----\n\n")

(define sol (solver-check solver))

(define t (- (current-inexact-milliseconds) t0))

(cond [(sat? sol)
       (define repaired-pre (evaluate X sol))
       (printf "Found a repair: ~a\n" (ast->datum (simplify repaired-pre)))
       (printf "Time: ~a ms\n" (~r t #:precision 0))
       (printf "\n----- Checking repaired framework... -----\n\n")
       (define repaired (repair-framework repaired-pre))
       (define repaired-classes
         (enumerate repaired madorhaim-tests madorhaim-90-allowed?))
       (printf "Produces ~v distinct models.\n" (hash-count repaired-classes))
       (define testL2-classes-new
         (enumerate repaired (list test/madorhaim/L2) madorhaim-90-allowed?))
       (printf "\nModels that allow test/madorhaim/L2: ~v\n" (length (hash-ref testL2-classes-new '(#t) '())))
       (printf "Models that forbid test/madorhaim/L2: ~v\n" (length (hash-ref testL2-classes-new '(#f) '())))]
      [else
       (printf "No repair found\n")])
