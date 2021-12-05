#lang rosette

(require "lang-gpu.rkt" "sigs-gpu.rkt"
         ocelot)
(provide (all-defined-out))


; A litmus test sketch consists of
; * a bound on the number of threads `threads`
; * a bound on the total number of instructions `ops`
; * a bound on the number of memory locations `locs`
; * three booleans:
;   - barriers? indicates whether the sketch allowed fence instructions
;   - deps? indicates whether the sketch allows dependencies
;   - post? indicates whether the sketch allows post-conditions
(struct litmus-test-sketch (threads ops locs syncs? lwsyncs? deps? post? atomics?) #:transparent)


; Given a universe, an interpretation (hash from relations to matrices),
; and a Rosette solution object,
; construct an instance of litmus-test? corresponding to the given relations.
(define (relations->litmus-test interp)
  (define evts (hash-ref interp MemoryEvent))
  (define (binary-rel->hash rel)
    (let ([lookup (for/hash ([pair (hash-ref interp rel)])
                    (values (list (car pair)) (cdr pair)))])
      (values lookup (sort (remove-duplicates (hash-values lookup)) symbol<? #:key car))))
  (define (binary-rel->hash* rel) (for/fold ([ret (hash)]) ([pair (hash-ref interp rel)])
                                    (let ([key (list (car pair))])
                                      (hash-set ret key (cons (cdr pair) (hash-ref ret key '()))))))

  (define-values (evt->proc procs) (binary-rel->hash proc))
  (define-values (evt->loc locs) (binary-rel->hash loc))
  (define-values (evt->val vals) (binary-rel->hash val))
  (unless (memq '(|0|) vals) ; 0 is special and can't be used as an arbitrary value
    (set! vals (cons '(|0|) vals)))
  (define evt->po (binary-rel->hash* sb))

  (define evts-in-po (sort evts > #:key (lambda (e) (length (hash-ref evt->po e '())))))
  (define proc->evts
    (for/hash ([p procs])
      (values p (filter (lambda (e) (eq? (hash-ref evt->proc e) p)) evts-in-po))))
  (define evt->lid
    (for*/hash ([(p es) proc->evts][(e lid) (in-indexed es)]) (values e lid)))

  (define loc->addr
    (for/hash ([(l i) (in-indexed locs)])
      (values l (string->symbol (string (integer->char (+ 65 i)))))))
  (define val->int
    (for/hash ([(v i) (in-indexed vals)])
      (values v i)))

  (define gid 0)
  (define P
    (Program
     (for/list ([(p tid) (in-indexed procs)])
       (Thread
        tid
        (for/list ([e (hash-ref proc->evts p)])
          (define lid (hash-ref evt->lid e))
          (define addr (hash-ref loc->addr (hash-ref evt->loc e (first locs))))
          (define val (hash-ref val->int (hash-ref evt->val e (first vals))))
          (begin0
            (cond [(member e (hash-ref interp Reads))
                   (Read gid lid tid addr val)]
                  ; [(member e (hash-ref interp Atomics))
                  ;  (Atomic gid lid tid deps addr val)]
                  [(member e (hash-ref interp Writes))
                   (Write gid lid tid addr val)]
                  [(member e (hash-ref interp Syncs))
                   (Fence gid lid tid addr val 'sync)]
                  ; [(member e (hash-ref interp Lwsyncs))
                  ;  (Fence gid lid tid deps addr val 'lwsync)]
                  [else (error 'evaluate-sketch "no type for op ~v" e)])
            (set! gid (add1 gid))))))))

  (define-values (loc->final finals) (binary-rel->hash finalValue))
  (define post
    (for/list ([(loc val) loc->final])
      (list (hash-ref loc->addr loc) (hash-ref val->int val))))

  (litmus-test 'T P post '()))


; Construct a well-formedness axiom for a litmus test sketch
(define (WellFormedProgram sketch #:conflicts? [conflicts? #t])
  (match-define (litmus-test-sketch _ _ _ syncs? lwsyncs? deps? post? atomics?) sketch)
  (and
   ; MemoryEvents are partitioned into four sigs
   (no (& Reads (+ Writes Syncs)))
   (no (& Writes (+ Reads Syncs)))
   (no (& Syncs (+ Reads Writes)))
  ;  (no (& Lwsyncs (+ Reads Writes Syncs)))
  ;  (if atomics?
      ;  (in Atomics Writes)
      ;  (no Atomics))
   (cond 
        ; [(and syncs? lwsyncs?)
        ;   (= (+ Reads Writes Syncs Lwsyncs) MemoryEvent)]
        [syncs?
          (= (+ Reads Writes Syncs) MemoryEvent)]
        ;  [lwsyncs?
        ;   (= (+ Reads Writes Lwsyncs) MemoryEvent)]
        [else
          (= (+ Reads Writes) MemoryEvent)])
   ; each MemoryEvent has exactly one proc
   (all ([m MemoryEvent])
     (one (join m proc)))
   ; reads and writes have exactly one loc and val
   (all ([m (+ Reads Writes)])
     (and (one (join m loc)) (one (join m val))))
   ; fences have no loc and no val
  ;  (no (join (+ Syncs Lwsyncs) loc))
  ;  (no (join (+ Syncs Lwsyncs) val))
   ; writes shouldn't use the initialization value
   (not (in Zero (join Writes val)))
   ; val ⊂ thd(proc.~proc) is transitive and irreflexive
   (in sb (join proc (~ proc)))
   (in (join val val) val)
   (no (& iden val))
   ; val is a linear order on each processor
   (all ([m1 MemoryEvent][m2 MemoryEvent])
     (or (= m1 m2)
         (=> (= (join m1 proc) (join m2 proc))
             (or (in (-> m1 m2) val) (in (-> m2 m1) val)))))
  ;  ; dep ⊂ po
  ;  (no (& iden dep))
  ;  ; only writes and reads can depend on reads; no other evts have deps
  ;  (in dep (& po (-> Reads (+ Reads Writes))))
  ;  ; at most one dep per event
  ;  (all ([e MemoryEvent]) (lone (join dep e)))
   ; finalValue assigns at most one value to each addr, and does not invent
   ; values out of thin air, and is not redundant
   (if post?
       (all ([i Int])
         (or (no (join i finalValue))
             (and (one (join i finalValue))
                  (in (join i finalValue) (join (<: Writes (join loc i)) val))
                  (some (- (join (<: Writes (join loc i)) val) (join i finalValue))))))
       (no finalValue))
   ; eliminate some redundancies: a variable used by only one thread is useless
   (all ([i Int])
     (or (no (join loc i))
         (and (not (one (join (join loc i) proc)))
              (some (& (join loc i) Reads))
              (some (& (join loc i) Writes)))))
   ; more redundancies: Mador-Haim's "conflict graph", modified to support barriers
   (if conflicts?
       (in MemoryEvent MemoryEvent)
       (in (-> (+ Writes Reads) (+ Writes Reads)) (^ (+ sb (- (join loc (~ loc)) (-> Reads Reads))))))
   ))
