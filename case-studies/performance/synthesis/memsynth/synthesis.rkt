#lang s-exp "../rosette/rosette/main.rkt"

(require "../../../../frameworks/alglave/framework.rkt"
         "../../../../frameworks/alglave/models.rkt"
         "../../../../litmus/tests/x86.rkt"
         "../../../synthesis/synthesis.rkt"
         s-exp "../rosette/rosette/main.rkt"/lib/angelic)

(define spec 'x86)
(define tests (list test/x86/8-1 test/x86/8-3 test/x86/8-5))

(define sketch1 (choose* SC TSO))
(define sketch2 (choose* SC TSO PSO))

(module+ main
  (printf "===== Synthesis with SC and TSO =====\n\n")
  (define M0 (run-synthesis-experiment spec tests sketch1))
  
  (printf "\n===== Synthesis with SC, TSO, and PSO =====\n\n")
  (define M1 (run-synthesis-experiment spec tests sketch2)))
