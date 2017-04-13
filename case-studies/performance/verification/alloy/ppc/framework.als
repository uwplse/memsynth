module framework
open program

fun fr[rf: Write->Read, ws: Write->Write] : Read -> Write {
    ~rf.ws + { r: Read, w: Write | no rf.r and loc[r] = loc[w] }
}
fun com[rf: Write->Read, ws: Write->Write] : MemoryEvent -> MemoryEvent {
    rf + ws + fr[rf,ws]
}
fun rfi[rf: Write->Read] : Write -> Read { 
    rf & (proc.~proc)
}
fun rfe[rf: Write->Read] : Write -> Read {
    rf - (proc.~proc)
}
fun ghb[rf: Write->Read, ws: Write->Write, ppo: MemoryEvent->MemoryEvent, grf: Write->Read, ab: MemoryEvent->MemoryEvent] : MemoryEvent -> MemoryEvent {
    ppo + ws + fr[rf,ws] + grf + ab
}
fun po_loc[] : MemoryEvent -> MemoryEvent {
    po & (loc.~loc)
}
pred WellFormed_rf[rf: Write->Read] {
    -- rf  ⊂ ∪_{l,v} WR_{l, v}
    rf in (loc.~loc & data.~data)
    -- ∀r ∃!w. w→r ∈ rf
    all r: Read { lone rf.r }
    all r: Read { no rf.r => data[r] = 0 }
}
pred WellFormed_ws[ws: Write->Write] {
    -- ws ⊂ ∪ \cup_{l} WW_{l}
    all a, b: Write { a->b in ws => loc[a] = loc[b] }
    -- ws is a linear order over WW_{l}
    iden not in ws  -- irreflexive
    ws.ws in ws  -- transitive
    all disj a, b: Write { loc[a] = loc[b] =>a->b in ws or b->a in ws }  -- total
    -- initialisation writes happen first
    -- all disj a, b: Write { proc[a] = Pinit and proc[b] != Pinit and loc[a] = loc[b] => a->b in ws }
    -- winning writes happen last
    all disj a,b: Write { loc[a] = loc[b] and data[a] = finalValue[loc[a]] and data[b] != finalValue[loc[b]] => a->b not in ws }
}
pred WellFormed[rf: Write->Read, ws: Write->Write] {
    WellFormed_rf[rf] and WellFormed_ws[ws]
}

pred Uniproc[rf: Write->Read, ws: Write->Write] {
    no ^(com[rf,ws] + po_loc) & iden
}

pred Thin[rf: Write->Read] {
    no ^(rf + dp) & iden
}

pred ValidExecution[rf: Write->Read, ws: Write->Write, ppo: MemoryEvent->MemoryEvent, grf: Write->Read, ab: MemoryEvent->MemoryEvent] {
    WellFormed[rf,ws] and Uniproc[rf,ws] and Thin[rf] and (no ^(ghb[rf,ws,ppo,grf,ab]) & iden)
}
