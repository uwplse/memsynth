#lang racket

(require "relation.rkt" "../../litmus/sigs-gpu.rkt" ocelot
         (rename-in (only-in racket set) [set $set]))
(provide (all-defined-out))

;; ================================================
;; Relations used to constraint candidate execution
;; rf, mo, sc ⊂ Event x Event
;; ================================================

; read from
(define rf (declare-relation 2 "rf"))

; modification order
(define mo (declare-relation 2 "mo"))

; sequential consistency order
(define sc (declare-relation 2 "sc"))

; Instantiate an execution given a set of (possibly symbolic) bounds for a litmus test.
; An execution is two relations rf : Write->Read and mo : Write->Write.
; a model M allows a test T if there exists an execution that satisfies the
; ValidExecution predicate.
(define (make-execution bnds) ; bnds: bounds of litmus test
  (define areads  (get-upper-bound bnds AReads))
  (define awrites (get-upper-bound bnds AWrites))
  (define rmws    (get-upper-bound bnds RMWs))
  (define zero    (first (first (get-upper-bound bnds Zero))))

  ; map events to set of addrs they can touch
  (define addr-ts (get-upper-bound bnds addr))
  (define event->addrs
    (for/fold ([ret (hash)]) ; initialize value ret
      ([el addr-ts])         ; for clause: <gid, addr> pair
      (hash-set ret 
        (first el)           ; key: gid
        (set-add (hash-ref ret (first el) $set) (second el)) ; value
      )
    )
  )
  (define (addrs t) (hash-ref event->addrs (first t)))  ; lookup function
  ; map events to set of values they read/write
  (define val-ts (get-upper-bound bnds val))
  (define event->vals
    (for/fold ([ret (hash)]) ; initialize value ret
      ([el val-ts])          ; for clause: <gid, value> pair
      (hash-set ret 
        (first el)           ; key: gid
        (set-add (hash-ref ret (first el) $set) (second el))
      )
    )
  )
  (define (vals t) (hash-ref event->vals (first t)))  ; lookup function
  ; map addrs to their possible final values
  (define fv-ts (get-upper-bound bnds finalValue))
  (define addr->fv
    (for/fold ([ret (hash)]) ; initialize value ret
      ([el fv-ts])           ; for clause: <gid, addr> pair
      (hash-set ret 
        (first el)           ; key: gid
        (set-add (hash-ref ret (first el) $set) (second el))
      )
    )
  )
  (define (fvs l) (hash-ref addr->fv l ($set)))
  ; map (addr, val) pairs to set of all write events that can generate that pair
  (define lv->writes
    (for*/fold ([ret (hash)]); initialize value ret
      ([(w ls) event->addrs] 
        #:when (member (list w) awrites)
        [v (hash-ref event->vals w '())] ; if hash-ref failed return '()
        [l ls]
      )
      (hash-set ret 
        (cons l v)           ; key: gid
        (set-add (hash-ref ret (cons l v) $set) w)
      )
    )
  )
  (define (lvws addr val) (hash-ref lv->writes (cons addr val) '()))  ; lookup function
  ; initialize all address (e.g. X, Y) to zero
  (define (writes-visible event)
    (let ([actual (for*/set ([addr (addrs event)][val (vals event)][w (lvws addr val)]) w)])
      (if (set-member? (vals event) zero) 
          (set-add actual 'init) 
          actual
      )
    )
  )

  ; create bounds for rf ⊂ (addr.~addr) & (val.~val) : same address with same value
  (define rf_U (for*/list ([w awrites][r areads]
                           #:when (and (not (set-empty? (set-intersect (addrs w) (addrs r))))
                                       (not (set-empty? (set-intersect (vals w) (vals r))))))
                 (list (first w) (first r))))
  (define rf_L (for*/list ([r areads] #:when (and (= (set-count (writes-visible r)) 1)
                                                 (not (eq? (set-first (writes-visible r)) 'init))))
                 (list (set-first (writes-visible r)) (first r))))
  (define brf (make-bound rf rf_L rf_U))

  ; create bounds for mo ⊂ (addr.~addr)-iden
  ; we also handle finalValues here:
  ;  all disj a,b: Write { addr[a] = addr[b] and data[a] = finalValue[addr[a]] and data[b] != finalValue[addr[b]]
  ;                         => a->b not in mo }
  ;  in other words,
  ;  we must allow w1->w2 ∈ mo if there is some location that w2 can write to that either
  ;  has no finalValue (so any value is allowed) or that has a finalValue w2 can write.
  (define mo_U (for*/list ([w1 awrites][w2 awrites]
                           #:when (and (not (set-empty? (set-intersect (addrs w1) (addrs w2))))
                                       (not (equal? w1 w2))
                                       (for/or ([l (addrs w2)])  ; if there is some addration w2 can write ...
                                         (or (set-empty? (fvs l))  ; that either has no finalValue
                                             (not (set-empty? (set-intersect (vals w2) (fvs l))))))))  ; or has a finalValue w2 can write
                 (list (first w1) (first w2))))
  ; if only one write event w can write the final value to a given location,
  ; then every write event that definitely awrites to that same location must
  ; happen before w
  (define mo_L (for*/list ([w1 awrites] #:when (and (= (set-count (addrs w1)) 1)
                                                  (= (set-count (vals w1)) 1)
                                                  (equal? (fvs (set-first (addrs w1))) (vals w1)))
                           [w2 awrites] #:when (and (not (equal? w1 w2)) (equal? (addrs w1) (addrs w2))))
                 (list (first w2) (first w1))))
  (define bmo (make-bound mo mo_L mo_U))

  (bounds (bounds-universe bnds) (list brf bmo))
)
