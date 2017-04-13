#lang rosette

(require ocelot "model.rkt" "../../litmus/litmus.rkt")

(provide rfi rfe SameAddr (all-from-out "model.rkt"))

;; common support for memory models --------------------------------------------

; define a new memory model with the given relations
(define-syntax define-model
  (syntax-rules ()
    [(_ name ppo grf ab llh?)
     (begin
       (provide name)
       (define name (memory-model (quote name) ppo grf ab llh?)))]
    [(_ name ppo grf ab)
     (define-model name ppo grf ab #f)]))

; common relations used by memory models
(define rf (declare-relation 2 "rf"))
(define (rfi rf)  ; rf edges on the same processor
  (& rf (join proc (~ proc))))
(define (rfe rf)  ; rf edges not on the same processor
  (- rf (join proc (~ proc))))
(define SameAddr
  (prefab (lambda (k) (if (= k 2) '((1)) '()))
          (lambda (A) (& (-> A A) (join loc (~ loc))))))

; no fence-induced edges
(define ab-none (-> none none))
; all fence-induced edges
(define ab-all (^ (+ (<: Syncs po) (:> po Syncs))))


;; memory models ---------------------------------------------------------------

; sequential consistency
(define ppo-SC po)
(define grf-SC rf)
(define-model SC ppo-SC grf-SC ab-none)

; total store order (x86, not IBM370)
(define ppo-TSO
  (- po (-> (- Writes Atomics) Reads)))
(define grf-TSO (rfe rf))
(define-model TSO ppo-TSO grf-TSO ab-none)

; partial store order
(define ppo-PSO (& po (-> Reads MemoryEvent)))
(define grf-PSO (rfe rf))
(define-model PSO ppo-PSO grf-PSO ab-none)

; Alpha
(define ppo-Alpha (& po (& (join loc (~ loc)) (-> Reads Reads))))
(define grf-Alpha (rfe rf))
(define-model Alpha ppo-Alpha grf-Alpha ab-none)

; relaxed memory order
(define ppo-RMO (& po dp))
(define grf-RMO (rfe rf))
(define-model RMO ppo-RMO grf-RMO ab-all #t)

; PowerPC
(define ppo-ppc (& po dp))
(define grf-ppc (-> none none))
(define ab-sync
  (let ([sync (join (:> po Syncs) po)])
    (^ (+ (+ sync (join sync rf)) (join rf sync)))))
(define ab-lwsync
  (let ([lwsync (& (join (:> po Lwsyncs) po) (+ (-> Writes Writes) (-> Reads MemoryEvent)))])
    (^ (+ (+ lwsync (:> (join rf lwsync) Writes)) (<: Reads (join lwsync rf))))))
(define ab-ppc (+ ab-sync ab-lwsync))
(define-model PPC ppo-ppc grf-ppc ab-ppc)

; vacuous model that allows all reordering
(define ppo-vacuous (-> none none))
(define grf-vacuous (-> none none))
(define-model vacuous ppo-vacuous grf-vacuous ab-none #t)
