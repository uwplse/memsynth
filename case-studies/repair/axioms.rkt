#lang rosette

(require ocelot 
         "../../litmus/litmus.rkt" 
         "../../frameworks/madorhaim/execution.rkt"
         "../../frameworks/alglave/models.rkt")

(provide (all-defined-out))


;; -----------------------------------------------------------------------------
;; This file is a direct copy of frameworks/madorhaim/axioms.rkt, except that
;; WellFormed_hb and Allowed take an extra argument "X" which is used to repair rule 5.
;; -----------------------------------------------------------------------------


(define sketch
  (expression-sketch 3 2 (list + - & -> SameAddr ~)
                         (list MemoryEvent Reads Writes po rf hb)))


; x is in the future of y
; "x > y" from the DAC'11 paper
(define (Future x y)
  (in (-> y x) po))

(define (WellFormed_rf rf)
  (and
    (no (& (~ po) rf))  ; cannot read from future writes
    (in rf (-> Writes Reads))
    (in rf (& (join loc (~ loc)) (join data (~ data))))
    (all ([r Reads])
      (and
        (lone (join rf r)) ; at most one write seen by a read
        (=> (no (join rf r))
            (= (join r data) Zero))))))  ; initial value if there is no write seen

(define (WellFormed_hb hb rf F)
  (and
   ; (1) program order
   (in (& F po) hb)

   ; (2) write-write
   (all ([w1 Writes][w2 Writes])
    (=> (= (join w1 loc) (join w2 loc))
        (or (in (-> w1 w2) hb) (in (-> w2 w1) hb))))

   ; (3) write-read
   (in (& rf (- (-> Writes Reads) (join proc (~ proc)))) hb)

   ; (4) read-write
   (in (- (- (& (-> Reads Writes) (join loc (~ loc))) (~ rf)) (~ (join hb rf))) hb)

   ; (5) ignore local  (PAPER BUG)
   (no (& (~ po) hb))
   ; (no sketch) ; try this

   ; partial order
   (in iden hb)  ; reflexive
   (in (& hb (~ hb)) iden)  ; antisymmetric
   (in (join hb hb) hb)))  ; transitive


(define (Allowed hb rf F)
  (and (WellFormed_rf rf)
       (WellFormed_hb hb rf F)
       (no (& (^ (- hb iden)) iden))))

