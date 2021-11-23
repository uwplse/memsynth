#lang rosette

(require racket/cmdline
         "../../../frameworks/alglave/models.rkt"
         "../../../memsynth/log.rkt"
         "../../../litmus/litmus.rkt"
         "../../../litmus/tests/uhd630.rkt"
         "../uniqueness.rkt"
         "sketch.rkt" "uhd0.rkt")

(file-stream-buffer-mode (current-output-port) 'none)

;; The tests to use
(define tests (sort all-ppc-tests < #:key (lambda (T) (length (all-actions (litmus-test-program T))))))

;; The sketch to use
(define sketch uhd630-sketch)

;; The litmus test sketch to use
(define litmus-sketch (litmus-test-sketch 4 6 2 #t #t #t #t #f))
(define litmus-sketch-small (litmus-test-sketch 2 5 2 #t #t #t #t #f))

;; The oracle memory model to use for uniqueness
(define oracle PPC)


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

  (printf "===== PPC_0: uniqueness experiment =====\n\n")

  (printf "----- Generating PPC_0... -----\n\n")
  (define PPC_0 (synthesize-PPC_0))
  
  (printf "\n\n----- Making PPC_0 unique... -----\n")
  (define PPC_0* (run-uniqueness-experiment oracle tests sketch (litsketch) PPC_0
                                            #:threads (nthd))))
