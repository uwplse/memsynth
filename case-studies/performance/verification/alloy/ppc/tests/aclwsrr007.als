module tests/aclwsrr007

open program
open model

/**
PPC aclwsrr007
"DpdR Fre SyncdWW Rfe LwSyncsRR"
Cycle=DpdR Fre SyncdWW Rfe LwSyncsRR
Relax=ACLwSyncsRR
Safe=Fre SyncdWW DpdR
{
0:r2=x; 0:r4=y;
1:r2=y; 1:r6=x;
}
 P0           | P1            ;
 li r1,1      | lwz r1,0(r2)  ;
 stw r1,0(r2) | lwsync        ;
 sync         | lwz r3,0(r2)  ;
 li r3,1      | xor r4,r3,r3  ;
 stw r3,0(r4) | lwzx r5,r4,r6 ;
exists
(1:r1=1 /\ 1:r3=1 /\ 1:r5=0)


**/


one sig x, y extends Location {}

one sig P1, P2 extends Processor {}

one sig op1 extends Write {}
one sig op2 extends Sync {}
one sig op3 extends Write {}
one sig op4 extends Read {}
one sig op5 extends Lwsync {}
one sig op6 extends Read {}
one sig op7 extends Read {}

fact {
    P1.write[1, op1, x, 1]
    P1.sync[2, op2]
    P1.write[3, op3, y, 1]
    P2.read[4, op4, y, 1]
    P2.lwsync[5, op5]
    P2.read[6, op6, y, 1]
    P2.read[7, op7, x, 0] and op7.dep[op6]
}

Allowed:
    run { Allowed_PPC } for 4 int expect 0