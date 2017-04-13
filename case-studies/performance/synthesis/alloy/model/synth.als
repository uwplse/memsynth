module synth
open framework
open model
open sketch
open test

one sig x, y, z extends Location {}

one sig P1, P2, P3, P4 extends Processor {}

one sig op1, op2, op3, op4, op5, op6 extends MemoryEvent {}

one sig V1 extends Value {}


/* x86/8-1 */
one sig x86_81 extends Test{}
fact {
	x86_81.Events = op1 + op2 + op3 + op4
	x86_81.Reads = op3 + op4
	x86_81.Writes = op1 + op2
	no x86_81.Syncs
	no x86_81.Lwsyncs
	x86_81.proc = (op1+op2)->P1 + (op3+op4)->P2
	x86_81.loc = (op1+op4)->x + (op2+op3)->y
	x86_81.data = (op1+op2+op3)->V1 + op4->V0
	x86_81.po = op1->op2 + op3->op4
	no x86_81.dp
	no x86_81.finalValue
}
-- run TSO_Forbids_x86_81 { Allowed_Sketch[x86_81, TSO] } expect 0

/* x86/8-3 */
one sig x86_83 extends Test{}
fact {
	x86_83.Events = op1 + op2 + op3 + op4
	x86_83.Reads = op2 + op4
	x86_83.Writes = op1 + op3
	no x86_83.Syncs
	no x86_83.Lwsyncs
	x86_83.proc = (op1+op2)->P1 + (op3+op4)->P2
	x86_83.loc = (op1+op4)->x + (op2+op3)->y
	x86_83.data = (op1+op3)->V1 + (op2+op4)->V0
	x86_83.po = op1->op2 + op3->op4
	no x86_83.dp
	no x86_83.finalValue
}
-- run TSO_Allows_x86_83 { Allowed_Sketch[x86_83, TSO] } expect 1

/* x86/8-5 */
one sig x86_85 extends Test{}
fact {
	x86_85.Events = op1 + op2 + op3 + op4 + op5 + op6
	x86_85.Reads = op2 + op3 + op5 + op6
	x86_85.Writes = op1 + op4
	no x86_85.Syncs
	no x86_85.Lwsyncs
	x86_85.proc = (op1+op2+op3)->P1 + (op4+op5+op6)->P2
	x86_85.loc = (op1+op2+op6)->x + (op3+op4+op5)->y
	x86_85.data = (op1+op2+op4+op5)->V1 + (op3+op6)->V0
	x86_85.po = op1->op2 + op1->op3 + op2->op3 + op4->op5 + op5->op6 + op4->op6
	no x86_85.dp
	no x86_85.finalValue
}
-- run TSO_Allows_X86_85 { Allowed_Sketch[x86_85, TSO] } expect 1



-- Try synthesis with only SC or TSO
run Synthesis_SC_TSO { 
	some s: one Model {
		-- Try to synthesize TSO, which allows 8-3 and 8-5 but forbids 8-1
		(s = SC or s = TSO)
		not Allowed_Sketch[x86_81, s]
		and Allowed_Sketch[x86_83, s]
		and Allowed_Sketch[x86_85, s]
	}
} expect 1

-- Try synthesis with SC or TSO os PSO
run Synthesis_SC_TSO_PSO { 
	some s: one Model {
		-- Try to synthesize TSO, which allows 8-3 and 8-5 but forbids 8-1
		(s = SC or s = TSO or s = PSO)
		not Allowed_Sketch[x86_81, s]
		and Allowed_Sketch[x86_83, s]
		and Allowed_Sketch[x86_85, s]
	}
} expect 1

