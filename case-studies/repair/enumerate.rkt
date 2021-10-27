#lang s-exp "../../rosette/rosette/main.rkt"

(require "../../frameworks/madorhaim/enumerate.rkt"
         "../../frameworks/madorhaim/mnr.rkt"
         "../../memsynth/memsynth.rkt"
         "../../litmus/tests/madorhaim.rkt")

(provide enumerate)

(define (enumerate framework tests [pred? (const #t)])
  (for/fold ([ret (hash)]) ([i 4445] #:when (and (valid-model-number? i) (pred? i)))
    (define M (model-number->model i))
    (define all-results (for/list ([T tests])
                          (parameterize ([current-terms (hash-copy (current-terms))])
                          (allowed? framework T M))
                        )
    )
    (hash-set ret all-results (append (hash-ref ret all-results '()) (list i)))
  )
)
