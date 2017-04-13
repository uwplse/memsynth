#lang racket

(provide (all-defined-out))


(struct litmus-file (name cpu content pre globals insns post) #:transparent)


(define (string-index str chr)
  (for/first ([c str][i (in-naturals)] #:when (eq? c chr)) i))


;; Parse a .litmus file into a litmus-file struct.
;; Does not model the actual assembly semantics -- that's a job
;; for the compiler.
(define (parse-litmus-test s)
  (define content (string-copy s))

  ; find the title
  (match-define (list cpu name)
    (let ([n (string-index s #\newline)])
      (begin0
        (string-split (substring s 0 n))
        (set! s (string-trim (substring s (+ n 1)))))))

  ; find the initialization
  (define init (make-hash))
  (define mem (make-hash))
  (let ([n (string-index s #\{)])
    (set! s (string-trim (substring s (+ n 1)))))
  (let loop ()
    (unless (eq? (string-ref s 0) #\})
      (define n* (string-index s #\;))
      (define assign (substring s 0 n*))
      (cond [(string-contains? assign ":")
             (match-define (list proc asst)
               (string-split (string-replace assign "P" "") ":"))
             (match-define (list reg val)
               (string-split asst "="))
             (hash-set! (hash-ref! init (string->number proc) make-hash) reg val)]
            [else
             (match-define (list reg val) (string-split assign "="))
             (hash-set! mem reg val)])
      (set! s (string-trim (substring s (+ n* 1))))
      (loop)))

  ; find number of processors
  (define nprocs
    (let ([n (string-index s #\;)])
      (begin0
        (length (string-split (substring s 0 n) "|"))
        (set! s (string-trim (substring s (+ n 1)))))))

  ; find instructions
  (define procs (make-hash))
  (let loop ()
    (unless (or (string-prefix? s "exists")
                (string-prefix? s "~exists")
                (string-prefix? s "locations"))
      (define n* (string-index s #\;))
      (define insns (map string-trim (string-split (substring s 0 n*) "|" #:trim? #f)))
      (for ([(insn p) (in-indexed insns)] #:when (non-empty-string? insn))
        (hash-set! procs p (append (hash-ref procs p '()) (list insn))))
      (set! s (string-trim (substring s (+ n* 1))))
      (loop)))

  ; find postcondition
  (set! s (string-trim (substring s (+ (string-index s #\() 1))))
  (define postcs
    (let ([n (string-index s #\))])
      (begin0
        (map string-trim (string-split (substring s 0 n) "/\\"))
        (set! s (substring s (+ n 1))))))
  (define post (make-hash))
  (for ([c postcs])
    (cond [(string-contains? c ":")
           (match-define (list proc asst)
             (string-split (string-replace c "P" "") ":"))
           (match-define (list reg val)
             (string-split asst "="))
           (hash-set! (hash-ref! post (string->number proc) make-hash) reg val)]
          [else
           (match-define (list addr val) (string-split c "="))
           (hash-set! post addr val)]))

  (litmus-file name cpu content init mem procs post))
