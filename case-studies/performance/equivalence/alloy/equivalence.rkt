#lang racket

(require "../../bin/alloy.rkt"
         "../../../../frameworks/alglave/model.rkt"
         "../models/models.rkt" "export.rkt"
         racket/sandbox racket/runtime-path)

(file-stream-buffer-mode (current-output-port) 'none)
(current-subprocess-custodian-mode 'kill)
(subprocess-group-enabled #t)

(define-runtime-path bin "../../bin")
(define-runtime-path alloy-model "model")

(define-values (alloy.jar alloy-lib) (setup-alloy "hola-0.2.jar"))
(compile-java "Run.java")

(define (check-equivalent?/alloy m1 m2 timeout)
  (define alloy (model-pair->alloy m1 m2))
  (define name (format "~a_~a.als" (model-name m1) (model-name m2)))
  (define als-path (build-path alloy-model name))
  (display-to-file alloy als-path #:exists 'replace)
  (begin0
    (with-handlers ([exn:fail:resource? (lambda (e) 'timeout)])
      (let ([cmd (format "java -cp ~a:~a -Djava.library.path=~a Run ~a"
                          alloy.jar
                          bin
                          alloy-lib
                          als-path)])
        (parameterize ([current-output-port (open-output-nowhere)])
          (with-deep-time-limit timeout
            (system cmd)))
        'success))
    (delete-file als-path)))


(define (check-pairwise-equivalence models timeout)
  (define model-pairs
    (for*/list ([(m1 i) (in-indexed models)][m2 (drop models (add1 i))])
      (cons m1 m2)))
  (define output-path (path->complete-path "alloy.csv"))
  (printf "Writing results to ~a\n" output-path)
  (define f (open-output-file output-path #:exists 'replace))
  (printf "0/~v\n" (length model-pairs))
  (for ([(m1m2 i) (in-indexed model-pairs)])
    (match-define (cons m1 m2) m1m2)
    (define t0 (current-inexact-milliseconds))
    (define result (check-equivalent?/alloy m1 m2 timeout))
    (define t (- (current-inexact-milliseconds) t0))
    (fprintf f "~a_~a,~v,~a\n" (model-name m1) (model-name m2) t result)
    (flush-output f)
    (printf "~v/~v\n" (+ i 1) (length model-pairs)))
  (close-output-port f))

(module+ main
  (check-pairwise-equivalence models 120))
