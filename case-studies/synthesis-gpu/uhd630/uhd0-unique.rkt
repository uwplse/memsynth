#lang rosette

(require racket/cmdline
         "../../../frameworks/opencl/oracle.rkt"
         "../../../memsynth/log.rkt"
         "../../../litmus/sketch-gpu.rkt"
         "../../../litmus/tests/intel-gpu.rkt"
         "../uniqueness.rkt"
         "sketch.rkt" "uhd0.rkt")

(file-stream-buffer-mode (current-output-port) 'none)

;; The tests to use
(define tests (sort intel-gpu-coherence-tests-default < #:key (lambda (T) (length (all-events (litmus-test-program T))))))

;; The sketch to use
(define sketch intel-gpu-sketch)

;; The litmus test sketch to use
(define litmus-sketch (litmus-test-sketch 4 6 2 #t #t #t #t #f))
(define litmus-sketch-small (litmus-test-sketch 2 5 2 #t #t #t #t #f))

;; The oracle memory model to use for uniqueness
(define oracle SC)


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

  (printf "===== UHD_0: uniqueness experiment =====\n\n")

  (printf "----- Generating UHD_0... -----\n\n")
  (define UHD_0 (synthesize-UHD_0))
  
  (printf "\n\n----- Making UHD_0 unique... -----\n")
  (define UHD_0* (run-uniqueness-experiment oracle tests sketch (litsketch) UHD_0
                                            #:threads (nthd))))
