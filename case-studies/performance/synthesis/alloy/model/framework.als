module framework
open program
open test

fun fr[rf: MemoryEvent->MemoryEvent, ws: MemoryEvent->MemoryEvent, t: Test] : MemoryEvent -> MemoryEvent {
    ~rf.ws + { r: t.Reads, w: t.Writes | no rf.r and t.loc[r] = t.loc[w] }
}
fun com[rf: MemoryEvent->MemoryEvent, ws: MemoryEvent->MemoryEvent, t: Test] : MemoryEvent -> MemoryEvent {
    rf + ws + fr[rf,ws,t]
}
fun rfi[rf: MemoryEvent->MemoryEvent, t: Test] :MemoryEvent->MemoryEvent { 
    rf & ((t.proc).~(t.proc))
}
fun rfe[rf: MemoryEvent->MemoryEvent, t: Test] : MemoryEvent->MemoryEvent {
    rf - ((t.proc).~(t.proc))
}
fun ghb[rf: MemoryEvent->MemoryEvent, ws: MemoryEvent->MemoryEvent, ppo: MemoryEvent->MemoryEvent, grf: MemoryEvent->MemoryEvent, ab: MemoryEvent->MemoryEvent, t: Test] : MemoryEvent -> MemoryEvent {
    ppo + ws + fr[rf,ws, t] + grf + ab
}
fun po_loc_llh[t: Test] : MemoryEvent -> MemoryEvent {
    t.po & ((t.loc).~(t.loc)) - t.Reads->t.Reads
}
pred WellFormed_rf[rf: MemoryEvent->MemoryEvent, t: Test] {
    -- rf  ⊂ ∪_{l,v} WR_{l, v}
    rf in (t.loc).~(t.loc) & (t.data).~(t.data) & (t.Writes->t.Reads)
    -- ∀r ∃!w. w→r ∈ rf
    all r: t.Reads { lone rf.r }
    all r: t.Reads { no rf.r => t.data[r] = V0 }
}
pred WellFormed_ws[ws: MemoryEvent->MemoryEvent, t: Test] {
    ws in (t.Writes->t.Writes) & ((t.loc).~(t.loc))
    -- ws is a linear order over WW_{l}
    iden not in ws  -- irreflexive
    ws.ws in ws  -- transitive
    all disj a, b: t.Writes { t.loc[a] = t.loc[b] =>a->b in ws or b->a in ws }  -- total
    -- initialisation writes happen first
    -- all disj a, b: Write { proc[a] = Pinit and proc[b] != Pinit and loc[a] = loc[b] => a->b in ws }
    -- winning writes happen last
    all disj a,b: t.Writes { t.loc[a] = t.loc[b] 
                                   and t.data[a] = t.finalValue[t.loc[a]] 
                                   and t.data[b] != t.finalValue[t.loc[b]] 
                                   => a->b not in ws }
}
pred WellFormed[rf: MemoryEvent->MemoryEvent, ws: MemoryEvent->MemoryEvent, t: Test] {
    WellFormed_rf[rf,t] and WellFormed_ws[ws,t]
}

pred Uniproc[rf: MemoryEvent->MemoryEvent, ws: MemoryEvent->MemoryEvent, t: Test] {
    no ^(com[rf,ws,t] + po_loc_llh[t]) & iden
}

pred Thin[rf: MemoryEvent->MemoryEvent, t: Test] {
    no ^(rf + t.dp) & iden
}

pred ValidExecution[rf: MemoryEvent->MemoryEvent, 
                              ws: MemoryEvent->MemoryEvent, 
                              ppo: MemoryEvent->MemoryEvent, 
                              grf: MemoryEvent->MemoryEvent, 
                              ab: MemoryEvent->MemoryEvent,
                              t: Test] {
    WellFormed[rf,ws,t] and Uniproc[rf,ws,t] and Thin[rf,t] and (no ^(ghb[rf,ws,ppo,grf,ab,t]) & iden)
}
