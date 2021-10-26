#lang info

(define collection "ocelot")

(define pkg-desc "A solver for relational logic")
(define version "0.0.1")
(define pkg-authors '(james))

(define deps '("base"
               "rackunit-lib"
               "sandbox-lib"
               "s-exp "../rosette/rosette/main.rkt""))
(define build-deps '("scribble-lib" "racket-doc"))

(define scribblings '(("scribblings/ocelot.scrbl" () (experimental))))
