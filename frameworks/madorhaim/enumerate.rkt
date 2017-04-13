#lang rosette

(require "framework.rkt" "mnr.rkt")

(provide enumerate)

; Enumerate over all model numbers that satisfy the given predicate, and return
; the outcomes for each test
(define (enumerate tests [pred? (const #t)])
  (for/fold ([ret (hash)]) ([i 4445] #:when (and (valid-model-number? i) (pred? i)))
    (define M (model-number->model i))
    (define all-results (for/list ([T tests]) (allowed? mador-haim T M)))
    (hash-set ret all-results (append (hash-ref ret all-results '()) (list i)))))
