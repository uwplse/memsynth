#lang racket

(require "sigs.rkt" ocelot)
(provide litmus-type-constraints)


; Constraints that convey type information about litmus test relations
(define (litmus-type-constraints #:atomics? [atomics? #t] #:syncs? [syncs? #t] #:lwsyncs? [lwsyncs? #t])
  (and
   (no (& MemoryEvent Int))
   (cond
     [(and syncs? lwsyncs?)
      (and
       (no (& Reads (+ Writes Syncs Lwsyncs)))   ; we don't need the disjointness conditions inside
       (no (& Writes (+ Reads Syncs Lwsyncs)))   ; the (cond ...), but they will save the simplifier
       (no (& Syncs (+ Reads Writes Lwsyncs)))   ; from instantiating Syncs/Lwsyncs unnecessarily
       (no (& Lwsyncs (+ Reads Writes Syncs)))
       (= (+ Reads Writes Syncs Lwsyncs) MemoryEvent))]
     [syncs?
      (and
       (no (& Reads (+ Writes Syncs)))
       (no (& Writes (+ Reads Syncs)))
       (no (& Syncs (+ Reads Writes)))
       (= (+ Reads Writes Syncs) MemoryEvent))]
     [lwsyncs?
      (and
       (no (& Reads (+ Writes Lwsyncs)))
       (no (& Writes (+ Reads Lwsyncs)))
       (no (& Lwsyncs (+ Reads Writes)))
       (= (+ Reads Writes Lwsyncs) MemoryEvent))]
     [else
      (and
       (no (& Reads Writes))
       (= (+ Reads Writes) MemoryEvent))])
   (if atomics?
       (in Atomics Writes)
       (in Writes Writes))
   (in po (-> MemoryEvent MemoryEvent))
   (in dp (-> MemoryEvent MemoryEvent))
   (in proc (-> MemoryEvent Int))
   (in loc (-> MemoryEvent Int))
   (in data (-> MemoryEvent Int))
   (let ([rf (declare-relation 2 "rf")])
     (in rf (& (-> Writes Reads) (join loc (~ loc)) (join data (~ data)))))))
