#lang rosette

(require ocelot "model.rkt" "../../litmus/litmus-gpu.rkt")

(provide (all-defined-out))

(define rf (declare-relation 2 "rf"))
(define ws (declare-relation 2 "ws"))

; Define derived realtions in this file

;; functions -------------------------------------------------------------------

(define (fr rf ws)
  (+ (join (~ rf) ws) (& (-> (- Reads (join Writes rf)) Writes) (join loc (~ loc)))))

(define (com rf ws)
  (+ rf ws (fr rf ws)))

(define (po_loc)
  (& po (join loc (~ loc))))

(define (po_loc_llh)
  (- (& po (join loc (~ loc))) (-> Reads Reads)))

(define (ghb rf ws ppo grf fence)
  (+ ppo ws (fr rf ws) grf fence))

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

