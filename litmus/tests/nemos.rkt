#lang racket

(require "../lang.rkt")

(provide (all-defined-out) (all-from-out "../lang.rkt"))


; Nemos test 1; MemSAT test 1
(define-litmus-test test/nemos/01
  (((R A 1))
   ((W A 1)))
  #:allowed SC TSO PSO Alpha RMO vacuous
  Coherence PRAM Causal PC)


; Nemos test 2; MemSAT test 2
;   Intel x86-64 test 8.2.3.3/8-2 
;   "stores are not reordered with earlier loads"
(define-litmus-test test/nemos/02
  (((R B 1)
    (W A 1))
   ((R A 1)
    (W B 1)))
  #:allowed Alpha RMO vacuous
  Coherence PRAM PC)


; Nemos test 3; MemSAT test 3
(define-litmus-test test/nemos/03
  (((W B 0))
   ((W B 1))
   ((R B 0)
    (W A 0)
    (R C 0))
   ((R B 1)
    (R A 0)
    (R C 1))
   ((R C 1)
    (R A 1)
    (R B 1))
   ((R C 0)
    (W A 1)
    (R B 0))
   ((W C 1))
   ((W C 0)))
  #:allowed SC Coherence PRAM Causal PC)


; Nemos test 4; MemSAT test 4
(define-litmus-test test/nemos/04
  (((W X 0)
    (W X 1)
    (R Y 0))
   ((W Y 0)
    (W Y 1)
    (R X 0)))
  #:allowed Coherence PRAM Causal PC)


; Nemos test 5; MemSAT test 5
(define-litmus-test test/nemos/05
  (((W X 0)
    (W X 1)
    (W Y 2))
   ((R Y 2)
    (R X 0)))
  #:allowed Coherence)


; Nemos test 6; MemSAT test 6
(define-litmus-test test/nemos/06
  (((W X 0)
    (R X 1))
   ((W X 1)
    (R X 0)))
  #:allowed PRAM Causal)


; Nemos test 7; MemSAT test 7
(define-litmus-test test/nemos/07
  (((W X 0)
    (W X 1)
    (W Z 0)
    (R Y 0))
   ((W Y 0)
    (W Y 1)
    (W Z 1)
    (R X 0)))
  #:allowed Coherence PRAM Causal)


; Nemos test 8; MemSAT test 8
(define-litmus-test test/nemos/08
  (((W X 0)
    (W Y 0))
   ((R Y 0)
    (W X 1))
   ((R X 1)
    (R X 0)))
  #:allowed SC Coherence PRAM Causal PC)


; Nemos test 10; MemSAT test 9
(define-litmus-test test/nemos/09
  (((W X 0)
    (W X 1)
    (W Y 1))
   ((R Y 1)
    (R Z 0))
   ((W Z 0)
    (W Z 1)
    (W V 1))
   ((R V 1)
    (R X 0)))
  #:allowed Coherence PRAM Causal PC)


; Nemos test 11; MemSAT test 10
;   Intel x86-64 test 8.2.3.2/8-1 
;   "neither loads nor stores are reordered with like operations"
(define-litmus-test test/nemos/10
  (((W X 1)
    (W Y 1))
   ((R Y 1)
    (R X 0)))
  #:allowed PSO Alpha RMO vacuous
  Coherence)


; Nemos test 12; MemSAT test 11
;   Intel x86-64 test 8.2.3.4/8-3 
;   "loads may be reordered with earlier stores to different locations"
(define-litmus-test test/nemos/11
  (((W X 1)
    (R Y 0))
   ((W Y 1)
    (R X 0)))
  #:allowed TSO PSO Alpha RMO vacuous
  Coherence PRAM Causal PC)  ; bug: Causal should not allow  


; Nemos test 13; MemSAT test 12
;   Intel x86-64 test 8.2.3.6/8-6 
;   "stores are transitively visible"
(define-litmus-test test/nemos/12
  (((W A 1))
   ((R A 1)
    (W B 1))
   ((R B 1)
    (R A 0)))
  #:allowed Alpha RMO vacuous
  Coherence PRAM PC)


; Nemos test 14; MemSAT test 13
;   Intel x86-64 test 8.2.3.7/8-7 
;   "stores are seen in a consistent order by other processors"
(define-litmus-test test/nemos/13
  (((W X 1))
   ((W Y 1))
   ((R X 1)
    (R Y 0))
   ((R Y 1)
    (R X 0)))
  #:allowed Alpha RMO vacuous
  Coherence PRAM Causal PC)  ; bug: Causal should not allow


; Nemos test 15; MemSAT test 14
;   Intel x86-64 test 8.2.3.5/8-5 
;   "intra-processor forwarding is allowed"
(define-litmus-test test/nemos/14
  (((W A 1)
    (R A 1)
    (R B 0))
   ((W B 1)
    (R B 1)
    (R A 0)))
  #:allowed TSO PSO Alpha RMO vacuous
  Coherence PRAM Causal PC)  ; bug: Causal should not allow


; Nemos test 16; MemSAT test 15
(define-litmus-test test/nemos/15
  (((W A 1)
    (W C 1)
    (R C 1)
    (R B 0))
   ((W B 1)
    (W C 2)
    (R C 2)
    (R A 0)))
  #:allowed Coherence PRAM Causal)  ; bug: Causal should not allow


(define nemos-tests
  (list test/nemos/01 
        test/nemos/02 
        test/nemos/03
        test/nemos/04
        test/nemos/05
        test/nemos/06
        test/nemos/07
        test/nemos/08
        test/nemos/09
        test/nemos/10 
        test/nemos/11
        test/nemos/12
        test/nemos/13
        test/nemos/14
        test/nemos/15))
