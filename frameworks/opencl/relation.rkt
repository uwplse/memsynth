#lang rosette

(require ocelot "../../litmus/sigs-gpu.rkt")

(provide (all-defined-out))


; ; loc: an equivalence relation over all events, relating events that access the same location
; (define loc (join addr (~ addr)))

; ; thd: an equivalence relation over all events, relating events from the same thread
; (define thd (join proc (~ proc)))

; ; wg : an equivalence relation over all events, relating events from the same workgroup
; (define wg (join scope (~ scope)))

;; functions -------------------------------------------------------------------

(define (fr rf mo)
  (+ (join (~ rf) mo) (& (-> (- Reads (join Writes rf)) Writes) (join loc (~ loc)))))

(define (com rf mo)
  (+ rf mo (fr rf mo)))

(define (po_loc)
  (& sb (join addr (~ addr))))

(define (ghb rf mo ppo grf fence)
  (+ ppo mo (fr rf mo) grf fence))

; common relations used by memory models
(define (rfi rf)  ; rf edges on the same processor
  (& rf (join proc (~ proc))))

(define (rfe rf)  ; rf edges not on the same processor
  (- rf (join proc (~ proc))))

(define SameAddr
  (prefab (lambda (k) (if (= k 2) '((1)) '()))
          (lambda (A) (& (-> A A) (join addr (~ addr))))))

; no fence-induced edges
(define ab-none (-> none none))

; all fence-induced edges
(define ab-all (^ (+ (<: Syncs sb) (:> sb Syncs))))

;; ===================

(define (rs mo)
  (define (rs_)
    (+
      thd
      (join univ (& (-> RMWs RMWs) iden))
    )
  )
  (-
    (& mo rs_)
    (join (- mo rs_) mo)
  )
)

(define (incl)
  (define (incl1)
    (+
      (join block (~ block) wg)
      (& (-> MemoryEvent MemoryEvent))
    )
  )
  (& incl1 (~ incl1))
)

(define (sw mo rf)
  (&
    (join
      (& (-> AWrites AWrites) iden)
      (+ (rs mo) iden)
      rf
      (& (-> AReads AReads) iden)
    )
    (- incl thd)
  )
)

(define (hb mo rf) 
  (^
    (+ sb (sw mo rf))
  )
)