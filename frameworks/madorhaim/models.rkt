#lang rosette

(require ocelot "model.rkt" "../../litmus/litmus.rkt")

(provide (all-from-out "model.rkt") vacuous TSO SC SameAddr)

;; common support for memory models --------------------------------------------

; define a new memory model with the given relation
(define-syntax-rule (define-model name mnr)
  (begin
    (provide name)
    (define name (memory-model (quote name) mnr))))

(define SameAddr
  (prefab (lambda (k) (if (= k 2) '((1)) '()))
          (lambda (A) (& (-> A A) (join loc (~ loc))))))

(define (SameAddr* A) ; given a set relation A, return the binary relation
  (& (-> A A) (join loc (~ loc))))


;; memory models ---------------------------------------------------------------

; sequential consistency
; F_SC = True
(define-model SC (-> univ univ))

; IBM370 allows reordering writes after reads, except to the same location
(define-model IBM370 (+ (& (-> Writes Reads) (SameAddr* MemoryEvent))
                        (-> Writes Writes)
                        (-> Reads MemoryEvent)
                        (-> Syncs MemoryEvent)
                        (-> MemoryEvent Syncs)))

; SPARC TSO allows reordering writes after reads
(define-model TSO (+ (-> Writes Writes)
                     (-> Reads MemoryEvent)
                     (-> Syncs MemoryEvent)
                     (-> MemoryEvent Syncs)))

; SPARC RMO allows all reorderings except fences, dependent instructions, and
; read/write instructions after a write to the same address
(define-model RMO (+ (& (-> Writes Writes) (SameAddr* MemoryEvent))
                     (& (-> Reads Writes) (+ (SameAddr* MemoryEvent) dp))
                     (& (-> Reads Reads) dp)
                     (-> Syncs MemoryEvent)
                     (-> MemoryEvent Syncs)))
; This is how RMO is defined in the paper. It is too strong -- it includes
; all dependencies, when RMO only protects read-read and read-write dependencies
(define-model RMO-paper (+ (& (-> MemoryEvent Writes) (SameAddr* MemoryEvent))
                           dp
                           (-> Syncs MemoryEvent)
                           (-> MemoryEvent Syncs)))

; vacuous model allows all reorderings
(define-model vacuous (-> none none))
