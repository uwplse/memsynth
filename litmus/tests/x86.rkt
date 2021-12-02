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
  #:allowed x86)

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
  #:allowed x86)

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

(define x86-tests
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

(define x86-tests/no-atomics
  (list test/x86/8-1
        test/x86/8-2
        test/x86/8-3
        test/x86/8-4
        test/x86/8-5
        test/x86/8-6
        test/x86/8-7
        ))


;; Tests from the x86-TSO model effort -----------------------------------------
;; Some of these tests duplicate those from the current Intel manual above.
;; Source: A better x86 memory model: x86-TSO (extended version)
;;         http://www.cl.cam.ac.uk/~pes20/weakmemory/x86tso-paper.pdf

(define-litmus-test test/x86tso/iwp2.1/amd1
  (((W X 1)
    (W Y 1))
   ((R Y 1)
    (R X 0)))
  #:allowed)

(define-litmus-test test/x86tso/iwp2.2/amd2
  (((W X 1)
    (W Y 1))
   ((R Y 1)
    (R X 0)))
  #:allowed)

(define-litmus-test test/x86tso/iwp2.3.a/amd4
  (((W X 1)
    (R Y 0))
   ((W Y 1)
    (R X 0)))
  #:allowed x86)

(define-litmus-test test/x86tso/iwp2.3.b
  (((W X 1)
    (R X 0))
   ((W Y 1)
    (R Y 0)))
  #:allowed)

(define-litmus-test test/x86tso/iwp2.4/amd9
  (((W X 1)
    (R X 1)
    (R Y 0))
   ((W Y 1)
    (R Y 1)
    (R X 0)))
  #:allowed x86)

(define-litmus-test test/x86tso/iwp2.5/amd8
  (((W X 1))
   ((R X 1)
    (W Y 1))
   ((R Y 1)
    (R X 0)))
  #:allowed)

(define-litmus-test test/x86tso/amd3
  (((W X 1)
    (W X 2)
    (R Y 1))
   ((W Y 1)
    (W Y 2)
    (R X 1)))
  #:allowed x86)

(define-litmus-test test/x86tso/iwp2.6
  (((W X 1))
   ((W X 2))
   ((R X 1)
    (R X 2))
   ((R X 2)
    (R X 1)))
  #:allowed)

(define-litmus-test test/x86tso/amd6
  (((W X 1))
   ((W Y 1))
   ((R X 1)
    (R Y 0))
   ((R Y 1)
    (R X 0)))
  #:allowed)

(define-litmus-test test/x86tso/iwp2.7/amd7
  (((A X 1))
   ((A Y 1))
   ((R X 1)
    (R Y 0))
   ((R Y 1)
    (R X 0)))
  #:allowed)

(define-litmus-test test/x86tso/iwp2.8.a
  (((A X 1)
    (R Y 0))
   ((A Y 1)
    (R X 0)))
  #:allowed)

(define-litmus-test test/x86tso/iwp2.8.b
  (((A X 1)
    (W Y 1))
   ((R Y 1)
    (R X 0)))
  #:allowed)

; this test is incorrect in the paper; this is the corrected version
; see errata: https://www.cl.cam.ac.uk/~pes20/weakmemory/x86tso-paper.errata.txt
(define-litmus-test test/x86tso/n8
  (((A X 1)
    (R Y 0))
   ((W Y 1)
    (R X 0)))
  #:allowed x86)

(define-litmus-test test/x86tso/n3
  (((A X 1))
   ((W Y 1))
   ((R Y 1)
    (R X 0)
    (R X 1))
   ((R X 1)
    (R Y 0)
    (R Y 1)))
  #:allowed)

(define-litmus-test test/x86tso/amd10
  (((W X 1)
    (F sync)
    (R X 1)
    (R Y 0))
   ((W Y 1)
    (F sync)
    (R Y 1)
    (R X 0)))
  #:allowed)

(define-litmus-test test/x86tso/amd5
  (((W X 1)
    (F sync)
    (R Y 0))
   ((W Y 1)
    (F sync)
    (R X 0)))
  #:allowed)

(define-litmus-test test/x86tso/n6
  (((W X 1)
    (R X 1)
    (R Y 0))
   ((W Y 2)
    (W X 2)))
  #:post ((X 1))
  #:allowed x86)

(define-litmus-test test/x86tso/n5
  (((W X 1)
    (R X 2))
   ((W X 2)
    (R X 1)))
  #:allowed)

(define-litmus-test test/x86tso/n4
  (((R X 2)
    (W X 1)
    (R X 1))
   ((R X 1)
    (W X 2)
    (R X 2)))
  #:allowed)

(define-litmus-test test/x86tso/n7
  (((W X 1)
    (R X 1)
    (R Y 0))
   ((W Y 1))
   ((R Y 1)
    (R X 0)))
  #:allowed x86)

(define-litmus-test test/x86tso/n1
  (((W X 2)
    (R Y 0))
   ((W Y 1)
    (W X 1))
   ((R X 1)
    (R X 2)))
  #:allowed x86)

(define-litmus-test test/x86tso/n2
  (((W Y 1)
    (W X 1))
   ((W X 2)
    (W Z 1))
   ((R X 1)
    (R X 2))
   ((R Z 1)
    (R Y 0)))
  #:allowed)

(define-litmus-test test/x86tso/rwc-unfenced
  (((W X 1))
   ((R X 1)
    (R Y 0))
   ((W Y 1)
    (R X 0)))
  #:allowed x86)

(define-litmus-test test/x86tso/rwc-fenced
  (((W X 1))
   ((R X 1)
    (R Y 0))
   ((W Y 1)
    (F sync)
    (R X 0)))
  #:allowed)

(define x86tso-tests
  (list test/x86tso/amd10
        test/x86tso/amd3
        test/x86tso/amd5
        test/x86tso/amd6
        test/x86tso/iwp2.1/amd1
        test/x86tso/iwp2.2/amd2
        test/x86tso/iwp2.3.a/amd4
        test/x86tso/iwp2.3.b
        test/x86tso/iwp2.4/amd9
        test/x86tso/iwp2.5/amd8
        test/x86tso/iwp2.6
        test/x86tso/iwp2.7/amd7
        test/x86tso/iwp2.8.a
        test/x86tso/iwp2.8.b
        test/x86tso/n1
        test/x86tso/n2
        test/x86tso/n3
        test/x86tso/n4
        test/x86tso/n5
        test/x86tso/n6
        test/x86tso/n7
        test/x86tso/n8
        test/x86tso/rwc-fenced
        test/x86tso/rwc-unfenced))

(module+ main
  (for ([T x86-tests]) (displayln (test->string T)))
)
