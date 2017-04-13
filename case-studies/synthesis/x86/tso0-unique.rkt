#lang rosette

(require "../../../frameworks/alglave/models.rkt" "../../../memsynth/log.rkt"
         "../../../litmus/litmus.rkt" "../../../litmus/tests/x86.rkt"
         "../uniqueness.rkt"
         "sketch.rkt" "tso0.rkt")

(file-stream-buffer-mode (current-output-port) 'none)

;; The tests to use
(define tests (sort x86-tests < #:key (lambda (T) (length (all-actions (litmus-test-program T))))))

;; The sketch to use
(define sketch x86-sketch)

;; The litmus test sketch to use
(define litmus-sketch (litmus-test-sketch 4 6 2 #t #f #f #f #t))
(define litmus-sketch-small (litmus-test-sketch 2 5 2 #f #f #f #f #t))

;; The oracle memory model to use for uniqueness
(define oracle TSO)


(module+ main
  (define nthd (make-parameter 1))
  (define litsketch (make-parameter litmus-sketch))
  (command-line
    #:once-each
    [("-v" "--verbose") "Produce verbose log output"
                        (log-types '(unique))]
    [("-s" "--small") "Use small symbolic litmus test"
                      (litsketch litmus-sketch-small)]
    [("-j" "--threads") n
                        "Number of threads to use for search"
                        (define n* (string->number n))
                        (unless (and (integer? n*) (>= n* 1))
                          (raise-argument-error 'threads "positive integer" n))
                        (nthd n*)])
  (printf "===== TSO_0: uniqueness experiment =====\n\n")

  (printf "----- Generating TSO_0... -----\n\n")
  (define TSO_0 (synthesize-TSO_0))
  
  (printf "\n\n----- Making TSO_0 unique... -----\n")
  (define TSO_0* (run-uniqueness-experiment oracle tests sketch (litsketch) TSO_0
                                            #:threads (nthd))))
