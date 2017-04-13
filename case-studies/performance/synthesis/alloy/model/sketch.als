module sketch
open model

-- A simple sketch that simply chooses between three models

abstract sig Model {}
one sig SC, TSO, PSO extends Model {}

fun ppo_sketch[s: one Model, t: Test] : MemoryEvent->MemoryEvent {
         s = SC =>    ppo_SC[t]
    else s = TSO =>   ppo_TSO[t]
    else              ppo_PSO[t]
}
fun grf_sketch[s: one Model, t: Test, rf: MemoryEvent->MemoryEvent] : MemoryEvent->MemoryEvent {
         s = SC =>    grf_SC[rf, t] 
    else s = TSO =>   grf_TSO[rf, t]
    else              grf_PSO[rf, t]
}
fun ab_sketch[s: one Model, t: Test, rf: MemoryEvent->MemoryEvent] : MemoryEvent->MemoryEvent {
         s = SC =>    ab_SC[rf, t]
    else s = TSO =>   ab_TSO[rf, t]
    else              ab_PSO[rf, t]
}       
pred Allowed_Sketch[t: Test, s: one Model] {
    some rf: t.Writes->t.Reads, ws: t.Writes->t.Writes |
        let ppo = ppo_sketch[s, t], grf = grf_sketch[s, t, rf], ab = ab_sketch[s, t, rf] |
            ValidExecution[rf, ws, ppo, grf, ab, t]
}
    
