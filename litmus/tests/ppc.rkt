#lang racket

(require "../lang.rkt" "ppc-all.rkt")

(provide (except-out (all-defined-out) test-filter) (all-from-out "../lang.rkt"))

(define ppc-tests
  (list test/ppc/podwr000 test/ppc/podrr000 test/ppc/lwdwr020 test/ppc/aclwdrr017 
        test/ppc/podwr001 test/ppc/rfe003 test/ppc/rfi000 test/ppc/aclwdrr010
        test/ppc/podrwposwr023 test/ppc/lwswr002 test/ppc/aclwsrr002 test/ppc/lwswr003
        test/ppc/safe320 test/ppc/safe358 test/ppc/safe460 test/ppc/safe388 
        test/ppc/safe503))

(define (test-filter pred tests)
  (filter
    (lambda (t) (not (for/or ([op (all-actions (litmus-test-program t))]) (pred op))))
    tests))

(define ppc-tests/no-lwsync
  (test-filter (lambda (op) (and (Fence? op) (equal? (Fence-type op) 'lwsync))) ppc-tests))
(define ppc-tests/no-fence
  (test-filter Fence? ppc-tests))
