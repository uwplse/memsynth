#lang s-exp "../../rosette/rosette/main.rkt"

(require "../../litmus/litmus.rkt" "../../ocelot/ocelot.rkt"
         (rename-in (only-in racket set) [set $set]))
(provide (all-defined-out))

(define rf (declare-relation 2 "rf"))
(define hb (declare-relation 2 "hb"))


; an execution is two relations rf : Write->Read and hb : MemoryEvent->MemoryEvent
; a model M allows a test T if there exists an execution that satisfies the
; Allowed predicate.
(define (make-execution bnds)
  (define mes (get-upper-bound bnds MemoryEvent))
  (define reads (get-upper-bound bnds Reads))
  (define writes (get-upper-bound bnds Writes))

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

  ; create bounds for rf ⊂ (loc.~loc) & (val.~val)
  (define WR_l (for*/list ([w writes][r reads]
                           #:when (and (not (set-empty? (set-intersect (locs w) (locs r))))
                                       (not (set-empty? (set-intersect (vals w) (vals r))))))
                 (list (first w) (first r))))
  (define brf (make-upper-bound rf WR_l))

  ; create bounds for HB that include the identity relation
  (define iden (for/list ([m1 mes]) (append m1 m1)))
  (define univ->univ (for*/list ([m1 mes][m2 mes]) (append m1 m2)))
  (define bhb (make-bound hb iden univ->univ))

  (bounds (bounds-universe bnds) (list brf bhb)))
