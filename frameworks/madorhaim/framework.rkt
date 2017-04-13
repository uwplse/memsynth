#lang racket

(require "../../memsynth/memsynth.rkt" "axioms.rkt" "execution.rkt" "model.rkt")
(provide mador-haim (all-from-out "../../memsynth/memsynth.rkt"))

(struct mador-haim-framework ()
  #:methods gen:memsynth-framework
  [(define (instantiate-execution f test)
     (make-execution test))
   (define (allow f M)
     (match-define (memory-model _ F) M)
     (Allowed hb rf F))])

(define mador-haim (mador-haim-framework))
