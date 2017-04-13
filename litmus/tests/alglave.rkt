#lang racket

(require "../lang.rkt" "nemos.rkt")

(provide (all-defined-out) (all-from-out "../lang.rkt") (all-from-out "nemos.rkt"))

;; single-threaded tests

; Intel x86-64 test 8.2.3.4/8-4 
; "loads are not reordered with older stores to the same location"
(define-litmus-test test/alglave/11a
  (((W X 1)
    (R X 0)))
  #:allowed)

;; example tests from Alglaves "A formal hierarchy of weak memory models"

; These two examples show that RMO and Alpha are incomparable:
; RMO allows some outcomes Alpha does not, and vice versa.

; Fig 10(a). Allowed by RMO, disallowed by Alpha
(define-litmus-test test/alglave/llh
  (((W X 1)
    (R X 2)
    (R X 1))
   ((W X 2)))
  #:allowed RMO vacuous)

; Fig 16. Allowed by Alpha, disallowed by RMO.
; This is a variant of test/nemos/13 with added dependencies.
; Note the papers version is buggy and mislabels the registers.
(define-litmus-test test/alglave/iriw*
  (((R X 1)
    (R Y 0 (0)))
   ((R Y 2)
    (R X 0 (0)))
   ((W X 1))
   ((W Y 2)))
  #:allowed Alpha vacuous)

(define alglave-tests
  (list test/nemos/01 test/nemos/02 test/nemos/10 test/nemos/11 
        test/nemos/12 test/nemos/13 test/nemos/14
        test/alglave/11a test/alglave/llh test/alglave/iriw*))
