#lang rosette

(require ocelot "relation.rkt" "../../litmus/sigs-gpu.rkt")

(provide (all-defined-out))

;; constraints -----------------------------------------------------------------

; rf: Write->Read
(define (WellFormed_rf rf)
  (and
   (in rf (& (-> AWrites AReads) (join addr (~ addr)) (join val (~ val))))
   (no (- (join rf (~ rf)) iden))
  )
)

; mo: Write->Write
(define (WellFormed_mo mo)
  (and
   (in mo (& (-> AWrites AWrites) (join addr (~ addr))))
   (no (& iden mo))
   (in (join mo mo) mo)
   (all ([a AWrites])
     (all ([b (- (& AWrites (join addr (join a addr))) a)])  ; all disj a,b : Writes & (loc.~loc) | ...
       (or (in (-> a b) mo) (in (-> b a) mo))))
   (in mo (join addr (~ addr)))))

(define (WellFormed rf mo)
  (and
   (WellFormed_rf rf)
   (WellFormed_mo mo)))

(define (Uniproc rf mo)
  (define input 
    (+ (com rf mo) (po_loc))
  )
  (no (& (^ input) iden))
)

; (define (Thin rf)
;   (no (& (^ (+ rf dep)) iden)))

(define (Final mo)
  (all ([w Writes])
    (=> (and (in w (- (join univ mo) (join mo univ))) (some (join (join w addr) finalValue)))
        (= (join w val) (join (join w addr) finalValue)))))

(define (Acyclic rf mo)
  (no (& (^ (ghb rf mo)) iden))
)

;; ===============================

; WellFormed Hb
(define (WellFormed_Hb mo rf)
  (define input (hb mo rf ))
  (no (& input iden))
)

; WellFormed Coh
(define (WellFormed_Coh mo rf)
  (define input
    (join
      (+ (~ rf) iden)
      mo 
      (+ rf iden)
      (hb mo rf)
    )
  )
  (no (& input iden))
)

; WellFormed Rf
(define (WellFormed_Rf mo rf)
  (define input (join rf (hb mo rf)))
  (no (& input iden))
)

; WellFormed RMW
(define (WellFormed_RMW mo rf)
  (define input 
    (+
      rf
      (join mo mo (~ rf))
      (join mo rf)
    )
  )
  (no (& input iden))
)

(define (Non-faultiness mo rf)
  (no (dr mo rf))
)

(define (WellFormed_init rf)
  (all ([r (- AReads (join AWrites rf))])
     (= (join r val) Zero))
)

(define (WellFormed_execution mo rf)
  (and
   (WellFormed_rf rf)
   (WellFormed_mo mo)
  )
)

(define (WellFormed_final mo)
  (all ([w AWrites])
    (=> (and (in w (- (join univ mo) (join mo univ))) (some (join (join w addr) finalValue)))
        (= (join w val) (join (join w addr) finalValue)))
  )
)

(define (Coh_with_holes mo rf X)
  ; (define input
  ;   (join
  ;     (+ (~ rf) iden)
  ;     mo 
  ;     (+ rf iden)
  ;     X
  ;   )
  ; )
  ; (define input 
  ;   (+ (com rf mo) (po_loc))
  ; )
  (no (& (^ X) iden))
)

(define (AllowedExecution rf mo X)
  (and
    ; (WellFormed_Hb  mo rf)
    ; (WellFormed_Coh mo rf)
    ; (WellFormed_Rf  mo rf) 
    ; (WellFormed_RMW mo rf)
    ; (Non-faultiness mo rf)

    ; (Uniproc rf mo)
    (WellFormed_init rf)
    (WellFormed_execution mo rf)
    (WellFormed_final mo)
    (Acyclic rf mo)

    (Coh_with_holes mo rf X)
  )
)