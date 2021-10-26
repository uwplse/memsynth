#lang s-exp "../../rosette/rosette/main.rkt"

(require "models.rkt" "../../litmus/litmus.rkt"
         "../../ocelot/ocelot.rkt"
         "../../rosette/rosette/lib/angelic.rkt")

(provide (all-defined-out))

(define (trivial-sketch . models)
  (apply choose* models))

(define (make-ppo-sketch depth ops terminals)
  (& po (expression-sketch depth 2 ops terminals)))

(define (make-grf-sketch depth ops terminals)
  (let* ([rf (declare-relation 2 "rf")]
        [terminals (append (for/list ([t terminals])
                             (if (procedure? t) (t rf) t))
                           (list rf))])
    (& rf (expression-sketch depth 2 ops terminals))))

(define (make-ab-sketch depth ops terminals)
  (expression-sketch depth 2 ops terminals))
