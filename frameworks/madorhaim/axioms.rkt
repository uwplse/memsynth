#lang rosette

(require ocelot "../../litmus/litmus.rkt" "model.rkt")

(provide (all-defined-out))

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
   ; (all ([e1 MemoryEvent][e2 MemoryEvent])
   ;  (=> (and (in (-> e1 e2) F) (Future e2 e1))
   ;      (in (-> e1 e2) hb)))
   ; alternative encoding without quantifiers:
   (in (& F po) hb)

   ; (2) write-write
   (all ([w1 Writes][w2 Writes])
    (=> (= (join w1 loc) (join w2 loc))
        (or (in (-> w1 w2) hb) (in (-> w2 w1) hb))))

   ; (3) write-read
   ; (all ([x Writes][y Reads])
   ;  (=> (and (in (-> x y) rf) (not (= (join x proc) (join y proc))))
   ;      (in (-> x y) hb)))
   ; alternative encoding without quantifiers:
   (in (& rf (- (-> Writes Reads) (join proc (~ proc)))) hb)

   ; (4) read-write
   ; (all ([x Reads][y Writes])
   ;  (=> (and (not (in (-> y x) rf))
   ;           (= (join x loc) (join y loc))
   ;           (not (some ([z Writes])
   ;                 (and (in (-> z x) rf) (in (-> y z) hb)))))
   ;      (in (-> x y) hb)))
   ; alternative encoding without quantifiers:
   (in (- (- (& (-> Reads Writes) (join loc (~ loc))) (~ rf)) (~ (join hb rf))) hb)

   ; (5) ignore local  (PAPER BUG)
   ; paper says:
   ; (all ([x MemoryEvent][y MemoryEvent])
   ;   (=> (Future x y) (not (in (-> x y) hb))))
   ; but this is too strong.
   ; instead, restrict only to writes:
   ; (all ([x Reads][y Writes])
   ;   (=> (Future x y) (not (in (-> x y) hb))))
   ; alternative encoding without quantifiers:
   ; (no (& (& (-> Reads Writes) (~ po)) hb))
   ; repaired version generated from demos/repair.rkt
   (no (& (~ (& (- po rf) (-> Writes Reads))) hb))

   ; partial order
   (in iden hb)  ; reflexive
   (in (& hb (~ hb)) iden)  ; antisymmetric
   (in (join hb hb) hb)))  ; transitive

(define (Allowed hb rf F)
  (and (WellFormed_rf rf)
       (WellFormed_hb hb rf F)
       (no (& (^ (- hb iden)) iden))))
