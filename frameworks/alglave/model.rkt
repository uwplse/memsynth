#lang s-exp "../../rosette/rosette/main.rkt"

(require (only-in "../../ocelot/ocelot.rkt" simplify ast->datum))
(provide (struct-out memory-model) make-model
         (rename-out [memory-model-name model-name]
                     [memory-model-ppo  model-ppo]
                     [memory-model-grf  model-grf]
                     [memory-model-ab   model-ab]
                     [memory-model-llh? model-llh?]))

;; model ----------------------------------------------------------------
; a memory model consists of five parts:
; * a name
; * a preserved program order relation, which will be intersected with program
;   order
; * a global reads from relation, containing all globally visible communication
; * a barrier relation, containing happens-before edges induced by fences
; * whether load-load hazards are allowed

(struct memory-model (name ppo grf ab llh?) #:transparent
  #:methods gen:custom-write
  [(define (write-proc self port mode)
    (fprintf port "(memory-model ~a\n        ppo: ~a\n        grf: ~a\n         ab: ~a\n       llh?: ~a)"
                  (memory-model-name self)
                  (ast->datum (simplify (memory-model-ppo self)))
                  (ast->datum (simplify (memory-model-grf self)))
                  (ast->datum (simplify (memory-model-ab self)))
                  (memory-model-llh? self)))])

; an anonymous model
(define (make-model ppo grf ab [llh? #f]) (memory-model 'anon ppo grf ab llh?))
