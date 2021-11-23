#lang racket

(require "strategy.rkt" "../../litmus/litmus.rkt" ocelot
         racket/generator)
(provide make-none-strategy)


; The none strategy concretizes nothing (i.e., there is only a single topology).
(struct none-strategy (gen)
  #:methods gen:strategy
  [(define (next-topology self)
     ((none-strategy-gen self)))
   (define (instantiate-topology self sketch topo)
     (instantiate-sketch/topology sketch topo))])
 

; Initialize a new write strategy from a given litmus test sketch.
(define (make-none-strategy sketch)
  (match-define (litmus-test-sketch nthds nops _ _ _ _ _ _) sketch)
  (none-strategy (generate-all-topologies nthds nops)))

(struct litmus-test-topology () #:transparent)


; Generate a list of litmus-test-topology?s that iterate all possible topologies
; up to the given bounds on the number of threads and total operations.
; A litmus-test-topology? includes an assignment of operations to each thread,
; as well as the allowed number of writes on each thread, and whether the test
; should be allowed or disallowed by the concrete model (the polarity).
(define (generate-all-topologies nthds nops)
  (generator ()
    (yield (litmus-test-topology))
    #f))


; Create bounds corresponding to a litmus test sketch of the given topology.
(define (instantiate-sketch/topology sketch topo)
  (match-define (litmus-test-sketch nthds nops nlocs syncs? lwsyncs? deps? post? atomics?) sketch)

  (define num-ints (max nthds nlocs))
  (define num-atoms (max nops num-ints))
  (define atoms (for/list ([i num-atoms]) (string->symbol (~v i))))
  (define ME-atoms (take atoms nops))
  (define Int-atoms (take atoms num-ints))
  (define U (universe atoms))

  (define bMemoryEvent (make-upper-bound MemoryEvent (for/list ([m1 ME-atoms]) (list m1))))
  (define bInt (make-exact-bound Int (for/list ([i Int-atoms]) (list i))))
  (define bZero (make-exact-bound Zero (list (list (first Int-atoms)))))

  (define Writes_u (for/list ([m1 ME-atoms]) (list m1)))
  (define bWrite (make-upper-bound Writes Writes_u))
  (define bAtomic (make-upper-bound Atomics (if atomics? Writes_u '())))

  (define bRead (make-upper-bound Reads (for/list ([m1 ME-atoms]) (list m1))))

  (define fences_u
    (for/list ([m1 ME-atoms]) (list m1)))
  (define bSync (make-upper-bound Syncs (if syncs? fences_u '())))
  (define bLwsync (make-upper-bound Lwsyncs (if lwsyncs? fences_u '())))

  ; the upper bound for Event ↦ Int relations contains symmetries which we can break.
  ; the idea is from Salor-Haim et al [CAV'10]:
  ; > We sort the addresses according to the order of their appearance in the program,
  ; > starting from T1 and continuing to the next thread after the end of each thread:
  ; > the first memory access in T1 is always to location 0, the next memory access
  ; > could either be to 0 again or to 1 and so on.
  ; we implement this symmetry breaking as a growing upper bound on the proc, loc, data
  ; relations. data is special because the first int atom is distinguished as 0.
  (define (event->int rel plus0?)
    (let ([lower (if plus0? '() (list (list (list-ref ME-atoms 0) (list-ref ME-atoms 0))))]
          [upper (for*/list ([(m idx) (in-indexed ME-atoms)]
                             [i (take Int-atoms (min (+ idx 1 (if plus0? 1 0)) num-ints))])
                   (list m i))])
      (make-bound rel lower upper)))
  (define bProc (event->int proc #f))
  (define bLoc (event->int loc #f))
  (define bData (event->int data #t))

  ; the upper bound for Event ↦ Event relations breaks symmetries in a similar way:
  ; it effectively enforces an ordering on events to rule out permutations.
  (define PO (for*/list ([e1 nops][e2 (in-range (add1 e1) nops)])
               (list (list-ref ME-atoms e1) (list-ref ME-atoms e2))))
  (define DP_u PO)
  (define bPO (make-upper-bound po PO))
  (define bDP (make-upper-bound dp (if deps? DP_u '())))
  (define int->int (for*/list ([i1 Int-atoms][i2 Int-atoms]) (list i1 i2)))
  (define bFinalValue (make-upper-bound finalValue (if post? int->int '())))

  (bounds U (list bMemoryEvent bProc bLoc bData bPO bDP bFinalValue bRead bWrite bSync bLwsync bAtomic bInt bZero)))
