#lang racket

(require racket/generic)
(provide (all-defined-out))

; A strategy defines an approach to concretizing a litmus test sketch.
(define-generics strategy
  ; Return the next topology from this strategy. The topology should be treated
  ; as an opaque object and is passed to instantiate-topology to create a set of
  ; litmus test bounds.
  (next-topology strategy)

  ; Given a litmus test sketch and a topology returned from next-topology,
  ; create a set of bounds describing a litmus test to solve for.
  (instantiate-topology strategy sketch topology))
