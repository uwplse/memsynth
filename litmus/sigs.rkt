#lang s-exp "../rosette/rosette/main.rkt"

(require "lang.rkt" 
         (only-in "../ocelot/ocelot.rkt" 
                  declare-relation make-exact-bound bounds universe))
(provide (all-defined-out))

;; Defines the signatures for the relations that make up a litmus test, and a
;; procedure to convert a litmus-test? to bounds on these relations

; abstract sig MemoryEvent {
(define MemoryEvent (declare-relation 1 "MemoryEvent"))
;  proc: Int
(define proc (declare-relation 2 "proc"))
;  loc: Int
(define loc (declare-relation 2 "loc"))
;  data: Int
(define data (declare-relation 2 "data"))
;  po: set MemoryEvent
(define po (declare-relation 2 "po"))
;  dp: set MemoryEvent
(define dp (declare-relation 2 "dp"))
; }
; abstract sig Location {
;   finalValue: int
(define finalValue (declare-relation 2 "finalValue"))
; }
; abstract sig Read extends MemoryEvent
(define Reads (declare-relation 1 "Reads"))
; abstract sig Write extends MemoryEvent
(define Writes (declare-relation 1 "Writes"))
; abstract sig Sync extends MemoryEvent
(define Syncs (declare-relation 1 "Syncs"))
; abstract sig Lwsync extends MemoryEvent
(define Lwsyncs (declare-relation 1 "Lwsyncs"))
; abstract sig Atomic extends Write
(define Atomics (declare-relation 1 "Atomics"))
; sig Int
(define Int (declare-relation 1 "Int"))
; one sig Zero extends Int
(define Zero (declare-relation 1 "Zero"))


; Instantiate a litmus-test? as bounds on the above relations.
(define (instantiate-test T)
  (define-values (P post min-ints) (canonicalize-program T))
  (define actions (all-actions P))
  (define num-events (length actions))
  (define num-ints min-ints)
  (define num-atoms (max num-events num-ints))
  (define atoms (for/list ([i num-atoms]) (string->symbol (~v i))))

  (define ME-atoms (take atoms num-events))
  (define Int-atoms (take atoms num-ints))
  (define U (universe atoms))
  (define MEs (for/list ([me ME-atoms]) (list me)))

  (define bMemoryEvent (make-exact-bound MemoryEvent MEs))
  (define bProc
    (make-exact-bound proc (for/list ([a actions]) (list (list-ref ME-atoms  (Action-gid a))
                                                   (list-ref Int-atoms (Action-thd a))))))
  (define bLoc
    (make-exact-bound loc (for/list ([a actions] #:unless (Fence? a)) (list (list-ref ME-atoms (Action-gid a))
                                                  (list-ref Int-atoms (Action-addr a))))))
  (define bData
    (make-exact-bound data (for/list ([a actions] #:unless (Fence? a)) (list (list-ref ME-atoms (Action-gid a))
                                                   (list-ref Int-atoms (Action-val a))))))
  (define bPO
    (make-exact-bound po (for*/list ([a actions][b actions]
                               #:when (and (= (Action-thd a) (Action-thd b))
                                            (< (Action-lid a) (Action-lid b))))
                     (list (list-ref ME-atoms (Action-gid a)) (list-ref ME-atoms (Action-gid b))))))
  (define bDP
    (make-exact-bound dp (for*/list ([a actions][b actions]
                               #:when (and (= (Action-thd a) (Action-thd b))
                                            (member (Action-lid a) (Action-deps b))))
                     (list (list-ref ME-atoms (Action-gid a)) (list-ref ME-atoms (Action-gid b))))))
  (define bfinalValue
    (make-exact-bound finalValue (for/list ([AV post])
                             (list (list-ref Int-atoms (car AV)) (list-ref Int-atoms (cdr AV))))))
  (define bRead
    (make-exact-bound Reads (for/list ([a actions] #:when (Read? a)) (list (list-ref ME-atoms (Action-gid a))))))
  (define bWrite
    (make-exact-bound Writes (for/list ([a actions] #:when (Write? a)) (list (list-ref ME-atoms (Action-gid a))))))
  (define bSync
    (make-exact-bound Syncs (for/list ([a actions] #:when (and (Fence? a) (eq? (Fence-type a) 'sync)))
                        (list (list-ref ME-atoms (Action-gid a))))))
  (define bLwsync
    (make-exact-bound Lwsyncs (for/list ([a actions] #:when (and (Fence? a) (eq? (Fence-type a) 'lwsync)))
                          (list (list-ref ME-atoms (Action-gid a))))))
  (define bAtomic
    (make-exact-bound Atomics (for/list ([a actions] #:when (Atomic? a)) (list (list-ref ME-atoms (Action-gid a))))))
  (define bInt (make-exact-bound Int (for/list ([i Int-atoms]) (list i))))
  (define bZero (make-exact-bound Zero (list (list (first Int-atoms)))))

  (bounds U (list bMemoryEvent bProc bLoc bData bPO bDP bfinalValue bRead bWrite bSync bLwsync bAtomic bInt bZero)))


; Canonicalize a litmus test so that it can be represented as relations.
; Each address and value are canonicalized to integers.
(define (canonicalize-program T)
  (define P (litmus-test-program T))
  ; create a map of addresses -> integers
  (define all-locs
    (remove-duplicates
     (for*/list ([thd (Program-threads P)][a (Thread-actions thd)] #:unless (Fence? a)) (Action-addr a))))
  (when (null? all-locs)
    (set! all-locs '(0)))
  (define locs
    (for/hash ([(loc i) (in-indexed all-locs)]) (values loc i)))
  ; create a map of values -> integers
  ; we must ensure 0 is in the map and is first, because it is used for initial values
  (define all-values
    (remove-duplicates
     (for*/list ([thd (Program-threads P)][a (Thread-actions thd)] #:unless (Fence? a)) (Action-val a))))
  (set! all-values (append (list 0) (remove 0 all-values)))
  (define vals
    (for/hash ([(v i) (in-indexed all-values)]) (values v i)))
  ; rewrite the program with integer addresses and values
  (define P*
    (Program
     (for/list ([thd (Program-threads P)])
       (Thread (Thread-tid thd)
        (for/list ([a (Thread-actions thd)])
          (match a
            [(Read  gid lid tid deps addr val)      (Read  gid lid tid deps (hash-ref locs addr) (hash-ref vals val))]
            [(Atomic gid lid tid deps addr val)     (Atomic gid lid tid deps (hash-ref locs addr) (hash-ref vals val))]
            [(Write gid lid tid deps addr val)      (Write gid lid tid deps (hash-ref locs addr) (hash-ref vals val))]
            [(Fence gid lid tid deps addr val type) (Fence gid lid tid deps (first all-locs) (hash-ref vals 0) type)]))))))
  ; the number of integers required
  (define num-ints (max (hash-count locs) (length (Program-threads P*)) (hash-count vals)))
  ; rewrite the test's postcondition using the locs map
  (define post (for/list ([AV (litmus-test-post T)])
                 (cons (hash-ref locs (first AV)) (hash-ref vals (second AV)))))
  (values P* post num-ints))
