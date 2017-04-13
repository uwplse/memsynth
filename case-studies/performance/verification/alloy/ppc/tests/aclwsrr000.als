module tests/aclwsrr000

open program
open model

/**
PPC aclwsrr000
"DpdR Fre SyncdWW Wse Rfe LwSyncsRR"
Cycle=DpdR Fre SyncdWW Wse Rfe LwSyncsRR
Relax=ACLwSyncsRR
Safe=Fre Wse SyncdWW DpdR
{
0:r2=x; 0:r4=y;
1:r2=y;
2:r2=y; 2:r6=x;
}
 P0           | P1           | P2            ;
 li r1,1      | li r1,2      | lwz r1,0(r2)  ;
 stw r1,0(r2) | stw r1,0(r2) | lwsync        ;
 sync         |              | lwz r3,0(r2)  ;
 li r3,1      |              | xor r4,r3,r3  ;
 stw r3,0(r4) |              | lwzx r5,r4,r6 ;
exists
(y=2 /\ 2:r1=2 /\ 2:r3=2 /\ 2:r5=0)


**/


one sig x, y extends Location {}

one sig P1, P2, P3 extends Processor {}

one sig op1 extends Write {}
one sig op2 extends Sync {}
one sig op3 extends Write {}
one sig op4 extends Write {}
one sig op5 extends Read {}
one sig op6 extends Lwsync {}
one sig op7 extends Read {}
one sig op8 extends Read {}

fact {
    P1.write[1, op1, x, 1]
    P1.sync[2, op2]
    P1.write[3, op3, y, 1]
    P2.write[4, op4, y, 2]
    P3.read[5, op5, y, 2]
    P3.lwsync[6, op6]
    P3.read[7, op7, y, 2]
    P3.read[8, op8, x, 0] and op8.dep[op7]
}

fact {
    y.final[2]
}

Allowed:
    run { Allowed_PPC } for 5 int expect 1