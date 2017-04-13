module tests/aclwsrr002

open program
open model

/**
PPC aclwsrr002
"DpdR Fre Rfe LwSyncsRR DpdR Fre Rfe LwSyncsRR"
Cycle=DpdR Fre Rfe LwSyncsRR DpdR Fre Rfe LwSyncsRR
Relax=ACLwSyncsRR
Safe=Fre DpdR
{
0:r2=x; 0:r6=y;
1:r2=y;
2:r2=y; 2:r6=x;
3:r2=x;
}
 P0            | P1           | P2            | P3           ;
 lwz r1,0(r2)  | li r1,1      | lwz r1,0(r2)  | li r1,1      ;
 lwsync        | stw r1,0(r2) | lwsync        | stw r1,0(r2) ;
 lwz r3,0(r2)  |              | lwz r3,0(r2)  |              ;
 xor r4,r3,r3  |              | xor r4,r3,r3  |              ;
 lwzx r5,r4,r6 |              | lwzx r5,r4,r6 |              ;
exists
(0:r1=1 /\ 0:r3=1 /\ 0:r5=0 /\ 2:r1=1 /\ 2:r3=1 /\ 2:r5=0)


**/


one sig x, y extends Location {}

one sig P1, P2, P3, P4 extends Processor {}

one sig op1 extends Read {}
one sig op2 extends Lwsync {}
one sig op3 extends Read {}
one sig op4 extends Read {}
one sig op5 extends Write {}
one sig op6 extends Read {}
one sig op7 extends Lwsync {}
one sig op8 extends Read {}
one sig op9 extends Read {}
one sig op10 extends Write {}

fact {
    P1.read[1, op1, x, 1]
    P1.lwsync[2, op2]
    P1.read[3, op3, x, 1]
    P1.read[4, op4, y, 0] and op4.dep[op3]
    P2.write[5, op5, y, 1]
    P3.read[6, op6, y, 1]
    P3.lwsync[7, op7]
    P3.read[8, op8, y, 1]
    P3.read[9, op9, x, 0] and op9.dep[op8]
    P4.write[10, op10, x, 1]
}

Allowed:
    run { Allowed_PPC } for 5 int expect 1