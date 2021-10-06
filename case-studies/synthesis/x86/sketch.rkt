#lang rosette

(require racket/require
         (multi-in "../../../frameworks/alglave" ("models.rkt" "sketch-model.rkt"))
         "../../../ocelot/ocelot.rkt"
         "../../../litmus/litmus.rkt")
(provide x86-sketch)

(define rf (declare-relation 2 "rf"))


;; Creates an x86 sketch, in which ppo/grf have depth 4 and fences has depth 0.
(define ppo (make-ppo-sketch 4 (list + - -> & SameAddr)
                               (list po MemoryEvent Reads Writes Syncs Atomics)))
(define grf (make-grf-sketch 4 (list + - -> & SameAddr)
                               (list rf rfi rfe none univ)))
(define ab (-> none none))

(define x86-sketch (make-model ppo grf ab))


;; Count the size of the search space defined by the sketch

(module+ main
  (printf "x86 search space: 2^~v\n" (length (symbolics x86-sketch))))
