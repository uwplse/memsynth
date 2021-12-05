#lang rosette

(require "lang-gpu.rkt" 
         (only-in ocelot
                  declare-relation make-exact-bound bounds universe))
(provide (all-defined-out))

;; Defines the signatures for the relations that make up a litmus test, and a
;; procedure to convert a litmus-test? to bounds on these relations

; An execution is a tuple X = (E, I, lbl, thd, wg, sb)

;  event: MemoryEvent
(define MemoryEvent (declare-relation 1 "MemoryEvent"))
;  block: <MemoryEvent, Workgroup>
(define block (declare-relation 2 "block"))
;  proc: <MemoryEvent, Thread>
(define proc (declare-relation 2 "proc"))
;  addr: <MemoryEvent, Address>
(define addr (declare-relation 2 "addr"))
;  val: <MemoryEvent, Value>
(define val (declare-relation 2 "val"))
;  finalValue: <Address, Value>
(define finalValue (declare-relation 2 "finalValue"))

;  loc: <MemoryEvent, <MemoryEvent>
(define loc (declare-relation 2 "loc"))
;  wg : <MemoryEvent, MemoryEvent>
(define wg (declare-relation 2 "wg"))
;  thd: <MemoryEvent, MemoryEvent>
(define thd (declare-relation 2 "thd"))
;  sb : <MemoryEvent, MemoryEvent>
(define sb (declare-relation 2 "sb"))


;; ============
;; Event labels
;; ============
; abstract sig Read extends MemoryEvent
(define Reads (declare-relation 1 "Reads"))
; abstract sig Write extends MemoryEvent
(define Writes (declare-relation 1 "Writes"))
; abstract sig Sync extends MemoryEvent
(define Syncs (declare-relation 1 "Syncs"))
; abstract sig RMW extends MemoryEvent
(define RMWs (declare-relation 1 "RMWs"))
; abstract sig Atomic Read extends Read
(define AReads (declare-relation 1 "AReads"))
; abstract sig Atomic Write extends Write
(define AWrites (declare-relation 1 "AWrites"))

; sig Int
(define Int (declare-relation 1 "Int"))
; one sig Zero extends Int
(define Zero (declare-relation 1 "Zero"))


; Instantiate a litmus-test? as bounds on the above relations.
(define (instantiate-test T)
  (define-values (P post num-ints) (canonicalize-program T))
  (define events (all-events P))
  (define num-events (length events))
  (define num-atoms (max num-events num-ints))
  (define atoms (for/list ([i num-atoms]) (string->symbol (~v i))))

  (define ME-atoms (take atoms num-events))
  (define Int-atoms (take atoms num-ints))
  (define U (universe atoms))
  (define MEs (for/list ([me ME-atoms]) (list me)))

  (define bMemoryEvent (make-exact-bound MemoryEvent MEs))
  (define bBlock
    (make-exact-bound block (for/list ([a events])
                              (list (list-ref ME-atoms (Event-gid a))
                                    (list-ref Int-atoms (Event-wgid a))
                              )
                            )
    )
  )
  (define bProc
    (make-exact-bound proc (for/list ([a events])
                              (list (list-ref ME-atoms (Event-gid a))
                                    (list-ref Int-atoms (Event-tid a))
                              )
                            )
    )
  )
  (define bAddr
    (make-exact-bound addr (for/list ([a events] #:unless (Fence? a))
                              (list (list-ref ME-atoms (Event-gid a))
                                    (list-ref Int-atoms (Event-addr a))
                              )
                          )
    )
  )
  (define bVal
    (make-exact-bound val (for/list ([a events] #:unless (Fence? a))
                              (list (list-ref ME-atoms (Event-gid a))
                                    (list-ref Int-atoms (Event-val a))
                              )
                            )
    )
  )
  (define bLoc
    (make-exact-bound loc (for*/list ([a events][b events]
                               #:when (= (Event-addr a) (Event-addr b)))
                              (list (list-ref ME-atoms (Event-gid a)) 
                                    (list-ref ME-atoms (Event-gid b))
                              )
                          )
    )
  )
  (define bWG
        (make-exact-bound wg (for*/list ([a events][b events]
                               #:when (= (Event-wgid a) (Event-wgid b)))
                              (list (list-ref ME-atoms (Event-gid a)) 
                                    (list-ref ME-atoms (Event-gid b))
                              )
                          )
    )
  )
  (define bThd
    (make-exact-bound thd (for*/list ([a events][b events]
                               #:when (= (Event-tid a) (Event-tid b)))
                              (list (list-ref ME-atoms (Event-gid a)) 
                                    (list-ref ME-atoms (Event-gid b))
                              )
                          )
    )
  )
  (define bSB
    (make-exact-bound sb (for*/list ([a events][b events]
                               #:when (and (= (Event-tid a) (Event-tid b))
                                            (< (Event-lid a) (Event-lid b))))
                              (list (list-ref ME-atoms (Event-gid a)) 
                                    (list-ref ME-atoms (Event-gid b))
                              )
                          )
    )
  )
  (define bfinalValue
    (make-exact-bound finalValue (for/list ([AV post])
                                    (list (list-ref Int-atoms (car AV)) 
                                          (list-ref Int-atoms (cdr AV))
                                    )
                                  )
    )
  )
  (define bRead
    (make-exact-bound Reads (for/list ([a events] #:when (Read? a)) (list (list-ref ME-atoms (Event-gid a))))))
  (define bWrite
    (make-exact-bound Writes (for/list ([a events] #:when (Write? a)) (list (list-ref ME-atoms (Event-gid a))))))
  (define bSync
    (make-exact-bound Syncs (for/list ([a events] #:when (and (Fence? a) (eq? (Fence-type a) 'sync)))
                        (list (list-ref ME-atoms (Event-gid a))))))
  (define bRMW
    (make-exact-bound RMWs (for/list ([a events] #:when (RMW? a)) 
                              (list (list-ref ME-atoms (Event-gid a))))))
  (define bARead
    (make-exact-bound AReads  (for/list ([a events] #:when (or (ARead? a) (and (RMW? a) (RMW-r/w a)))) 
                                  (list (list-ref ME-atoms (Event-gid a)))
                              )
    )
  )
  (define bAWrite
    (make-exact-bound AWrites (for/list ([a events] #:when (or (AWrite? a) (and (RMW? a) (not (RMW-r/w a))))) 
                                  (list (list-ref ME-atoms (Event-gid a)))
                              )
    )
  )
  (define bInt (make-exact-bound Int (for/list ([i Int-atoms]) (list i))))
  (define bZero (make-exact-bound Zero (list (list (first Int-atoms)))))

  (bounds U (list bMemoryEvent bBlock bProc bAddr bVal bLoc bWG bThd bSB bfinalValue bRead bWrite bSync bRMW bARead bAWrite bInt bZero)))


; Canonicalize a litmus test so that it can be represented as relations.
; Each address and value are canonicalized to integers.
(define (canonicalize-program T)
  (define P (litmus-test-program T))
  ; create a map of locations -> integers
  (define all-addrs
    (remove-duplicates
     (for*/list ([WG (Program-workgroups P)][proc (WorkGroup-threads WG)][a (Thread-events proc)] #:unless (Fence? a)) (Event-addr a))))
  (when (null? all-addrs)
    (set! all-addrs '(0)))
  (define addrs
    (for/hash ([(addr i) (in-indexed all-addrs)]) (values addr i)))
  ; create a map of values -> integers
  ; we must ensure 0 is in the map and is first, because it is used for initial values
  (define all-values
    (remove-duplicates
     (for*/list ([WG (Program-workgroups P)][proc (WorkGroup-threads WG)][a (Thread-events proc)] #:unless (Fence? a)) (Event-val a))))
  (set! all-values (append (list 0) (remove 0 all-values)))
  (define vals
    (for/hash ([(v i) (in-indexed all-values)]) (values v i)))
  (define thd_num 0)
  ; rewrite the program with integer locations and values
  (define P*
    (Program
      (for/list ([wg (Program-workgroups P)])
        (WorkGroup
          (for/list ([proc (WorkGroup-threads wg)])
            (begin0
              (Thread (Thread-wgid proc) (Thread-tid proc)
                (for/list ([a (Thread-events proc)])
                  (match a
                    [(ARead gid wgid tid lid addr val)        (ARead  gid wgid tid lid  (hash-ref addrs addr) (hash-ref vals val))]
                    [(AWrite gid wgid tid lid addr val)       (AWrite gid wgid tid lid  (hash-ref addrs addr) (hash-ref vals val))]
                    [(RMW gid wgid tid lid  addr val r/w)     (RMW   gid wgid tid lid  (hash-ref addrs addr) (hash-ref vals val) r/w)]
                    [(Read  gid wgid tid lid  addr val)       (Read  gid lid tid  (hash-ref addrs addr) (hash-ref vals val))]
                    [(Write gid wgid tid lid  addr val)       (Write gid lid tid  (hash-ref addrs addr) (hash-ref vals val))]
                    [(Fence gid wgid tid lid  addr val type)  (Fence gid lid tid  (first all-addrs) (hash-ref vals 0) type)]
                  )
                )
              )
              (set! thd_num (add1 thd_num))
            )
          )
        )
      )
    )
  )
  ; the number of integers required
  (define num-ints  (max (hash-count addrs) thd_num (hash-count vals)))
  ; rewrite the test's postcondition using the addrs map
  (define post (for/list ([AV (litmus-test-post T)])
                 (cons (hash-ref addrs (first AV)) 
                       (hash-ref vals (second AV)))))
  (values P* post num-ints)
)
