#lang rosette

(require ocelot "model.rkt" "relation.rkt" "execution.rkt" "../../litmus/litmus-gpu.rkt")

;; common support for memory models --------------------------------------------

; define a new memory model with the given relations
(define-syntax define-model
  (syntax-rules ()
    [(_ name ppo grf ab llh?)
     (begin
       (provide name)
       (define name (memory-model (quote name) ppo grf ab llh?)))]
    [(_ name ppo grf ab)
     (define-model name ppo grf ab #f)]
  )
)

;; memory models ---------------------------------------------------------------

; sequential consistency
(define ppo-SC sb)
(define grf-SC rf)
(define-model SC ppo-SC grf-SC ab-none)

; partial store order
(define ppo-PSO (& sb (-> Reads MemoryEvent)))
(define grf-PSO (rfe rf))
(define-model PSO ppo-PSO grf-PSO ab-none)

; Alpha
(define ppo-Alpha (& sb (& (join loc (~ loc)) (-> Reads Reads))))
(define grf-Alpha (rfe rf))
(define-model Alpha ppo-Alpha grf-Alpha ab-none)

; vacuous model that allows all reordering
(define ppo-vacuous (-> none none))
(define grf-vacuous (-> none none))
(define-model vacuous ppo-vacuous grf-vacuous ab-none #t)
