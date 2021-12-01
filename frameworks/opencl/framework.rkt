#lang racket

(require "../../memsynth/memsynth-gpu.rkt" "axioms.rkt" "execution.rkt" "model.rkt")
(provide intel-gpu (all-from-out "../../memsynth/memsynth-gpu.rkt"))

(struct intel-gpu-framework ()
  #:methods gen:memsynth-framework
  [ (define (instantiate-execution f test)
     (make-execution test)
    )
    (define (allow f M)
     (match-define (memory-model _ ppo grf ab llh?) M)
     (ValidExecution rf ws ppo grf ab llh?)
    )
  ]
)

(define intel-gpu (intel-gpu-framework))
