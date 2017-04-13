#lang rosette

(require "framework.rkt" "verify.rkt" "util.rkt" "log.rkt"
         "../litmus/litmus.rkt" 
         ocelot
         rosette/solver/smt/z3)

(provide synth synth-tests-used)

(define synth-tests-used 0)

; Perform incremental synthesis given a list of tests.
; Each test is a pair (cons program outcome), where outcome is either #t or #f.
; The incremental synthesis uses the tests as the verification oracle for CEGIS,
; testing them in the order they are provided.
(define (synth f tests sketch)
  (parameterize ([current-custodian (make-custodian)]
                 [current-subprocess-custodian-mode 'kill])
    (set! synth-tests-used 0) ; XXX hack

    ; test evaluation
    (define (eval-test T O)
      (define bTest (instantiate-test T))
      (define iTest (instantiate-bounds bTest))
      (define bExec (instantiate-execution f bTest))
      (define iExec (instantiate-bounds bExec))
      (define interp (interpretation-union iTest iExec))
      (define VE (allow f sketch))
      (define-values (VE* assumes)
        (with-asserts (interpret* VE interp #:cache? #t)))
      (define xs (symbolics iExec))
      (log 'synth "interpreted test ~a(~a)" (litmus-test-name T) O)
      (set! synth-tests-used (add1 synth-tests-used))
      (if O VE* (forall xs (! VE*))))
    
    ; counterexample discovery
    (define (find-cex model)
      (let loop ([tests tests])
        (if (null? tests)
            #f
            (match-let ([(cons T O) (car tests)])
              (let-values ([(res as) (parameterize ([term-cache (make-hash)])
                                       (with-asserts
                                           (allowed? f T model)))])
                (log 'synth "tested ~a(~v)" (litmus-test-name T) O)
                (if (equal? res O)
                    (loop (cdr tests))
                    (car tests)))))))

    ; QBF solver
    (define solver (z3))
    (solver-clear solver)  ; inherit Rosette's solver options

    ; find first positive and negative tests
    (define pos-test (findf cdr tests))
    (when pos-test
      (solver-assert solver (list (eval-test (car pos-test) (cdr pos-test))))
      (remove! tests pos-test))
    (define neg-test (findf (compose1 not cdr) tests))
    (when neg-test
      (solver-assert solver (list (eval-test (car neg-test) (cdr neg-test))))
      (remove! tests neg-test))

    ; do the synthesis
    (define all-holes (symbolics sketch))
    (begin0
      (let loop ()
        (let ([candidate (solver-check solver)])
          (cond
            [(unsat? candidate) (log 'synth "candidate is unsat")
                                #f]
            [else
             (define S* (model-for candidate all-holes))
             (define M (evaluate sketch S*))
             (log 'synth "found candidate: ~v" M)
             (define next-test (find-cex M))
             (cond [next-test
                    (log 'synth "found next test")
                    (solver-assert solver (list (eval-test (car next-test) (cdr next-test))))
                    (remove! tests next-test)
                    (loop)]
                   [else M])])))
      (custodian-shutdown-all (current-custodian)))))
