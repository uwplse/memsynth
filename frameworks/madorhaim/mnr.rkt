#lang rosette

(require ocelot "model.rkt" "framework.rkt"
         "../../litmus/litmus.rkt"
         rosette/lib/angelic
         (prefix-in $ racket))

(provide (all-defined-out))


; A must-not-reorder function is a four digit number in base 5.
; For example, SC is "4444" while RMO is "1010".
;
; Each digit specifies when reorderings are allowed for a particular pair of
; operations, as follows:
;   Digit 0: read-read operations
;   Digit 1: read-write operations
;   Digit 2: write-read operations
;   Digit 3: write-write operations
;
; The value of each digit specifies which reorderings are forbidden on operations
; of that pair:
;   0: nothing forbidden -- reordering always allowed
;   1: forbidden if same addresses
;   2: forbidden if data dependencies
;   3: forbidden if same addresses or data dependencies
;   4: always forbidden -- reordering never allowed


; Domains for each part of the model
(define domains
  (list #| 0 |# (-> Reads Reads)
        #| 1 |# (-> Reads Writes)
        #| 2 |# (-> Writes Reads)
        #| 3 |# (-> Writes Writes)))

; Subsets of univ->univ forbidden by each value of a digit
(define forbidden
  (list #| 0 |# (-> none none)
        #| 1 |# (join loc (~ loc))
        #| 2 |# dp
        #| 3 |# (+ (join loc (~ loc)) dp)
        #| 4 |# (-> univ univ)))


; Take as input a model number (in decimal) and return the corresponding
; memory-model? instance.
; For example, if num=4444, then returns SC.
(define (model-number->model num)
  (make-model
   (+ (for/fold ([ret (-> none none)]) ([i 4][dom domains])
        (let* ([val (remainder (quotient num (expt 10 i)) 10)]
               [ran (list-ref forbidden val)])
          (+ (& dom ran) ret)))
      (-> Syncs MemoryEvent)
      (-> MemoryEvent Syncs))
   (~r num #:min-width 4 #:pad-string "0")))


; Produce a *sketch* of a must-not-reorder function.
; The input is four lists that specify which digits are allowed for each
; position in the must-not-reorder functions.
; For example:
;   (model-number-sketch '(0) '(1) '(2) '(3 4))
; allows two models 0123 and 0124.
(define (model-number-sketch ww wr rw rr)
  (define ranges (list rr rw wr ww))
  (make-model
   (+ (for/fold ([ret (-> none none)]) ([dom domains][ran ranges])
        (+ (& dom (apply choose* (map (curry list-ref forbidden) ran)))
           ret))
      (-> Syncs MemoryEvent)
      (-> MemoryEvent Syncs))))


; The "default" sketch rules out certain redundancies (from §4.2):
; (1) Reordering read-write and write-write with the same address violates
;     single-thread consistency and therefore we do not consider them
; (2) There is no need to consider dependencies for write-read and write-write
(define madorhaim-90-allowed
  '((1 4)          ; write-write
    (0 1 4)        ; write-read
    (1 3 4)        ; read-write
    (0 1 2 3 4)))  ; read-read
(define (madorhaim-sketch)
  (apply model-number-sketch madorhaim-90-allowed))


; A valid model number is a four digit number in base 5
(define (valid-model-number? n)
  ($and (<= n 4444) (for/and ([i 4]) (<= (remainder (quotient n (expt 10 i)) 10) 4))))


; Check if a model number is one of the paper's 90 models from §4.2
(define (madorhaim-90-allowed? n)
  (for/and ([i 4])
    (member (remainder (quotient n (expt 10 i)) 10)
            (list-ref madorhaim-90-allowed ($- 3 i)))))

; Check if a model is one of the paper's models from Fig 4, which is the set of 90
; models but ignoring data depdendences
(define (madorhaim-fig4-allowed? n)
  ($and (madorhaim-90-allowed? n)
        (for/and ([i 4]) (let ([d (remainder (quotient n (expt 10 i)) 10)])
                           ($not ($or ($= d 2) ($= d 3)))))))
