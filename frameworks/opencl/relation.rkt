#lang rosette

(require ocelot "model.rkt" "../../litmus/litmus-gpu.rkt")

(provide (all-defined-out))

;; Primitive relations

; read from
(define rf (declare-relation 2 "rf"))

; modification order
(define mo (declare-relation 2 "mo"))

; sequenced before
(define sb (declare-relation 2 "sb"))

; location: an equivalence relation over all events, relating events that access the same location
(define location (join loc (~ loc)))

; thd: an equivalence relation over all events, relating events from the same thread
(define thd (join proc (~ proc)))

; wg: an equivalence relation over all events, relating events from the same workgroup
(define wg (join scope (~ scope)))

; dv: an equivalence relation over all events, relating events from the same device
; (define dv (declare-relation 2 "dv"))


; Derived realtions

;; functions -------------------------------------------------------------------

(define (fr rf mo)
  (+ (join (~ rf) mo) (& (-> (- Reads (join Writes rf)) Writes) (join loc (~ loc)))))

(define (com rf mo)
  (+ rf mo (fr rf mo)))

(define (po_loc)
  (& po (join loc (~ loc))))

(define (po_loc_llh)
  (- (& po (join loc (~ loc))) (-> Reads Reads)))

(define (ghb rf mo ppo grf fence)
  (+ ppo mo (fr rf mo) grf fence))

; common relations used by memory models
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

