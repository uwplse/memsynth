#lang racket

(require "../lang.rkt")

(provide (all-defined-out) (all-from-out "../lang.rkt"))

; Intel SDM §8.2.3.2, example 8-1
; "Stores Are Not Reordered with Older Stores"
(define-litmus-test test/x86/8-1
  (((W X 1)
    (W Y 1))
   ((R Y 1)
    (R X 0)))
  #:allowed)

; Intel SDM §8.2.3.3, example 8-2
; "Stores Are Not Reordered with Older Loads"
(define-litmus-test test/x86/8-2
  (((R X 1)
    (W Y 1))
   ((R Y 1)
    (W X 1)))
  #:allowed)

; Intel SDM §8.2.3.4, example 8-3
; "Loads May be Reordered with Older Stores"
(define-litmus-test test/x86/8-3
  (((W X 1)
    (R Y 0))
   ((W Y 1)
    (R X 0)))
  #:allowed intel-gpu)

; Intel SDM §8.2.3.4, example 8-4
; "Loads Are not Reordered with Older Stores to the Same Location"
(define-litmus-test test/x86/8-4
  (((W X 1)
    (R X 0)))
  #:allowed)

; Intel SDM §8.2.3.5, example 8-5
; "Intra-Processor Forwarding Is Allowed"
(define-litmus-test test/x86/8-5
  (((W X 1)
    (R X 1)
    (R Y 0))
   ((W Y 1)
    (R Y 1)
    (R X 0)))
  #:allowed intel-gpu)

; Intel SDM §8.2.3.6, example 8-6
; "Stores Are Transitively Visible"
(define-litmus-test test/x86/8-6
  (((W X 1))
   ((R X 1)
    (W Y 1))
   ((R Y 1)
    (R X 0)))
  #:allowed)

; Intel SDM §8.2.3.7, example 8-7
; "Stores Are Seen in a Consistent Order by Other Processors"
(define-litmus-test test/x86/8-7
  (((W X 1))
   ((W Y 1))
   ((R X 1)
    (R Y 0))
   ((R Y 1)
    (R X 0)))
  #:allowed)

; Intel SDM §8.2.3.8, example 8-8
; "Locked Instructions Have a Total Order"
(define-litmus-test test/x86/8-8
  (((A X 1))
   ((A Y 1))
   ((R X 1)
    (R Y 0))
   ((R Y 1)
    (R X 0)))
  #:allowed)

; Intel SDM §8.2.3.9, example 8-9
; "Loads Are not Reordered with Locks"
(define-litmus-test test/x86/8-9
  (((A X 1)
    (R Y 0))
   ((A Y 1)
    (R X 0)))
  #:allowed)

; Indel SDM §8.2.3.9, example 8-10
; "Stores Are not Reordered with Locks"
(define-litmus-test test/x86/8-10
  (((A X 1)
    (W Y 1))
   ((R Y 1)
    (R X 0)))
  #:allowed)

(define coherence-tests
  (list test/x86/8-1
        test/x86/8-2
        test/x86/8-3
        test/x86/8-4
        test/x86/8-5
        test/x86/8-6
        test/x86/8-7
        test/x86/8-8
        test/x86/8-9
        test/x86/8-10
        ))


