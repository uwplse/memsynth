module alglave
open program
open framework

/* SC */
pred Allowed_SC {
	some rf: Write->Read, ws: Write->Write |
		ValidExecution[rf, ws, po, rf, none->none]
}

/* TSO */
pred Allowed_TSO {
	let TSO_ppo = po & (Read->MemoryEvent + Write->Write) |
		some rf: Write->Read, ws: Write->Write |
			ValidExecution[rf, ws, TSO_ppo, rfe[rf], none->none]
}

/* PSO */
pred Allowed_PSO {
	let PSO_ppo = po & Read->MemoryEvent |
		some rf: Write->Read, ws: Write->Write |
			ValidExecution[rf, ws, PSO_ppo, rfe[rf], none->none]
}

/* Alpha */
pred Allowed_Alpha {
	let Alpha_ppo = po & (loc.~loc & (Read->Read)) |
		some rf: Write->Read, ws: Write->Write |
			ValidExecution[rf, ws, Alpha_ppo, rfe[rf], none->none]
}

/* RMO */
pred Allowed_RMO {
	let RMO_ppo = po & dp |
		some rf: Write->Read, ws: Write->Write |
			ValidExecution[rf, ws, RMO_ppo, rfe[rf], none->none]
}


/* PPC */
fun ab_sync[rf: Write->Read] : MemoryEvent->MemoryEvent {
	let sync = (po :> Sync).po |
		^(sync + sync.rf + rf.sync)
}
fun ab_lwsync[rf: Write->Read] : MemoryEvent->MemoryEvent {
	let lwsync = (po :> Lwsync).po & (Write->Write + Read->MemoryEvent) |
		^(lwsync + (rf.lwsync :> Write) + (Read <: lwsync.rf))
}
fun ab_ppc[rf: Write->Read] : MemoryEvent->MemoryEvent {
	ab_sync[rf] + ab_lwsync[rf]
}

fun ppo_ppc[] : MemoryEvent->MemoryEvent {
    po & dp
}
pred Allowed_PPC {
    some rf: Write->Read, ws: Write->Write |
        ValidExecution[rf, ws, ppo_ppc, none->none, ab_ppc[rf]]
}



-- check models for vacuity
run { Allowed_SC }  
run { Allowed_TSO }
run { Allowed_PSO }
run { Allowed_Alpha }
run { Allowed_RMO }
run { Allowed_PPC }
