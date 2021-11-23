#lang rosette

(require racket/require
         (multi-in "../../../frameworks/opencl" ("models.rkt" "sketch-model.rkt"))
         ocelot
         "../../../litmus/litmus.rkt")
(provide uhd630-sketch)

(define rf (declare-relation 2 "rf"))


;; Creates a PowerPC sketch, in which ppo/grf/fences all have depth 4.

(define ppo (make-ppo-sketch 4 (list + - -> & SameAddr)
                               (list po dp MemoryEvent Reads Writes)))
(define grf (make-grf-sketch 4 (list + - -> & SameAddr)
                               (list rfi rfe none univ)))
(define ab-sync (make-ab-sketch 4 (list + join <: :>)
                                  (list rf Writes Reads (join (:> po Syncs) po))))
; Note that `ab` is the name the code uses for `fences` in the paper.
(define ab-lwsync (make-ab-sketch 4 (list + join <: :>)
                                    (list rf Writes Reads (& (join (:> po Lwsyncs) po) (+ (-> Writes Writes) (-> Reads MemoryEvent))))))
(define ab (+ ab-sync ab-lwsync))

(define uhd630-sketch (make-model ppo grf ab))


;; Count the size of the search space defined by the sketch

(module+ main
  (printf "UHD630 search space: 2^~v\n" (length (symbolics uhd630-sketch))))
