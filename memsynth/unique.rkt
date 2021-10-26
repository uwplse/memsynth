#lang s-exp "../rosette/rosette/main.rkt"

(require racket/generator
         "../rosette/rosette/solver/smt/z3.rkt"
         "framework.rkt" "verify.rkt" "util.rkt" "log.rkt" "name.rkt"
         "../litmus/litmus.rkt"
         "../ocelot/ocelot.rkt"
         "strategy/strategy.rkt" "strategy/writes.rkt")
(provide disambiguate make-unique)


; Determine whether a given model is unique -- the only model that explains a
; given set of tests. Does so by searching model-sketch for a second memory
; model also correct on all given tests, but disagrees for some test in the
; given test-sketch.
(define (disambiguate f model-concrete tests model-sketch test-sketch
                      #:strategy [strategy-ctor make-writes-strategy]
                      #:threads [nthd 1])
  (define g (disambiguate* f model-concrete tests model-sketch test-sketch
                           #:strategy strategy-ctor #:threads nthd))
  (g model-concrete #f))


; Make a given model unique by repeatedly discovering missing tests (see above)
; and consulting an oracle model to determine the correct outcome for them.
(define (make-unique f model-concrete tests model-sketch test-sketch oracle
                     #:strategy [strategy-ctor make-writes-strategy]
                     #:threads [nthd 1])
  (define g (disambiguate* f model-concrete tests model-sketch test-sketch
                           #:strategy strategy-ctor #:threads nthd))
  (let loop ([M1 model-concrete][O #f])
    (define-values (M2 T) (g M1 O))
    (cond [(false? M2) M1]
          [else
           (log 'unique "found distinguishing test: ~v" T)
           (log 'unique "first model: ~v" M1)
           (log 'unique "second model: ~v" M2)
           (define allowed-M1 (allowed? f T M1))
           (define allowed-M2 (allowed? f T M2))
           (log 'unique "allowed by M1? ~v" allowed-M1)
           (log 'unique "allowed by M2? ~v" allowed-M2)
           (when (eq? allowed-M1 allowed-M2)
             (raise-result-error 'make-unique "models should disagree" allowed-M1))
           (define O (oracle T))
           (log 'unique "oracle: ~v" O)
           (loop (if (eq? O allowed-M1) M1 M2) O)])))


; Common helper for both methods above.
; Returns a generator which returns the next ambiguous litmus test on each
; invocation. The generator should be called with two arguments:
; * the concrete memory model M to disambiguate
; * a boolean indicating whether the previously returned test should be allowed
; Both arguments can be #f on the first call.
; This method takes as input a "strategy" which determines how to concretize the
; litmus test sketch.
(define (disambiguate* f model-concrete tests model-sketch test-sketch
                       #:strategy [strategy-ctor make-writes-strategy]
                       #:threads [nthd 1])
  (new-log-phase)
  (if (> nthd 1)
      (disambiguate*/par f model-concrete tests model-sketch test-sketch strategy-ctor nthd)
      (disambiguate*/seq f model-concrete tests model-sketch test-sketch strategy-ctor)))

; Run the disambiguate query in parallel with `nthd` threads.
(define (disambiguate*/par f model-concrete tests model-sketch test-sketch strategy-ctor nthd)
  (define strategy (strategy-ctor test-sketch))
  (generator (M O)
    ; list of all the tasks we need to run
    (define topos (reverse (let loop ([ts '()])
                             (let ([n (next-topology strategy)])
                               (if n (loop (cons n ts)) ts)))))
    (define jobs (for*/list ([t topos][pos? (list #t #f)]) (cons t pos?)))

    ; run a task on a new thread; return the custodian for that thread
    (define (run-on-thread t pos?)
      (log 'unique "Trying topology ~v; polarity ~v" t pos?)
      (define cust (make-custodian))
      (define me (current-thread))
      (parameterize ([current-custodian cust]
                     [current-subprocess-custodian-mode 'kill]
                     [current-solver (z3)]  ; make sure threads aren't sharing a solver
                    )
        (thread
         (thunk
          (with-handlers ([exn:fail? (lambda (e) (thread-send me (list cust t pos? e)))])
            (define sketch (instantiate-topology strategy test-sketch t))
            (define t0 (current-inexact-milliseconds))
            (define-values (M2 T)
              (disambiguate-one f model-concrete tests model-sketch test-sketch sketch pos?))
            (define td (- (current-inexact-milliseconds) t0))
            (thread-send me (list cust t pos? M2 T td))))))
      cust)

    ; track all running threads
    (define threads (make-hash))
    ; canonicalize the order jobs were started in, for determinism
    (define all-jobs (make-hash))

    ; start the first thread
    (define first-job (car jobs))
    (hash-set! threads (run-on-thread (car first-job) (cdr first-job)) first-job)
    (hash-set! all-jobs first-job 0)
    (set! jobs (cdr jobs))

    ; handle jobs
    (define rec-evt (thread-receive-evt))
    (let loop ()
      ; throttle our spawning of new threads: start either once Racket is idle
      ; (i.e., s-exp "../rosette/rosette/main.rkt" has shelled out to Z3) or after 2 seconds.
      (match (if (and (< (hash-count threads) nthd) (not (null? jobs)))
                 (sync/timeout/enable-break 2.0 (system-idle-evt) rec-evt)
                 (sync/enable-break rec-evt))
        [(== rec-evt)
         (match (thread-receive)  ; will not block, because rec-evt has fired
           [(list cust t pos? M2 T td)
            (cond [M2  ; found a distinguishing model and test
                   (log 'unique "SAT [~ams]: topology ~v; polarity ~v"
                                (~r td #:precision 0) t pos?)
                   ; shutdown all the threads (including the one that messaged us).
                   ; be sure to return jobs to the queue such that they restart in
                   ; the order they originally started.
                   (define my-job (hash-ref threads cust))
                   (define running-jobs
                     (sort (hash->list threads) >
                           #:key (lambda (x) (hash-ref all-jobs (cdr x)))))
                   (for ([c/j running-jobs])
                     (match-define (cons t j) c/j)
                     (custodian-shutdown-all t)
                     (unless (equal? j my-job)
                       (set! jobs (cons j jobs))))
                   (hash-clear! threads)
                   ; drain messages
                   (let inner ()
                     (when (thread-try-receive) (inner)))
                   ; yield the result
                   (define-values (M1* O) (yield M2 T))
                   (set! model-concrete M1*)
                   (set! tests (cons (cons T O) tests))
                   ; restart the SAT job
                   (hash-set! threads (run-on-thread (car my-job) (cdr my-job)) my-job)]
                  [else
                   (log 'unique "UNSAT [~ams]: topology ~v polarity ~v; ~v remaining jobs"
                        (~r td #:precision 0) t pos? (length jobs))
                   ; kill that thread
                   (custodian-shutdown-all cust)
                   (hash-remove! threads cust)
                   ; start next job (no race here bc must finish this code before next msg)
                   (unless (null? jobs)
                     (define next-job (car jobs))
                     (define next-cust (run-on-thread (car next-job) (cdr next-job)))
                     (hash-set! threads next-cust next-job)
                     (unless (hash-has-key? all-jobs next-job)
                       (hash-set! all-jobs next-job (hash-count all-jobs)))
                     (set! jobs (cdr jobs)))])]
           [(list cust t pos? exn) ; fail if a thread fails
            (raise exn)])]
        [_ (define next-job (car jobs))
           (hash-set! threads (run-on-thread (car next-job) (cdr next-job)) next-job)
           (unless (hash-has-key? all-jobs next-job)
             (hash-set! all-jobs next-job (hash-count all-jobs)))
           (set! jobs (cdr jobs))])
      (when (or (> (hash-count threads) 0) (> (length jobs) 0))
        (loop)))

    (values #f #f)))

; Run the disambiguate query on a single thread.
(define (disambiguate*/seq f model-concrete tests model-sketch test-sketch strategy-ctor)
  (define strategy (strategy-ctor test-sketch))
  (generator (M O)
    (let outer ()
      (define next (next-topology strategy))
      (cond [next
             (for ([pos? (list #t #f)])
               (log 'unique "Trying topology ~v; polarity ~v" next pos?)
               (define sketch (instantiate-topology strategy test-sketch next))
               (let inner ()
                 (define-values (M2 T)
                   (parameterize ([current-custodian (make-custodian)]
                                  [current-subprocess-custodian-mode 'kill]
                                 )
                     (begin0
                       (disambiguate-one f model-concrete tests model-sketch test-sketch sketch pos?)
                       (custodian-shutdown-all (current-custodian)))))
                 (when M2
                   (define-values (M1* O) (yield M2 T))
                   (set! model-concrete M1*)
                   (set! tests (cons (cons T O) tests))
                   (inner))))
             (outer)]
            [else (values #f #f)]))))


; Disambiguate with respect to a single sketch bSketch.
; Returns two values: a memory-model? and a litmus-test?,
; or #f #f if no disambiguating test exists within bSketch.
(define (disambiguate-one f model-concrete tests model-sketch test-sketch bSketch pos?)
  ; create the test sketch constraints and bounds
  (define iSketch (instantiate-bounds bSketch))
  (define WFP (WellFormedProgram test-sketch))
  (define WFP* (interpret* WFP iSketch))
  
  ; test evaluation
  (define (eval-test T O)
    (define bTest (instantiate-test T))
    (define iTest (instantiate-bounds bTest))
    (define bExec (instantiate-execution f bTest))
    (define iExec (instantiate-bounds bExec))
    (define interp (interpretation-union iTest iExec))
    (define VE (allow f model-sketch))
    (define-values (VE*)
      (result-value (with-vc (interpret* VE interp #:cache? #t))))
    (define xs (symbolics iExec))
    (log 'unique/synth "interpreted test ~a(~a)" (litmus-test-name T) O)
    (if O VE* (forall xs (! VE*))))
  
  ; counterexample discovery
  (define (find-cex model)
    (let loop ([tests tests])
      (if (null? tests)
          #f
          (match-let ([(cons T O) (car tests)])
            (let-values ([(res) (result-value (with-vc (allowed? f T model)))])
              (log 'unique/synth "tested ~a(~v)" (litmus-test-name T) O)
              (if (equal? res O)
                  (loop (cdr tests))
                  (car tests)))))))
  
  ; QBF solver
  (define solver (z3))
  (solver-clear solver)  ; inherit s-exp "../rosette/rosette/main.rkt"'s solver options
  
  ; assert WFP
  (solver-assert solver (list WFP*))
  
  ; assert the sketched test on the concrete model
  (define (add-sketched-test-concrete)
    (define bExec (instantiate-execution f bSketch))
    (define iExec (instantiate-bounds bExec))
    (define interp (interpretation-union iExec iSketch))
    (define VE (allow f model-concrete))
    (define-values (VE*)
      (result-value (with-vc (interpret* VE interp #:cache? #t))))
    (define xs* (symbolics iExec))
    (solver-assert solver (list (if pos? (forall xs* (! VE*)) VE*)))
    (log 'unique/synth "added sketched test on concrete model"))
  
  ; assert the sketched test on the sketched model
  (define (add-sketched-test-symbolic)
    (define bExec (instantiate-execution f bSketch))
    (define iExec (instantiate-bounds bExec))
    (define interp (interpretation-union iExec iSketch))
    (define VE (allow f model-sketch))
    (define-values (VE*)
      (result-value (with-vc (interpret* VE interp #:cache? #t))))
    (define xs* (symbolics iExec))
    (solver-assert solver (list (if pos? VE* (forall xs* (! VE*)))))
    (log 'unique/synth "added sketched test on symbolic model"))
  
  (add-sketched-test-concrete)
  (add-sketched-test-symbolic)
  
  ; do the synthesis
  (define all-holes (append (symbolics model-sketch) (symbolics iSketch)))
  (let loop ()
    (let ([candidate (solver-check solver)])
      (cond
        [(unsat? candidate) (log 'unique/synth "candidate is unsat")
                            (values #f #f)]
        [else
         (define S* (model-for candidate all-holes))
         (define M (evaluate model-sketch S*))
         (log 'unique/synth "found candidate: ~v" M)
         (define T
           (relations->litmus-test (interpretation->relations (evaluate iSketch S*))))
         (log 'unique/synth "test: ~v" T)
         (log 'unique/synth "allowed by existing? ~v" (allowed? f T model-concrete))
         (log 'unique/synth "allowed by candidate? ~v" (allowed? f T M))
         (define next-test (find-cex M))
         (cond [next-test
                (log 'unique/synth "found next test")
                (solver-assert solver (list (eval-test (car next-test) (cdr next-test))))
                (remove! tests next-test)
                (loop)]
               [else (values M (rename-test T 'disambig))])]))))
