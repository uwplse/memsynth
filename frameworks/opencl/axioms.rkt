#lang rosette

(require ocelot "relation.rkt" "../../litmus/litmus-gpu.rkt")

(provide (all-defined-out))

;; constraints -----------------------------------------------------------------

; rf: Write->Read
(define (WellFormed_rf rf)
  (and
   (in rf (& (-> Writes Reads) (join loc (~ loc)) (join data (~ data))))
   (no (- (join rf (~ rf)) iden))
   (all ([r (- Reads (join Writes rf))])
     (= (join r data) Zero))))

; mo: Write->Write
(define (WellFormed_mo mo)
  (and
   (in mo (& (-> Writes Writes) (join loc (~ loc))))
   (no (& iden mo))
   (in (join mo mo) mo)
   (all ([a Writes])
     (all ([b (- (& Writes (join loc (join a loc))) a)])  ; all disj a,b : Writes & (loc.~loc) | ...
       (or (in (-> a b) mo) (in (-> b a) mo))))
   (in mo (join loc (~ loc)))))

(define (WellFormed rf mo)
  (and
   (WellFormed_rf rf)
   (WellFormed_mo mo)))

(define (Uniproc rf mo llh?)
  (no (& (^ (+ (com rf mo) (if llh? (po_loc_llh) (po_loc)))) iden)))

(define (Thin rf)
  (no (& (^ (+ rf dep)) iden)))

(define (Final mo)
  (all ([w Writes])
    (=> (and (in w (- (join univ mo) (join mo univ))) (some (join (join w loc) finalValue)))
        (= (join w data) (join (join w loc) finalValue)))))

(define (Acyclic rf mo ppo grf fence)
  (no (& (^ (ghb rf mo ppo grf fence)) iden))
)

(define (ValidExecution rf mo ppo grf fence llh?)
  (and
    (WellFormed rf mo)            ; Execution
    (Uniproc rf mo llh?)          ; Uniproc
    (Thin rf)                     ; Thin
    (Final mo)                    ; Final
    (Acyclic rf mo ppo grf fence) ; Acyclic
  )
)
