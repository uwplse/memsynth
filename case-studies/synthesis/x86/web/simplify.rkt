#lang racket

(require json
         racket/hash
         "../ocelot/ocelot.rkt" 
         "../../../../litmus/litmus.rkt"
         "../../../../litmus/types.rkt")

(define rf (declare-relation 2 "rf"))

(define-namespace-anchor a)
(define ns (namespace-anchor->namespace a))

(define data
  (with-input-from-file "data.json" read-json))

(define data*
  (let rec ([d data])
    (cond
      [(hash? d)
       (if (hash-has-key? d 'ppo)
           (let ([ppo (eval (with-input-from-string (hash-ref d 'ppo) read) ns)]
                 [grf (eval (with-input-from-string (hash-ref d 'grf) read) ns)])
             (hash-union
              (for/hash ([(k v) d]) (values k (rec v)))
              (hash 'ppo (~a (ast->datum (simplify/solve ppo (litmus-type-constraints #:syncs? #f #:lwsyncs? #f #:atomics? #f))))
                    'grf (~a (ast->datum (simplify/solve grf (litmus-type-constraints #:syncs? #f #:lwsyncs? #f #:atomics? #f)))))
              #:combine (lambda (a b) b)))
           (for/hash ([(k v) d]) (values k (rec v))))]
      [(list? d)
       (map rec d)]
      [else d])))

(write-json data*)
