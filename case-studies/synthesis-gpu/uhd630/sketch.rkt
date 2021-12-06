#lang rosette

(require racket/require
         (multi-in "../../../frameworks/opencl" ("relation.rkt" "sketch-model.rkt" "model.rkt"))
         ocelot
         "../../../litmus/sigs-gpu.rkt")
(provide intel-gpu-sketch)


;; Creates an Intel-GPU sketch, in which ppo/grf have depth 4 and fences has depth 0.
; ; Allowed intra-thread reordering
; (define ppo (make-ppo-sketch 5 (list + - -> & SameAddr)
;                                (list sb MemoryEvent AReads AWrites RMWs)))
; Allowed inter-workgroup reordering
(define grf (make-grf-sketch 5 (list + - -> & SameAddr)
                               (list rfi rfe none univ)))


; Allowed intra-thread reordering
(define ppo 
  (& sb 
    (expression-sketch 5 2
      (list + - -> &)
      (list sb MemoryEvent AReads AWrites RMWs)
    )
  )
)

; (define grf (expression-sketch 5 2
;   (list + - -> & SameAddr) 
;   (list addr loc proc sb none univ))
; )

(define fence (-> none none))

;; Get an an anonymous model with name 'anon
(define intel-gpu-sketch (make-model ppo grf fence))


;; Count the size of the search space defined by the sketch

(module+ main
  (printf "Intel-GPU search space: 2^~v\n" (length (symbolics intel-gpu-sketch))))
