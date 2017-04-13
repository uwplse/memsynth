module program

abstract sig Processor {}

abstract sig Location {
	finalValue: lone Int -- which value wins?
}
one sig SyncLoc extends Location {} -- null location used for syncs
sig Loc extends Location {}

abstract sig MemoryEvent {
	proc: one Processor,
	pc: one Int,
	loc: one Location,
	data: one Int,
	po: set MemoryEvent,
	dp: set MemoryEvent,  -- x->y in dep == y depends on x
}

abstract sig Write extends MemoryEvent {}

abstract sig Read extends MemoryEvent {}

abstract sig Barrier extends MemoryEvent {}

abstract sig Sync extends Barrier {}
abstract sig Lwsync extends Barrier {}



-- Create the program order relation for Alglave
fact {
	po = {e1, e2: MemoryEvent | pc[e1] < pc[e2] and proc[e1] = proc[e2]}
}

-- shorthand for writing programs
pred memOp[p: Processor, c: Int, op: MemoryEvent, var: Location, d: Int] {
	proc[op] = p and pc[op] = c and loc[op] = var and data[op] = d
}
pred Processor.write[c: Int, op: Write, var: Location, d: Int] {
	memOp[this, c, op, var, d]
}
pred Processor.read[c: Int, op: Read, var: Location, d: Int] {
	memOp[this, c, op, var, d]
}
pred Processor.sync[c: Int, op: Sync] {
	memOp[this, c, op, SyncLoc, 0]
}
pred Processor.lwsync[c: Int, op: Lwsync] {
	memOp[this, c, op, SyncLoc, 0]
}
-- op1.dep[op2] == op1 depends on op2 == op2->op1 in dep
pred MemoryEvent.dep[other: MemoryEvent] {
	other->this in dp
}

pred Location.final[c: Int] {
	this.finalValue = c
}
