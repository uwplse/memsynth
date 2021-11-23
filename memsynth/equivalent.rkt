#lang rosette

(require "framework.rkt" "log.rkt" "name.rkt"
         "../litmus/litmus.rkt"
         "../ocelot/ocelot.rkt"
         "strategy/strategy.rkt" "strategy/writes.rkt"
         rosette/solver/smt/z3)
(provide equivalent?)


; Takes two models and checks whether they are equivalent on all tests up to 
; a given bound.
(define (equivalent? f mA mB sketch [direction #f]
                     #:strategy [strategy-ctor make-writes-strategy]
                     #:threads [nthd 1])
  (new-log-phase)
  (if (> nthd 1)
      (equivalent?/par f mA mB sketch direction strategy-ctor nthd)
      (equivalent?/seq f mA mB sketch direction strategy-ctor)))

; Run the equivalence query with one thread.
(define (equivalent?/seq f mA mB sketch direction strategy-ctor)
  (define strategy (strategy-ctor sketch))
  (define polarities
    (match direction
      ['stronger (list #t)]
      ['weaker   (list #f)]
      [_         (list #t #f)]))
  (let loop ()
    (define next (next-topology strategy))
    (cond [next
           (let inner ([pos? (car polarities)][!pos? (cdr polarities)])
             (log 'equiv "Trying topology ~v; polarity ~v" next pos?)
             (define bSketch (instantiate-topology strategy sketch next))
             (define T (parameterize ([current-terms (hash-copy (current-terms))])
                        (equivalent?/one f mA mB sketch bSketch pos?)))
             (cond [(litmus-test? T) T]
                   [(not (null? !pos?)) (inner (car !pos?) (cdr !pos?))]
                   [else (loop)]))]
          [else #t])))

; Run the equivalence query in parallel with `nthd` threads.
(define (equivalent?/par f mA mB sketch direction strategy-ctor nthd)
  (define strategy (strategy-ctor sketch))

  ; list of all the tasks we need to run
  (define polarities
    (match direction
      ['stronger (list #t)]
      ['weaker   (list #f)]
      [_         (list #t #f)]))
  (define topos (reverse (let loop ([ts '()])
                           (let ([n (next-topology strategy)])
                             (if n (loop (cons n ts)) ts)))))
  (define jobs (for*/list ([t topos][pos? polarities]) (cons t pos?)))

  ; run a task on a new thread; return the custodian for that thread
  (define (run-on-thread t pos?)
    (log 'equiv "Trying topology ~v; polarity ~v" t pos?)
    (define cust (make-custodian))
    (define me (current-thread))
    (parameterize ([current-custodian cust]
                   [current-subprocess-custodian-mode 'kill]
                   [current-solver (z3)]  ; make sure threads aren't sharing a solver
                   [current-terms (hash-copy (current-terms))]
                  )
      (thread
       (thunk
        (with-handlers ([exn:fail? (lambda (e) (thread-send me (list cust t pos? e)))])
          (define bSketch (instantiate-topology strategy sketch t))
          (define t0 (current-inexact-milliseconds))
          (define T (equivalent?/one f mA mB sketch bSketch pos?))
          (define td (- (current-inexact-milliseconds) t0))
          (thread-send me (list cust t pos? T td))))))
    cust)

  ; start the initial threads
  (define threads (make-hash))
  (for ([i nthd][j jobs])
    (hash-set! threads (run-on-thread (car j) (cdr j)) j))
  (set! jobs (drop jobs (hash-count threads)))

  ; handle jobs
  (let loop ()
    (match (thread-receive)
      [(list cust t pos? T td)
       (cond [(litmus-test? T)
              (log 'equiv "SAT [~ams]: ~v/~v" (~r td #:precision 0) t pos?)
              ; shutdown all the threads
              (for ([(t j) threads])
                (custodian-shutdown-all t)
                (set! jobs (cons j jobs)))
              (hash-clear! threads)
              ; drain messages
              (let inner ()
                (when (thread-try-receive) (inner)))
              T]
             [else
              (log 'equiv "UNSAT [~ams]: topology ~v polarity ~v; ~v remaining jobs"
                   (~r td #:precision 0) t pos? (length jobs))
              ; kill that thread
              (custodian-shutdown-all cust)
              (hash-remove! threads cust)
              ; start next job (no race here bc must finish this code before next msg)
              (unless (null? jobs)
                (define next-job (car jobs))
                (define next-cust (run-on-thread (car next-job) (cdr next-job)))
                (hash-set! threads next-cust next-job)
                (set! jobs (cdr jobs)))
              (if (or (> (hash-count threads) 0) (> (length jobs) 0))
                  (loop)
                  #t)])]
        [(list cust t pos? exn) ; fail if a thread fails
         (raise exn)])))


; Checks equivalence on a given set of sketch bounds and polarity
; (mA stronger or weaker than mB)
(define (equivalent?/one f mA mB sketch bSketch pos?)
  ; construct the test sketch and its well-formedness constraint
  (define iSketch (instantiate-bounds bSketch))
  (define WFP (WellFormedProgram sketch))
  (define WFP* (interpret* WFP iSketch))

   ; construct executions for mA and mB
  (define (execute M)
    (define bExec (instantiate-execution f bSketch))
    (define iExec (instantiate-bounds bExec))
    (define interp (interpretation-union iExec iSketch))
    (define VE (allow f M))
    (define VE* (interpret* VE interp))
    (define xs (symbolics iExec))
    (values VE* xs))
  (define-values (VE*A xsA) (execute mA))
  (define-values (VE*B xsB) (execute mB))

  ; synthesize a test allowed by one model and disallowed by another
  (define (synth-test VE-allow VE-disallow xs-disallow)
    (define solver (z3))
    (solver-assert solver (list WFP* VE-allow (forall xs-disallow (not VE-disallow))))
    (begin0
      (solver-check solver)
      (solver-shutdown solver)))

  ; find a solution to the queries
  (define S
    (if pos?
        (synth-test VE*A VE*B xsB)
        (synth-test VE*B VE*A xsA)))
  
  (if (sat? S)
      (rename-test
        (relations->litmus-test (interpretation->relations (evaluate iSketch S)))
        'equiv)
      #t))
