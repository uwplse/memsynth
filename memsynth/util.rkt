#lang rosette

(require (only-in rosette/base/core/type solvable-default)
         (prefix-in $ racket))

(provide (all-defined-out))

(define-syntax-rule (append! lst lsts ...)
  (set! lst (append lst lsts ...)))
(define-syntax-rule (append*! lst lsts ...)
  (set! lst ($remove-duplicates (append lst lsts ...))))
(define-syntax-rule (append-one! lst elem)
  (append! lst (list elem)))
(define-syntax-rule (remove! lst elem)
  (set! lst (remove elem lst)))

; Given a model? and a list of constants, produce a new model? which binds only
; the constants in the given list. If such a constant doesn't appear in the
; given model, it is bound to the appropriate default value.
(define (model-for sol consts)
  (match sol
    [(model m)
     (sat (for/hash ([x consts] #:when (constant? x))
            (values x (dict-ref m x (value-for x)))))]))
(define (value-for v)
  (if (constant? v)
      (solvable-default (term-type v))
      v))
