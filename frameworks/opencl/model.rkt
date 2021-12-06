#lang rosette

(require (only-in ocelot simplify ast->datum))
(provide (struct-out memory-model) make-model
         (rename-out [memory-model-name model-name]
                     [memory-model-X model-X]))

;; model ----------------------------------------------------------------
; a memory model consists of five parts:
; * a name
; * a preserved program order relation, which will be intersected with program
;   order
; * a global reads from relation, containing all globally visible communication
; * a barrier relation, containing happens-before edges induced by fences
; * whether load-load hazards(llh) are allowed

(struct memory-model (name X) #:transparent
  #:methods gen:custom-write
  [(define (write-proc self port mode)
    (fprintf port "(memory-model ~a\n       X: ~a)"
                  (memory-model-name self)
                  (ast->datum (simplify (memory-model-X self)))))])

; define an anonymous model
(define (make-model X) (memory-model 'anon X))
