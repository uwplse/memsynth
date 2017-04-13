#lang racket

(require "../lang.rkt")

(provide (all-defined-out) (all-from-out "../lang.rkt"))

(define-litmus-test test/madorhaim/L1
  (((W X 1)
    (W Y 1))
   ((R Y 1)
    (F)
    (R X 0)))
  #:allowed RMO vacuous)

(define-litmus-test test/madorhaim/L2
  (((W X 1)
    (W X 2))
   ((R X 2)
    (R X 0)))
  #:allowed RMO vacuous)

(define-litmus-test test/madorhaim/L3
  (((W X 1)
    (F)
    (W Y 2))
   ((R Y 2)
    (R X 0)))
  #:allowed RMO vacuous)

(define-litmus-test test/madorhaim/L4
  (((W X 1)
    (F)
    (W Y 2))
   ((R Y 2)
    (R X 0 (0))))
  #:allowed vacuous)

(define-litmus-test test/madorhaim/L5
  (((R X 1)
    (W Y 1))
   ((R Y 1)
    (W X 1)))
  #:allowed RMO vacuous)

(define-litmus-test test/madorhaim/L6
  (((R X 1)
    (W Y 1 (0)))
   ((R Y 1)
    (W X 1 (0))))
  #:allowed vacuous)

(define-litmus-test test/madorhaim/L7
  (((W X 1)
    (R Y 0))
   ((W Y 1)
    (R X 0)))
  #:allowed IBM370 TSO RMO vacuous)

(define-litmus-test test/madorhaim/L8
  (((W X 1)
    (R X 1)
    (R Y 0 (1)))
   ((W Y 1)
    (R Y 1)
    (R X 0 (1))))
  #:allowed TSO RMO vacuous)

(define-litmus-test test/madorhaim/L9
  (((W X 1)
    (R X 1)
    (W Y 1 (1)))
   ((R Y 1)
    (W X 2 (0))
    (R X 1)))
  #:allowed RMO vacuous)

(define madorhaim-tests
  (list test/madorhaim/L1 test/madorhaim/L2 test/madorhaim/L3 test/madorhaim/L4 test/madorhaim/L5 
        test/madorhaim/L6 test/madorhaim/L7 test/madorhaim/L8 test/madorhaim/L9))
