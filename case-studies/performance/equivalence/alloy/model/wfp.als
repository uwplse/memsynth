module wfp
open program

pred WellFormedProgram {
	0 not in Write.data
	po in (proc.~proc)
	po.po in po
	no po & iden
	all disj m1, m2: MemoryEvent { proc[m1] = proc[m2] => (m1->m2 in po or m2->m1 in po) }
	no dp & iden
	dp in po & Read->MemoryEvent
	no finalValue
	no dp
	all l: Location { (no loc.l.proc) or !(one loc.l.proc) }
}

run { WellFormedProgram and some p: Processor | not (one proc.p) and not (no proc.p) }
