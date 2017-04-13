module alglave
open program
open framework
open test

/* SC */
fun ppo_SC[t: Test] : MemoryEvent->MemoryEvent {
    t.po
}
fun grf_SC[rf: MemoryEvent->MemoryEvent, t: Test] : MemoryEvent->MemoryEvent {
    rf
}
fun ab_SC[rf: MemoryEvent->MemoryEvent, t: Test] : MemoryEvent->MemoryEvent {
    none->none
}

/* TSO */
fun ppo_TSO[t: Test] : MemoryEvent->MemoryEvent {
    t.po & (t.Reads->t.Events + t.Writes->t.Writes)
}
fun grf_TSO[rf: MemoryEvent->MemoryEvent, t: Test] : MemoryEvent->MemoryEvent {
    rfe[rf,t]
}
fun ab_TSO[rf: MemoryEvent->MemoryEvent, t: Test] : MemoryEvent->MemoryEvent {
    none->none
}

/* PSO */
fun ppo_PSO[t: Test] : MemoryEvent->MemoryEvent {
    t.po & (t.Reads->t.Events)
}
fun grf_PSO[rf: MemoryEvent->MemoryEvent, t: Test] : MemoryEvent->MemoryEvent {
    rfe[rf,t]
}
fun ab_PSO[rf: MemoryEvent->MemoryEvent, t: Test] : MemoryEvent->MemoryEvent {
    none->none
}

/* Alpha */
fun ppo_Alpha[t: Test] : MemoryEvent->MemoryEvent {
    t.po & ((t.loc).~(t.loc) & (t.Reads->t.Reads))
}
fun grf_Alpha[rf: MemoryEvent->MemoryEvent, t: Test] : MemoryEvent->MemoryEvent {
    rfe[rf,t]
}
fun ab_Alpha[rf: MemoryEvent->MemoryEvent, t: Test] : MemoryEvent->MemoryEvent {
    none->none
}

/* RMO */
fun ppo_RMO[t: Test] : MemoryEvent->MemoryEvent {
    t.po & t.dp
}
fun grf_RMO[rf: MemoryEvent->MemoryEvent, t: Test] : MemoryEvent->MemoryEvent {
    rfe[rf,t]
}
fun ab_RMO[rf: MemoryEvent->MemoryEvent, t: Test] : MemoryEvent->MemoryEvent {
    none->none
}


/* PPC */
fun ppo_PPC[t: Test] : MemoryEvent->MemoryEvent {
    t.po & t.dp
}
fun grf_PPC[rf: MemoryEvent->MemoryEvent, t: Test] : MemoryEvent->MemoryEvent {
    none->none
}
fun ab_sync[rf: MemoryEvent->MemoryEvent, t: Test] : MemoryEvent->MemoryEvent {
    let sync = ((t.po) :> (t.Syncs)).(t.po) |
        ^(sync + sync.rf + rf.sync)
}
fun ab_lwsync[rf: MemoryEvent->MemoryEvent, t: Test] : MemoryEvent->MemoryEvent {
    let lwsync = ((t.po) :> (t.Lwsyncs)).(t.po) & (t.Writes->t.Writes + t.Reads->t.Events) |
        ^(lwsync + (rf.lwsync :> t.Writes) + (t.Reads <: lwsync.rf))
}
fun ab_PPC[rf: MemoryEvent->MemoryEvent, t: Test] : MemoryEvent->MemoryEvent {
    ab_sync[rf,t] + ab_lwsync[rf,t]
}


/* Vacuous */
fun ppo_vacuous[t: Test] : MemoryEvent->MemoryEvent {
    none->none
}
fun grf_vacuous[rf: MemoryEvent->MemoryEvent, t: Test] : MemoryEvent->MemoryEvent {
    none->none
}
fun ab_vacuous[rf: MemoryEvent->MemoryEvent, t: Test] : MemoryEvent->MemoryEvent {
    none->none
}
