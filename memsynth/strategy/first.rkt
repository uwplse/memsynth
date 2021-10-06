#lang racket

(require "strategy.rkt" "../../litmus/litmus.rkt" "../../ocelot/ocelot.rkt"
         racket/generator)
(provide make-first-strategy)


; The first strategy concretizes a litmus test sketch by fixing the
; number of operations on each thread, and fixing the type of the first
; instruction on each thread.
(struct first-strategy (gen)
  #:methods gen:strategy
  [(define (next-topology self)
     ((first-strategy-gen self)))
   (define (instantiate-topology self sketch topo)
     (instantiate-sketch/topology sketch topo))])
 

; Initialize a new write strategy from a given litmus test sketch.
(define (make-first-strategy sketch)
  (match-define (litmus-test-sketch nthds nops _ _ _ _ _ _) sketch)
  (first-strategy (generate-all-topologies nthds nops)))


; threads is a list of integers, whose length is the number of threads in the
; test, and each integer is the number of instructions on that thread.
; types is a list of symbols, the same length as threads, where each element
; is either 'read or 'write
(struct litmus-test-topology (threads types) #:transparent)


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
  (generator ()
    (for* ([ops (in-range 2 (add1 nops))]
           [thds (in-range 2 (add1 nthds))]
           [topo (enumerate-topologies thds ops)]
           [type (apply cartesian-product (make-list thds (list 'read 'write)))])
      (yield (litmus-test-topology topo type)))
    #f))


; Create bounds corresponding to a litmus test sketch of the given topology.
(define (instantiate-sketch/topology sketch topo)
  (match-define (litmus-test-sketch nthds nops nlocs syncs? lwsyncs? deps? post? atomics?) sketch)
  (match-define (litmus-test-topology topology types) topo)

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

  (define Reads_l (for/list ([tid (length topology)]
                             [type types]
                             #:when (eq? type 'read))
                    (list (list-ref ME-atoms (tid->id tid 0)))))
  (define Writes_l (for/list ([tid (length topology)]
                             [type types]
                             #:when (eq? type 'write))
                    (list (list-ref ME-atoms (tid->id tid 0)))))
  (define Reads_u (for/list ([m1 ME-atoms] #:unless (member (list m1) Writes_l))
                    (list m1)))
  (define Writes_u (for/list ([m1 ME-atoms] #:unless (member (list m1) Reads_l))
                     (list m1)))
  (define bWrite (make-bound Writes Writes_l Writes_u))
  (define bAtomic
    (if atomics? (make-bound Atomics Writes_l Writes_u)
                 (make-exact-bound Atomics '())))
  (define bRead (make-bound Reads Reads_l Reads_u))
  
  (define fences_u
    (for*/list ([(t tid) (in-indexed topology)]
                [i (in-range t)]
                #:when (and (< 0 i) (< i (sub1 t))))
      (list (list-ref ME-atoms (tid->id tid i)))))
  (define bSync (make-upper-bound Syncs (if syncs? fences_u '())))
  (define bLwsync (make-upper-bound Lwsyncs (if lwsyncs? fences_u '())))
  
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
    (let ([lower (if plus0? '() (list (list (list-ref ME-atoms 0) (list-ref ME-atoms 0))))]
          [upper (for*/list ([(m idx) (in-indexed ME-atoms)]
                             [i (take Int-atoms (min (+ idx 1 (if plus0? 1 0)) num-ints))])
                   (list m i))])
      (make-bound rel lower upper)))
  (define bLoc (event->int loc #f))
  (define bData (event->int data #t))

  ; the upper bound for Event ↦ Event relations breaks symmetries in a similar way:
  ; it effectively enforces an ordering on events to rule out permutations.
  (define PO (for*/list ([(t tid) (in-indexed topology)][e1 t][e2 (in-range (add1 e1) t)])
               (list (list-ref ME-atoms (tid->id tid e1)) (list-ref ME-atoms (tid->id tid e2)))))
  (define DP_u PO)
  (define bPO (make-exact-bound po PO))
  (define bDP (make-upper-bound dp (if deps? DP_u '())))
  (define int->int (for*/list ([i1 Int-atoms][i2 Int-atoms]) (list i1 i2)))
  (define bFinalValue (make-upper-bound finalValue (if post? int->int '())))

  (bounds U (list bMemoryEvent bProc bLoc bData bPO bDP bFinalValue bRead bWrite bAtomic bSync bLwsync bInt bZero)))
