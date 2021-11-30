#lang racket

(require "../lang-gpu.rkt")

(provide (all-defined-out) (all-from-out "../lang-gpu.rkt"))

; LOAD -> READ
; STORE -> WRITE

; CoRR Litmus Tests 

; (1) WebGPU CoRR-default
(define-litmus-test test/uhd630/CoRR-default
  (
    (; workgroup 0
      (; thread 0
        (AW X 1) ; action 0
      )
    )
    (; workgroup 1
      (; thread 0
        (AR X 1) ; action 0
        (AR X 0) ; action 1
      )
    )
  )
  #:post ()
  #:allowed
)

; (2) WebGPU CoRR-RMW
(define-litmus-test test/uhd630/CoRR-rmw
  (
    (; workgroup 0
      (; thread 0
        (AE X 1) ; action 0
      )
    )
    (; workgroup 1
      (; thread 0
        (AR X 1) ; action 0
        (AA X 0) ; action 1
      )
    )
  )
  #:post ()
  #:allowed
)
; (3) WebGPU CoRR-workgroup
(define-litmus-test test/uhd630/CoRR-workgroup
  (
    (
      ; workgroup 0
      (
        ; thread 0
        (AW X 1)
      )
      (
        ; thread 1
        (AR X 1)
        (AR X 0)
      )
    )
  )
  #:post ()
  #:allowed
)

; (4) WebGPU CoRR-workgroup_rmw
(define-litmus-test test/uhd630/CoRR-workgroup-rmw
  (
    (
      ; workgroup 0
      (
        ; thread 0
        (AE X 1)
      )
      (
        ; thread 1
        (AR X 1)
        (AA X 0)
      )
    )
  )
  #:post ()
  #:allowed
)

; (5) WebGPU CoRR-rmw1
(define-litmus-test test/uhd630/CoRR-rmw1
  (
    (
      ; workgroup 0
      (
        ; thread 0
        (AE X 1)
      )
    )
    (
      ; workgroup 1
      (
        ; thread 1
        (AR X 1)
        (AR X 0)
      )
    )
  )
  #:post ()
  #:allowed
)

; (5) WebGPU CoRR-rmw2
(define-litmus-test test/uhd630/CoRR-rmw2
  (
    (
      ; workgroup 0
      (
        ; thread 0
        (AE X 1)
      )
    )
    (
      ; workgroup 1
      (
        ; thread 1
        (AR X 1)
        (AA X 0)
      )
    )
  )
  #:post ()
  #:allowed
)

; 4-Threaded CoRR Litmus Tests
; (1) WebGPU 4-Threaded CoRR Default

; #To-Do Need to Figure Out How to Model Tests In This Case


; CoWW Tests

; (1) WebGPU CoWW Default
(define-litmus-test test/uhd630/CoWW-default
  (
    (; workgroup 0
      (; thread 0
        (AW X 1) ; action 0
        (AW X 2) ; action 0
      )
    )
  )
  #:post ((X 1))
  #:allowed
)

; (2) WebGPU CoWW Default
(define-litmus-test test/uhd630/CoWW-rmw
  (
    (; workgroup 0
      (; thread 0
        (AW X 1) ; action 0
        (AE X 2) ; action 1
      )
    )
  )
  #:post ((X 1))
  #:allowed
)

; (3) WebGPU CoWW Default
(define-litmus-test test/uhd630/CoWW-workgroup
  (
    (; workgroup 0
      (; thread 0
        (AW X 1) ; action 0
        (AW X 2) ; action 1
      )
    )
  )
  #:post ((X 1))
  #:allowed
)

; (4) WebGPU CoWW Workgroup-RMW
(define-litmus-test test/uhd630/CoWW-workgroup-rmw
  (
    (; workgroup 0
      (; thread 0
        (AW X 1) ; action 0
        (AE X 2) ; action 1
      )
    )
  )
  #:post ((X 1))
  #:allowed
)

; CoWR Litmus Tests

; (1) WebGPU CoWR Default
(define-litmus-test test/uhd630/CoWR-default
  (
    (; workgroup 0
      (; thread 0
        (AW X 1) ; action 0
        (AR X 2)
      )
    )
    (; workgroup 1
      (; thread 0
        (AW X 2) ; action 0
      )
    )
  )
  #:post ((X 1))
  #:allowed
)

; (2) WebGPU CoWR RMW
(define-litmus-test test/uhd630/CoWR-rmw
  (
    (; workgroup 0
      (; thread 0
        (AE X 1) ; action 0
        (AA X 0)
      )
    )
    (; workgroup 1
      (; thread 0
        (AE X 2) ; action 0
      )
    )
  )
  #:post ((X 1))
  #:allowed
)

; (3) WebGPU CoWR Workgroup
(define-litmus-test test/uhd630/CoWR-workgroup
  (
    (; workgroup 0
      (; thread 0
        (AW X 1) ; action 0
        (AR X 2)
      )
      (; thread 1
        (AW X 2) ; action 0
      )
    )
  )
  #:post ((X 1))
  #:allowed
)

; (4) WebGPU CoWR Workgroup-RMW
(define-litmus-test test/uhd630/CoWR-workgroup-rmw
  (
    (; workgroup 0
      (; thread 0
        (AE X 1) ; action 0
        (AA X 0)
      )
      (; thread 1
        (AE X 2) ; action 0
      )
    )
  )
  #:post ((X 1))
  #:allowed
)

; (5) WebGPU CoWR RMW-1
(define-litmus-test test/uhd630/CoWR-rmw-1
  (
    (; workgroup 0
      (; thread 0
        (AE X 1) ; action 0
        (AR X 2)
      )
    )
    (; workgroup 1
      (; thread 0
        (AW X 2) ; action 0
      )
    )
  )
  #:post ((X 1))
  #:allowed
)
; (6) WebGPU CoWR RMW-2
(define-litmus-test test/uhd630/CoWR-rmw-2
  (
    (; workgroup 0
      (; thread 0
        (AW X 1) ; action 0
        (AA X 0)
      )
    )
    (; workgroup 1
      (; thread 0
        (AW X 2) ; action 0
      )
    )
  )
  #:post ((X 1))
  #:allowed
)
; (7) WebGPU CoWR RMW-3
(define-litmus-test test/uhd630/CoWR-rmw-3
  (
    (; workgroup 0
      (; thread 0
        (AW X 1) ; action 0
        (AR X 2)
      )
    )
    (; workgroup 1
      (; thread 0
        (AE X 2) ; action 0
      )
    )
  )
  #:post ((X 1))
  #:allowed
)
; (8) WebGPU CoWR RMW-4
(define-litmus-test test/uhd630/CoWR-rmw-4
  (
    (; workgroup 0
      (; thread 0
        (AE X 1) ; action 0
        (AR X 2)
      )
    )
    (; workgroup 1
      (; thread 0
        (AE X 2) ; action 0
      )
    )
  )
  #:post ((X 1))
  #:allowed
)
; (9) WebGPU CoWR RMW-5
(define-litmus-test test/uhd630/CoWR-rmw-5
  (
    (; workgroup 0
      (; thread 0
        (AE X 1) ; action 0
        (AA X 0)
      )
    )
    (; workgroup 1
      (; thread 0
        (AW X 2) ; action 0
      )
    )
  )
  #:post ((X 1))
  #:allowed
)
; (10) WebGPU CoWR RMW-6
(define-litmus-test test/uhd630/CoWR-rmw-6
  (
    (; workgroup 0
      (; thread 0
        (AW X 1) ; action 0
        (AA X 0)
      )
    )
    (; workgroup 1
      (; thread 0
        (AE X 2) ; action 0
      )
    )
  )
  #:post ((X 1))
  #:allowed
)

; CoRW1 Litmus Tests

; (1) CoRW1 Default
(define-litmus-test test/uhd630/CoRW1-default
  (
    (; workgroup 0
      (; thread 0
        (AR X 1)
        (AW X 1)
      )
    )
  )
  #:post ()
  #:allowed
)

; (2) CoRW1 Workgroup
(define-litmus-test test/uhd630/CoRW1-workgroup
  (
    (; workgroup 0
      (; thread 0
        (AR X 1)
        (AW X 1)
      )
    )
  )
  #:post ()
  #:allowed
)


; CoWR2 Litmus Tests

; (1) CoRW2 Default
(define-litmus-test test/uhd630/CoRW2-default
  (
    (; workgroup 0
      (; thread 0
        (AR X 2)
        (AW X 1)
      )
    )
    (; workgroup 1
      (; thread 0
        (AW X 1)
      )
    )
  )
  #:post ((X 2))
  #:allowed
)

; (2) CoRW2 RMW
(define-litmus-test test/uhd630/CoRW2-rmw
  (
    (; workgroup 0
      (; thread 0
        (AR X 2)
        (AW X 1)
      )
    )
    (; workgroup 1
      (; thread 0
        (AE X 2)
      )
    )
  )
  #:post ((X 2))
  #:allowed
)

; (3) CoRW2 Workgroup
(define-litmus-test test/uhd630/CoRW2-workgroup
  (
    (; workgroup 0
      (; thread 0
        (AR X 2)
        (AW X 1)
      )
      (; thread 0
        (AW X 2)
      )
    )
  )
  #:post ((X 2))
  #:allowed
)

; (4) CoRW2 Workgroup-RMW
(define-litmus-test test/uhd630/CoRW2-workgroup-rmw
  (
    (; workgroup 0
      (; thread 0
        (AR X 2)
        (AW X 1)
      )
      (; thread 0
        (AE X 2)
      )
    )
  )
  #:post ((X 2))
  #:allowed
)

(define uhd630-coherence-tests
  (list test/uhd630/CoRR-default
        test/uhd630/CoRR-rmw
        test/uhd630/CoRR-workgroup
        test/uhd630/CoRR-workgroup-rmw
        test/uhd630/CoRR-rmw1
        test/uhd630/CoRR-rmw2
        test/uhd630/CoWW-default
        test/uhd630/CoWW-rmw
        test/uhd630/CoWW-workgroup
        test/uhd630/CoWW-workgroup-rmw
        test/uhd630/CoWR-default
        test/uhd630/CoWR-rmw
        test/uhd630/CoWR-workgroup
        test/uhd630/CoWR-workgroup-rmw
        test/uhd630/CoWR-rmw-1
        test/uhd630/CoWR-rmw-2
        test/uhd630/CoWR-rmw-3
        test/uhd630/CoWR-rmw-4
        test/uhd630/CoWR-rmw-5
        test/uhd630/CoWR-rmw-6
        test/uhd630/CoRW1-default
        test/uhd630/CoRW1-workgroup
        test/uhd630/CoRW2-default
        test/uhd630/CoRW2-rmw
        test/uhd630/CoRW2-workgroup
        test/uhd630/CoRW2-workgroup-rmw
  )
)

(module+ main
  (for ([T uhd630-coherence-tests]) (displayln (test->string T)))
)
