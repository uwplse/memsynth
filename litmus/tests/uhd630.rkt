#lang racket

(require "../lang-gpu.rkt")

(provide (all-defined-out) (all-from-out "../lang-gpu.rkt"))

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
(define-litmus-test test/uhd630/CoRR-RMW
  (
    (; workgroup 0
      (; thread 0
        (AE X 1) ; action 0
      )
    )
    (; workgroup 1
      (; thread 0
        (AR X 1) ; action 0
        (RMW X 0) ; action 1
      )
    )
  )
  #:post ()
  #:allowed
)

(define uhd630-coherence-tests
  (list test/uhd630/CoRR-default
        test/uhd630/CoRR-RMW
  )
)

(module+ main
  (for ([T uhd630-coherence-tests]) (displayln (test->string T)))
)
