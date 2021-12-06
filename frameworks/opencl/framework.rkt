#lang racket

(require "../../memsynth/memsynth-gpu.rkt" "axioms.rkt" "execution.rkt" "model.rkt")
(provide intel-gpu-fw (all-from-out "../../memsynth/memsynth-gpu.rkt"))

(struct intel-gpu-framework ()
  #:methods gen:memsynth-framework
  [ (define (instantiate-execution f bTest)
     (make-execution bTest)
    )
    (define (allow f M)
     (match-define (memory-model _ X) M)
      (AllowedExecution rf mo X)
    )
  ]
)

(define intel-gpu-fw (intel-gpu-framework))
