#lang s-exp "../../rosette/rosette/main.rkt"

(provide (struct-out memory-model) make-model
         (rename-out [memory-model-name model-name]
                     [memory-model-mnr  model-mnr]))

;; model ----------------------------------------------------------------
; a memory model consists of two parts:
; * a name
; * a must-not-reorder function

(struct memory-model (name mnr) #:transparent)

; an anonymous model
(define (make-model mnr [name #f]) (memory-model (or name 'anon) mnr))
