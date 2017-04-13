#lang racket

(require ocelot
         "../../../../frameworks/alglave/model.rkt")
(provide model-pair->alloy)

(define (model-pair->alloy m1 m2)
  ; rewrite some symbols to match the Alloy framework
  (define (rewrite x)
    (define a (ast->alloy x))
    (define rewrites (hash "Reads" "Read" "Writes" "Write" "Syncs" "Sync" "Lwsyncs" "Lwsync"))
    (for/fold ([a a]) ([(k v) rewrites])
      (string-replace a k v)))

  (define template
    #<<TPL
module ~a_~a
open model
open program
open wfp

fun ppo_a : MemoryEvent->MemoryEvent {
    ~a
}
fun grf_a[rf: MemoryEvent->MemoryEvent] : MemoryEvent->MemoryEvent {
    ~a
}
fun ab_a[rf: MemoryEvent->MemoryEvent] : MemoryEvent->MemoryEvent {
    ~a
}
pred Allowed_PPC_A {
    some rf:Write->Read, ws:Write->Write |
        ValidExecution[rf, ws, ppo_a, grf_a[rf], ab_a[rf]]
}


fun ppo_b : MemoryEvent->MemoryEvent {
    ~a
}
fun grf_b[rf: MemoryEvent->MemoryEvent] : MemoryEvent->MemoryEvent {
    ~a
}
fun ab_b[rf: MemoryEvent->MemoryEvent] : MemoryEvent->MemoryEvent {
    ~a
}
pred Allowed_PPC_B {
    some rf:Write->Read, ws:Write->Write |
        ValidExecution[rf, ws, ppo_b, grf_b[rf], ab_b[rf]]
}

run {
    WellFormedProgram and ((Allowed_PPC_A and not Allowed_PPC_B) or (Allowed_PPC_B and not Allowed_PPC_A))
} for 6 MemoryEvent, 2 Processor, 2 Location

TPL
    )

  (format template
          (model-name m1)
          (model-name m2)
          (rewrite (model-ppo m1))
          (rewrite (model-grf m1))
          (rewrite (model-ab m1))
          (rewrite (model-ppo m2))
          (rewrite (model-grf m2))
          (rewrite (model-ab m2))))
