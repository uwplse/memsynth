#lang racket

(require "../lang-gpu.rkt")

(provide (all-defined-out) (all-from-out "../lang-gpu.rkt"))

; LOAD -> READ
; STORE -> WRITE

;; =================
;; CoRR Litmus Tests 
;; =================

; (1) WebGPU CoRR-default
(define-litmus-test test/coherence/CoRR-default
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
  #:allowed uhd630
)

; (2) WebGPU CoRR-RMW
(define-litmus-test test/coherence/CoRR-rmw
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
(define-litmus-test test/coherence/CoRR-workgroup
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
(define-litmus-test test/coherence/CoRR-workgroup-rmw
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
(define-litmus-test test/coherence/CoRR-rmw1
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
        ; thread 0
        (AR X 1)
        (AR X 0)
      )
    )
  )
  #:post ()
  #:allowed uhd630
)

; (5) WebGPU CoRR-rmw2
(define-litmus-test test/coherence/CoRR-rmw2
  (
    (
      ; workgroup 0
      (
        ; thread 0
        (AW X 1)
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

;; ============================
;; 4-Threaded CoRR Litmus Tests
;; ============================
; (1) WebGPU 4-Threaded CoRR Default

; #To-Do Need to Figure Out How to Model Tests In This Case

;; =================
;; CoWW Litmus Tests
;; =================
; (1) WebGPU CoWW Default
(define-litmus-test test/coherence/CoWW-default
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

; (2) WebGPU CoWW RMW
(define-litmus-test test/coherence/CoWW-rmw
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

; (3) WebGPU CoWW Workgroup
(define-litmus-test test/coherence/CoWW-workgroup
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
(define-litmus-test test/coherence/CoWW-workgroup-rmw
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
;; =================
;; CoWR Litmus Tests
;; =================
; (1) WebGPU CoWR Default
(define-litmus-test test/coherence/CoWR-default
  (
    (; workgroup 0
      (; thread 0
        (AW X 1) ; action 0
        (AR X 2) ; action 1
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
(define-litmus-test test/coherence/CoWR-rmw
  (
    (; workgroup 0
      (; thread 0
        (AE X 1) ; action 0
        (AA X 2) ; action 1
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
(define-litmus-test test/coherence/CoWR-workgroup
  (
    (; workgroup 0
      (; thread 0
        (AW X 1) ; action 0
        (AR X 2) ; action 1
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
(define-litmus-test test/coherence/CoWR-workgroup-rmw
  (
    (; workgroup 0
      (; thread 0
        (AE X 1) ; action 0
        (AA X 2) ; action 1
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
(define-litmus-test test/coherence/CoWR-rmw-1
  (
    (; workgroup 0
      (; thread 0
        (AE X 1) ; action 0
        (AR X 2) ; action 1
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
(define-litmus-test test/coherence/CoWR-rmw-2
  (
    (; workgroup 0
      (; thread 0
        (AW X 1) ; action 0
        (AA X 2) ; action 1
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
(define-litmus-test test/coherence/CoWR-rmw-3
  (
    (; workgroup 0
      (; thread 0
        (AW X 1) ; action 0
        (AR X 2) ; action 1
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
(define-litmus-test test/coherence/CoWR-rmw-4
  (
    (; workgroup 0
      (; thread 0
        (AE X 1) ; action 0
        (AR X 2) ; action 1
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
(define-litmus-test test/coherence/CoWR-rmw-5
  (
    (; workgroup 0
      (; thread 0
        (AE X 1) ; action 0
        (AA X 2) ; action 1
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
(define-litmus-test test/coherence/CoWR-rmw-6
  (
    (; workgroup 0
      (; thread 0
        (AW X 1) ; action 0
        (AA X 2) ; action 1
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
;; ==================
;; CoRW1 Litmus Tests
;; ==================
; (1) CoRW1 Default
(define-litmus-test test/coherence/CoRW1-default
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
(define-litmus-test test/coherence/CoRW1-workgroup
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

;; ==================
;; CoWR2 Litmus Tests
;; ==================
; (1) CoRW2 Default
(define-litmus-test test/coherence/CoRW2-default
  (
    (; workgroup 0
      (; thread 0
        (AR X 2)
        (AW X 1)
      )
    )
    (; workgroup 1
      (; thread 0
        (AW X 2)
      )
    )
  )
  #:post ((X 2))
  #:allowed
)

; (2) CoRW2 RMW
(define-litmus-test test/coherence/CoRW2-rmw
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
(define-litmus-test test/coherence/CoRW2-workgroup
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
(define-litmus-test test/coherence/CoRW2-workgroup-rmw
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

(define intel-gpu-coherence-tests-all
  (list test/coherence/CoRR-default
        test/coherence/CoRR-rmw
        test/coherence/CoRR-workgroup
        test/coherence/CoRR-workgroup-rmw
        test/coherence/CoRR-rmw1
        test/coherence/CoRR-rmw2
        test/coherence/CoWW-default
        test/coherence/CoWW-rmw
        test/coherence/CoWW-workgroup
        test/coherence/CoWW-workgroup-rmw
        test/coherence/CoWR-default
        test/coherence/CoWR-rmw
        test/coherence/CoWR-workgroup
        test/coherence/CoWR-workgroup-rmw
        test/coherence/CoWR-rmw-1
        test/coherence/CoWR-rmw-2
        test/coherence/CoWR-rmw-3
        test/coherence/CoWR-rmw-4
        test/coherence/CoWR-rmw-5
        test/coherence/CoWR-rmw-6
        test/coherence/CoRW1-default
        test/coherence/CoRW1-workgroup
        test/coherence/CoRW2-default
        test/coherence/CoRW2-rmw
        test/coherence/CoRW2-workgroup
        test/coherence/CoRW2-workgroup-rmw
  )
)

(define intel-gpu-coherence-tests-default
  (list test/coherence/CoRR-default
        test/coherence/CoWW-default
        test/coherence/CoWR-default
        test/coherence/CoRW1-default
        test/coherence/CoRW2-default
  )
)

(module+ main
  (for ([T intel-gpu-coherence-tests-all]) (displayln (test->string T)))
)
