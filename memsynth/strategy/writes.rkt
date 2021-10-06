#lang racket

(require "strategy.rkt" "../../litmus/litmus.rkt" "../../ocelot/ocelot.rkt"
         racket/generator)
(provide make-writes-strategy)


; The writes strategy concretizes a litmus test sketch in two ways:
; * the thread topology (threads + operations per thread are fixed)
; * the number of writes on each thread is concrete
(struct writes-strategy (gen)
  #:methods gen:strategy
  [(define (next-topology self)
     ((writes-strategy-gen self)))
   (define (instantiate-topology self sketch topo)
     (instantiate-sketch/topology sketch topo))])
 

; Initialize a new write strategy from a given litmus test sketch.
(define (make-writes-strategy sketch)
  (match-define (litmus-test-sketch nthds nops _ _ _ _ _ _) sketch)
  (writes-strategy (generate-all-topologies nthds nops)))


; A litmus test topology is a pair, where
; * threads is a list of integers, whose length is the number of threads in the
;   test, and each integer is the number of instructions on that thread
; * writes is a list of integers with |writes| = |threads|, where each integer
;   is the number of write instructions on that thread, such that
;   writes[i] ≤ threads[i] for all i.
(struct litmus-test-topology (threads writes) #:transparent)


; Generate a list of litmus-test-topology?s that iterate all possible topologies
; up to the given bounds on the number of threads and total operations.
; A litmus-test-topology? includes an assignment of operations to each thread,
; as well as the allowed number of writes on each thread, and whether the test
; should be allowed or disallowed by the concrete model (the polarity).
(define (generate-all-topologies nthds nops)
  ; enumerate all topologies up to the given bounds
  (define (enumerate-topologies nthds nops)
    (sequence->list
     (in-generator
      (let loop ([t '()])
        (cond [(= (length t) nthds) (when (= (apply + t) nops)
                                      (yield t))]
              [else (let ([start (if (null? t) 1 (car t))]
                          [end (- nops (apply + t))])
                      (for ([i (in-range end (sub1 start) -1)])
                        (loop (cons i t))))])))))
  ; enumerate all writes in a given topology
  (define (enumerate-writes topo)
    (define nums (for/list ([t topo]) (range (add1 t))))
    (define used (mutable-set))
    (define (key o) (sort (for/list ([x o][t topo]) (cons x t)) < #:key car))
    (for/list ([o (apply cartesian-product nums)] #:unless (set-member? used (key o)))
      (set-add! used (key o))
      o))
  ; filter out topologies that will never do anything interesting (no reads/writes)
  (define (valid-topology? topo writes)
    (let ([s (apply + writes)])
      (not (or (= s 0) (= s (apply + topo))))))
  (generator ()
    (for* ([ops (in-range 2 (add1 nops))]
           [thds (in-range 2 (add1 nthds))]
           [topo (enumerate-topologies thds ops)]
           [writes (enumerate-writes topo)]
           #:when (valid-topology? topo writes))
      (yield (litmus-test-topology topo writes)))
    #f))


; Create bounds corresponding to a litmus test sketch of the given topology.
(define (instantiate-sketch/topology sketch topo)
  (match-define (litmus-test-sketch nthds nops nlocs syncs? lwsyncs? deps? post? atomics?) sketch)
  (match-define (litmus-test-topology topology writes) topo)

  (define num-ints (max (length topology) nlocs))
  (define num-atoms (max (apply + topology) num-ints))
  (define atoms (for/list ([i num-atoms]) (string->symbol (~v i))))
  (define ME-atoms (take atoms (apply + topology)))
  (define Int-atoms (take atoms (max num-ints (length topology))))
  (define U (universe atoms))

  (define (tid->id tid i)
    (+ (apply + (take topology tid)) i))

  (define bMemoryEvent (make-exact-bound MemoryEvent (for/list ([m1 ME-atoms]) (list m1))))
  (define bInt (make-exact-bound Int (for/list ([i Int-atoms]) (list i))))
  (define bZero (make-exact-bound Zero (list (list (first Int-atoms)))))

  ; The first t events on each thread are writes.
  (define Write_ids (for*/list ([(t tid) (in-indexed writes)][i (in-range t)])
                       (tid->id tid i)))
  (define Write_u (for/list ([id Write_ids]) (list (list-ref ME-atoms id))))
  (define bWrite (make-exact-bound Writes Write_u))
  (define bAtomic (make-upper-bound Atomics (if atomics? Write_u '())))

  ; The set of all events that must be writes
  (define Write_set (list->set Write_ids))
  ; The set of all events that must not be writes
  (define Read/Barrier_set
    (set-subtract (for*/set ([(t tid) (in-indexed topology)][i (in-range t)])
                    (tid->id tid i))
                  Write_set))
  ; The upper bound for reads and barriers
  (define Read/Barrier_u (for/list ([id (sort (set->list Read/Barrier_set) <)])
                           (list (list-ref ME-atoms id))))
  (define bRead (make-upper-bound Reads Read/Barrier_u))
  (define bSync (make-upper-bound Syncs (if syncs? Read/Barrier_u '())))
  (define bLwsync (make-upper-bound Lwsyncs (if lwsyncs? Read/Barrier_u '())))

  (define bProc (make-exact-bound proc (for*/list ([(t tid) (in-indexed topology)][i t])
                                   (list (list-ref ME-atoms (tid->id tid i)) (list-ref Int-atoms tid)))))

  ; the upper bound for Event ↦ Int relations contains symmetries which we can break.
  ; the idea is from Salor-Haim et al [CAV'10]:
  ; > We sort the addresses according to the order of their appearance in the program,
  ; > starting from T1 and continuing to the next thread after the end of each thread:
  ; > the first memory access in T1 is always to location 0, the next memory access
  ; > could either be to 0 again or to 1 and so on.
  ; we implement this symmetry breaking as a growing upper bound on the proc, loc, data
  ; relations. data is special because the first int atom is distinguished as 0.
  (define (event->int rel plus0?)
    (let ([lower (if plus0? '() (list (list (list-ref ME-atoms 0) (list-ref Int-atoms 0))))]
          [upper (for*/list ([(m idx) (in-indexed ME-atoms)]
                             [i (take Int-atoms (min (+ idx 1 (if plus0? 1 0)) num-ints))])
                   (list m i))])
      (make-bound rel lower upper)))
  (define bLoc (event->int loc #f))
  (define bData (event->int data #t))

  ; the upper bound for Event ↦ Event relations breaks symmetries in a similar way:
  ; it effectively enforces an ordering on events to rule out permutations.
  (define PO_u (for*/list ([(t tid) (in-indexed topology)][e1 t][e2 t] #:unless (= e1 e2))
                 (list (list-ref ME-atoms (tid->id tid e1)) (list-ref ME-atoms (tid->id tid e2)))))
  (define DP_u (for*/list ([(t tid) (in-indexed topology)][e1 t][e2 t]
                           #:unless (or (= e1 e2) (set-member? Write_set (tid->id tid e1))))
                 (list (list-ref ME-atoms (tid->id tid e1)) (list-ref ME-atoms (tid->id tid e2)))))
  (define bPO (make-upper-bound po PO_u))
  (define bDP (make-upper-bound dp (if deps? DP_u '())))
  (define int->int (for*/list ([i1 Int-atoms][i2 Int-atoms]) (list i1 i2)))
  (define bFinalValue (make-upper-bound finalValue (if post? int->int '())))

  (bounds U (list bMemoryEvent bProc bLoc bData bPO bDP bFinalValue bRead bWrite bSync bLwsync bAtomic bInt bZero)))
