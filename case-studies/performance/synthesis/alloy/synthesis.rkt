#lang racket

(require "../../bin/alloy.rkt"
         racket/sandbox racket/runtime-path file/unzip)

(file-stream-buffer-mode (current-output-port) 'none)
(current-subprocess-custodian-mode 'kill)
(subprocess-group-enabled #t)

(define-runtime-path bin "../../bin")
(define-runtime-path synth.als "model/synth.als")

(define-values (alloy.jar alloy-lib) (setup-alloy "hola-0.2.jar"))
(compile-java "Run.java")


(define (run-synthesis timeout)
  (with-handlers ([exn:fail:resource? (lambda (e) (printf "TIMEOUT\n"))])
    (with-deep-time-limit timeout
      (system (format "java -cp ~a:~a -Djava.library.path=~a Run ~a"
                      alloy.jar
                      bin
                      alloy-lib
                      synth.als))))
  (void))


(module+ main
  (define timeout 300)
  (printf "Timeout is ~v secs\n" timeout)
  (run-synthesis timeout))
