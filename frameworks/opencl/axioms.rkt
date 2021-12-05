#lang rosette

(require ocelot "relation.rkt" "../../litmus/litmus-gpu.rkt")

(provide (all-defined-out))

;; constraints -----------------------------------------------------------------

; rf: Write->Read
(define (WellFormed_rf rf)
  (and
   (in rf (& (-> AWrites AReads) (join addr (~ addr)) (join val (~ val))))
   (no (- (join rf (~ rf)) iden))
   (all ([r (- AReads (join AWrites rf))])
     (= (join r val) Zero))))

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

(define (Uniproc rf mo llh?)
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

(define (Acyclic rf mo ppo grf fence)
  (no (& (^ (ghb rf mo ppo grf fence)) iden))
)

(define (ValidExecution rf mo ppo grf fence)
  (and
    (WellFormed rf mo)            ; Execution
    (Uniproc rf mo)               ; Uniproc
    ; (Thin rf)                     ; Thin
    (Final mo)                    ; Final
    (Acyclic rf mo ppo grf fence) ; Acyclic
  )
)

;; ===============================

(define (irreflexive r)
  (no (& (^ r) iden))
)

; WellFormed Hb
(define (WellFormed_Hb mo rf)
  irreflexive((hb mo rf))
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
  irreflexive(input)
)

; WellFormed Rf
(define (WellFormed_Rf mo rf)
  (define input (join rf (hb mo rf)))
  (no (& (^ input) iden))
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
  irreflexive(input)
)

(define (AllowedExecution rf mo ppo grf fence)
  (and
    (WellFormed_Hb  mo rf)
    (WellFormed_Coh mo rf)
    (WellFormed_Rf  mo rf) 
    (WellFormed_RMW mo rf)

    (Final mo)                    ; Final
    ; (Acyclic rf mo ppo grf fence) ; Acyclic
  )
)