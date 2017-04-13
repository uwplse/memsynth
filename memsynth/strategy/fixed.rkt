#lang racket

(require "strategy.rkt" "../../litmus/litmus.rkt" ocelot
         racket/generator
         (prefix-in $ (only-in racket set)))
(provide make-fixed-strategy)


; The fixed strategy concretizes a litmus test sketch by fixing the
; number of operations on each thread, and fixing the type of each
; instruction on each thread.
(struct fixed-strategy (gen)
  #:methods gen:strategy
  [(define (next-topology self)
     ((fixed-strategy-gen self)))
   (define (instantiate-topology self sketch topo)
     (instantiate-sketch/topology sketch topo))])
 

; Initialize a new fixed strategy from a given litmus test sketch.
(define (make-fixed-strategy sketch)
  (match-define (litmus-test-sketch nthds nops _ syncs? lwsyncs? _ _ atomics?) sketch)
  (fixed-strategy (generate-all-topologies nthds nops syncs? lwsyncs? atomics?)))


; threads is a list of integers, whose length is the number of threads in the
; test, and each integer is the number of instructions on that thread.
; types is a list of symbols, the same length as threads, where each element
; is a list of event types
(struct litmus-test-topology (threads types) #:transparent)


; Generate a list of litmus-test-topology?s that iterate all possible topologies
; up to the given bounds on the number of threads and total operations.
; A litmus-test-topology? includes an assignment of operations to each thread,
; as well as the allowed number of writes on each thread, and whether the test
; should be allowed or disallowed by the concrete model (the polarity).
(define (generate-all-topologies nthds nops syncs? lwsyncs? atomics?)
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
  ; enumerate all event settings in the given topology
  (define (enumerate-events topo)
    (define insn-types '(read write))
    (when syncs?
      (set! insn-types (append insn-types '(sync))))
    (when lwsyncs?
      (set! insn-types (append insn-types '(lwsync))))
    (when atomics?
      (set! insn-types (append insn-types '(atomic))))
    (define num-insn-types (length insn-types))
    (define nops (apply + topo))
    (define nthds (length topo))
    (define start (for/list ([(t i) (in-indexed topo)]) (apply + (take topo i))))
    (define (valid-topology? t)  ; filter topos with syncs at start/end
      (for/and ([thd t]) (and (false? (member (first thd) '(sync lwsync)))
                              (false? (member (last thd) '(sync lwsync))))))
    (define-values (topos seen)
      (for/fold ([ret '()][seen ($set)]) ([i (in-range (sub1 (expt num-insn-types nops)) -1 -1)])
        (define res
          (for/list ([s start][t topo])
            (for/list ([j t])
              (list-ref insn-types (modulo (quotient i (expt num-insn-types (+ s j))) num-insn-types)))))
        (if (and (valid-topology? res) (not (set-member? seen (apply $set res))))
            (values (cons res ret) (set-add seen (apply $set res)))
            (values ret seen))))
    topos)
  (generator ()
    (for* ([ops (in-range 2 (add1 nops))]
           [thds (in-range 2 (add1 nthds))]
           [topo (enumerate-topologies thds ops)]
           [evts (enumerate-events topo)])
      (yield (litmus-test-topology topo evts)))
    #f))


; Create bounds corresponding to a litmus test sketch of the given topology.
(define (instantiate-sketch/topology sketch topo)
  (match-define (litmus-test-sketch _ _ nlocs _ _ deps? post? _) sketch)
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

  (define (event-bound type)
    (for*/list ([(tys tid) (in-indexed types)]
                [(t i) (in-indexed tys)]
                #:when (eq? t type))
      (list (list-ref ME-atoms (tid->id tid i)))))

  (define bWrite (make-exact-bound Writes (event-bound 'write)))
  (define bRead (make-exact-bound Reads (event-bound 'read)))
  (define bSync (make-exact-bound Syncs (event-bound 'sync)))
  (define bLwsync (make-exact-bound Lwsyncs (event-bound 'lwsync)))
  (define bAtomic (make-exact-bound Lwsyncs (event-bound 'atomic)))

  (define syncs (list->set (append (map car (event-bound 'sync)) (map car (event-bound 'lwsync)))))
  
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
          [upper (for*/list ([(m idx) (in-indexed ME-atoms)] #:unless (set-member? syncs m)
                             [i (take Int-atoms (min (+ idx 1 (if plus0? 1 0)) num-ints))])
                   (list m i))])
      (make-bound rel lower upper)))
  (define bLoc (event->int loc #f))
  (define bData (event->int data #t))

  ; the upper bound for Event ↦ Event relations breaks symmetries in a similar way:
  ; it effectively enforces an ordering on events to rule out permutations.
  (define PO (for*/list ([(t tid) (in-indexed topology)][e1 t][e2 (in-range (add1 e1) t)])
               (list (list-ref ME-atoms (tid->id tid e1)) (list-ref ME-atoms (tid->id tid e2)))))
  (define DP_u (for*/list ([(t tid) (in-indexed topology)][e1 t][e2 t] #:unless (= e1 e2))
                 (list (list-ref ME-atoms (tid->id tid e1)) (list-ref ME-atoms (tid->id tid e2)))))
  (define bPO (make-exact-bound po PO))
  (define bDP (make-upper-bound dp (if deps? DP_u '())))
  (define int->int (for*/list ([i1 Int-atoms][i2 Int-atoms]) (list i1 i2)))
  (define bFinalValue (make-upper-bound finalValue (if post? int->int '())))

  (bounds U (list bMemoryEvent bProc bLoc bData bPO bDP bFinalValue bRead bWrite bSync bLwsync bAtomic bInt bZero)))
