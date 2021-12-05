#lang rosette

(require racket/require
         (multi-in "../../../frameworks/opencl" ("relation.rkt" "model.rkt"))
         ocelot
         "../../../litmus/sigs-gpu.rkt")
(provide intel-gpu-sketch)

(define rf (declare-relation 2 "rf"))

;; Creates an Intel-GPU sketch, in which ppo/grf have depth 4 and fences has depth 0.

; (define ppo (make-ppo-sketch 5 (list + - -> & SameAddr)
;                                (list MemoryEvent AReads AWrites rf sb)))
; (define grf (make-grf-sketch 5 (list + - -> & SameAddr)
;                                (list rfi rfe none univ)))
(define ppo (expression-sketch 5 2
  (list + - -> & ~ SameAddr)
  (list MemoryEvent AReads AWrites rf sb)))

(define grf (expression-sketch 5 2 
  (list + - -> & ~ SameAddr) 
  (list rf addr loc thd none sb univ))
)

(define fence (-> none none))

;; Get an an anonymous model with name 'anon
(define intel-gpu-sketch (make-model ppo grf fence))


;; Count the size of the search space defined by the sketch

(module+ main
  (printf "Intel-GPU search space: 2^~v\n" (length (symbolics intel-gpu-sketch))))
