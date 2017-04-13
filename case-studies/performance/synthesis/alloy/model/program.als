module program

abstract sig Processor {}

abstract sig Location {}
one sig SyncLoc extends Location {} -- null location used for syncs
sig Loc extends Location {}

abstract sig MemoryEvent {}

abstract sig Value {}
one sig V0 extends Value {}
