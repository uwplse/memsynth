#lang rosette

(require ocelot "../../litmus/litmus.rkt" "model.rkt")

(provide (all-defined-out))

;; functions -------------------------------------------------------------------

(define (fr rf ws)
  (+ (join (~ rf) ws) (& (-> (- Reads (join Writes rf)) Writes) (join loc (~ loc)))))

(define (com rf ws)
  (+ rf ws (fr rf ws)))

(define (po_loc)
  (& po (join loc (~ loc))))

(define (po_loc_llh)
  (- (& po (join loc (~ loc))) (-> Reads Reads)))

(define (ghb rf ws ppo grf ab)
  (+ ppo ws (fr rf ws) grf ab))

;; constraints -----------------------------------------------------------------

; rf: Write->Read
(define (WellFormed_rf rf)
  (and
   (in rf (& (-> Writes Reads) (join loc (~ loc)) (join data (~ data))))
   (no (- (join rf (~ rf)) iden))
   (all ([r (- Reads (join Writes rf))])
     (= (join r data) Zero))))

; ws: Write->Write
(define (WellFormed_ws ws)
  (and
   (in ws (& (-> Writes Writes) (join loc (~ loc))))
   (no (& iden ws))
   (in (join ws ws) ws)
   (all ([a Writes])
     (all ([b (- (& Writes (join loc (join a loc))) a)])  ; all disj a,b : Writes & (loc.~loc) | ...
       (or (in (-> a b) ws) (in (-> b a) ws))))
   (in ws (join loc (~ loc)))))

(define (WellFormed rf ws)
  (and
   (WellFormed_rf rf)
   (WellFormed_ws ws)))

(define (Uniproc rf ws llh?)
  (no (& (^ (+ (com rf ws) (if llh? (po_loc_llh) (po_loc)))) iden)))

(define (Thin rf)
  (no (& (^ (+ rf dp)) iden)))

(define (Final ws)
  (all ([w Writes])
    (=> (and (in w (- (join univ ws) (join ws univ))) (some (join (join w loc) finalValue)))
        (= (join w data) (join (join w loc) finalValue)))))

(define (Acyclic rf ws ppo grf ab)
  (no (& (^ (ghb rf ws ppo grf ab)) iden))
)

(define (ValidExecution rf ws ppo grf ab llh?)
  (and
    (WellFormed rf ws)          ; Execution
    (Uniproc rf ws llh?)        ; Uniproc
    (Thin rf)                   ; Thin
    (Final ws)                  ; Final
    (Acyclic rf ws ppo grf ab)  ; Acyclic
  )
)
