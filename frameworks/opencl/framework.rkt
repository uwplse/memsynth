#lang racket

(require "../../memsynth/memsynth-gpu.rkt" "axioms.rkt" "execution.rkt" "model.rkt")
(provide intel-gpu-fw (all-from-out "../../memsynth/memsynth-gpu.rkt"))

(struct intel-gpu-framework ()
  #:methods gen:memsynth-framework
  [ (define (instantiate-execution f bTest)
     (make-execution bTest)
    )
    (define (allow f M)
     (match-define (memory-model _ ppo grf ab llh?) M)
    ;  (ValidExecution rf mo ppo grf ab llh?)
      (AllowedExecution rf mo ppo grf ab)
    )
  ]
)

(define intel-gpu-fw (intel-gpu-framework))
