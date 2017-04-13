#lang racket

(require "../../bin/alloy.rkt"
         racket/sandbox racket/runtime-path file/unzip)

(file-stream-buffer-mode (current-output-port) 'none)
(current-subprocess-custodian-mode 'kill)
(subprocess-group-enabled #t)

(define-runtime-path bin "../../bin")
(define-runtime-path tests "ppc/tests")

(define-values (alloy.jar alloy-lib) (setup-alloy "alloy4.2_2015-02-22.jar"))


(define (run-verifier)
  (define paths (string-join (map path->string (directory-list tests #:build? #t)) " "))
  (system (format "java -cp ~a:~a -Djava.library.path=~a RunTests ~a"
                  alloy.jar
                  bin
                  alloy-lib
                  paths))
  (void))


(module+ main
  (if (vector-member "-c" (current-command-line-arguments))
      (compile-java "RunTests.java" "alloy4.2_2015-02-22.jar")
      (run-verifier)))

