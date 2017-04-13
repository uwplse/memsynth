module test
open program

sig Test {
	Events: set MemoryEvent,
	Reads: set MemoryEvent,
	Writes: set MemoryEvent,
	Syncs: set MemoryEvent,
	Lwsyncs: set MemoryEvent,
	proc: MemoryEvent->lone Processor,
	loc: MemoryEvent->lone Location,
	data: MemoryEvent->lone Value,
	po: MemoryEvent->set MemoryEvent,
	dp: MemoryEvent->set MemoryEvent,
	finalValue: Location->lone Value
}
