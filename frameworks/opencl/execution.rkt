#lang racket

(require "derived.rkt" "../../litmus/litmus-gpu.rkt" ocelot
         (rename-in (only-in racket set) [set $set]))
(provide (all-defined-out))

; Instantiate an execution given a set of (possibly symbolic) bounds for a litmus test.
; An execution is two relations rf : Write->Read and ws : Write->Write.
; a model M allows a test T if there exists an execution that satisfies the
; ValidExecution predicate.
(define (make-execution bnds)
  (define reads (get-upper-bound bnds Reads))
  (define writes (get-upper-bound bnds Writes))
  (define zero (first (first (get-upper-bound bnds Zero))))

  ; map events to set of locs they can touch
  (define loc-ts (get-upper-bound bnds loc))
  (define event->locs
    (for/fold ([ret (hash)]) ([el loc-ts])
      (hash-set ret (first el) (set-add (hash-ref ret (first el) $set) (second el)))))
  (define (locs t) (hash-ref event->locs (first t)))  ; lookup function
  ; map events to set of values they read/write
  (define val-ts (get-upper-bound bnds data))
  (define event->vals
    (for/fold ([ret (hash)]) ([el val-ts])
      (hash-set ret (first el) (set-add (hash-ref ret (first el) $set) (second el)))))
  (define (vals t) (hash-ref event->vals (first t)))  ; lookup function
  ; map locs to their possible final values
  (define fv-ts (get-upper-bound bnds finalValue))
  (define loc->fv
    (for/fold ([ret (hash)]) ([el fv-ts])
      (hash-set ret (first el) (set-add (hash-ref ret (first el) $set) (second el)))))
  (define (fvs l) (hash-ref loc->fv l ($set)))
  ; map (loc, val) pairs to set of all write events that can generate that pair
  (define lv->writes
    (for*/fold ([ret (hash)]) ([(w ls) event->locs] #:when (member (list w) writes)
                               [v (hash-ref event->vals w '())]
                               [l ls])
      (hash-set ret (cons l v) (set-add (hash-ref ret (cons l v) $set) w))))
  (define (writes-visible r)
    (let ([actual (for*/set ([l (locs r)][v (vals r)][w (hash-ref lv->writes (cons l v) '())])
                    w)])
      (if (set-member? (vals r) zero) (set-add actual 'init) actual)))

  ; create bounds for rf ⊂ (loc.~loc) & (val.~val)
  (define rf_U (for*/list ([w writes][r reads]
                           #:when (and (not (set-empty? (set-intersect (locs w) (locs r))))
                                       (not (set-empty? (set-intersect (vals w) (vals r))))))
                 (list (first w) (first r))))
  (define rf_L (for*/list ([r reads] #:when (and (= (set-count (writes-visible r)) 1)
                                                 (not (eq? (set-first (writes-visible r)) 'init))))
                 (list (set-first (writes-visible r)) (first r))))
  (define brf (make-bound rf rf_L rf_U))

  ; create bounds for ws ⊂ (loc.~loc)-iden
  ; we also handle finalValues here:
  ;  all disj a,b: Write { loc[a] = loc[b] and data[a] = finalValue[loc[a]] and data[b] != finalValue[loc[b]]
  ;                         => a->b not in ws }
  ;  in other words,
  ;  we must allow w1->w2 ∈ ws if there is some location that w2 can write to that either
  ;  has no finalValue (so any value is allowed) or that has a finalValue w2 can write.
  (define ws_U (for*/list ([w1 writes][w2 writes]
                           #:when (and (not (set-empty? (set-intersect (locs w1) (locs w2))))
                                       (not (equal? w1 w2))
                                       (for/or ([l (locs w2)])  ; if there is some location w2 can write ...
                                         (or (set-empty? (fvs l))  ; that either has no finalValue
                                             (not (set-empty? (set-intersect (vals w2) (fvs l))))))))  ; or has a finalValue w2 can write
                 (list (first w1) (first w2))))
  ; if only one write event w can write the final value to a given location,
  ; then every write event that definitely writes to that same location must
  ; happen before w
  (define ws_L (for*/list ([w writes] #:when (and (= (set-count (locs w)) 1)
                                                  (= (set-count (vals w)) 1)
                                                  (equal? (fvs (set-first (locs w))) (vals w)))
                           [w2 writes] #:when (and (not (equal? w w2)) (equal? (locs w) (locs w2))))
                 (list (first w2) (first w))))
  (define bws (make-bound ws ws_L ws_U))

  (bounds (bounds-universe bnds) (list brf bws)))
