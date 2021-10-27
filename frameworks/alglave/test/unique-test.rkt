#lang s-exp "../../../rosette/rosette/main.rkt"

(require "../framework.rkt" "../models.rkt" "../sketch-model.rkt"
         "../../../litmus/litmus.rkt" "../../../litmus/tests/alglave.rkt"
         "../../../ocelot/ocelot.rkt"
         "../../../memsynth/strategy/writes.rkt"
         "../../../memsynth/strategy/threads.rkt"
         "../../../memsynth/strategy/none.rkt"
         "../../../memsynth/strategy/first.rkt"
         rackunit rackunit/text-ui)

(define (run-unique-tests tests model sketch [sat? #t]
                          #:threads [nthd 1]
                          #:strategy [strategy make-writes-strategy])
  (test-begin
    (printf "tests: ~v\n" (map litmus-test-name tests))
    (define TOs (for/list ([T tests]) (cons T (litmus-test-allowed? (model-name model) T))))

    (define T_s (litmus-test-sketch 2 4 2 #f #f #f #f #f))
    (define-values (new-model T) (disambiguate alglave model TOs sketch T_s #:threads nthd #:strategy strategy))

    (cond [sat? (check-not-false T)
                (printf "solution:  ppo: ~a\n" (ast->datum (model-ppo new-model)))
                (printf "           grf: ~a\n" (ast->datum (model-grf new-model)))
                (printf "            ab: ~a\n" (ast->datum (model-ab new-model)))
                (printf "          test: ~v\n" T)
                (define old (allowed? alglave T model))
                (define new (allowed? alglave T new-model))
                (check-false (equal? old new))]
          [else (check-false T)
                (printf "no soln\n")])))

;(define-syntax-rule (id . pattern) template)
(define-syntax-rule (make-unique-tests name options ...)
  (test-suite
   name
   #:before (thunk (printf "\n\n-----running unique tests (~a)-----\n" name))
   (begin
     (let ([sketch (trivial-sketch TSO SC)])
       (run-unique-tests
        (list test/nemos/01 test/nemos/02) TSO sketch
        options ...)
       (run-unique-tests
        (list test/nemos/01 test/nemos/02 test/nemos/11) TSO sketch #f
        options ...))
     (let ([sketch (trivial-sketch TSO SC PSO)])
       (run-unique-tests
        (list test/nemos/01 test/nemos/02 test/nemos/11 test/nemos/12 test/nemos/13) TSO sketch
        options ...)
       (run-unique-tests
        (list test/nemos/01 test/nemos/02 test/nemos/11 test/nemos/12 test/nemos/13 test/nemos/10) TSO sketch #f
        options ...))
    )
  )
)


(define unique-tests
  (make-unique-tests "default"))
(define unique-tests/threads
  (make-unique-tests "threads strategy" #:strategy make-threads-strategy))
(define unique-tests/none
  (make-unique-tests "none strategy" #:strategy make-none-strategy))
(define unique-tests/first
  (make-unique-tests "first strategy" #:strategy make-first-strategy))
(define unique-tests/parallel
  (make-unique-tests "parallel" #:threads 2))


(time (run-tests unique-tests))
(time (run-tests unique-tests/threads))
(time (run-tests unique-tests/none))
(time (run-tests unique-tests/first))
(time (run-tests unique-tests/parallel))
