#lang racket

(require racket/generic)
(provide (all-defined-out))

; A MemSynth framework provides two methods:
; * `instantiate-execution` creates bounds on the variables used to define an
;   execution of the given litmus test
; * `allow` creates an AST corresponding to the framework's axioms for a given
;   memory model

(define-generics memsynth-framework
  (instantiate-execution memsynth-framework test-bounds)
  (allow memsynth-framework model))
