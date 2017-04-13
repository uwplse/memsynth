module tests/bclwdww019

open program
open model

/**
PPC bclwdww019
"DpdR Fre LwSyncdWW Rfe"
Cycle=DpdR Fre LwSyncdWW Rfe
Relax=BCLwSyncdWW
Safe=Fre DpdR
{
0:r2=x; 0:r4=y;
1:r2=y; 1:r5=x;
}
 P0           | P1            ;
 li r1,1      | lwz r1,0(r2)  ;
 stw r1,0(r2) | xor r3,r1,r1  ;
 lwsync       | lwzx r4,r3,r5 ;
 li r3,1      |               ;
 stw r3,0(r4) |               ;
exists
(1:r1=1 /\ 1:r4=0)


**/


one sig x, y extends Location {}

one sig P1, P2 extends Processor {}

one sig op1 extends Write {}
one sig op2 extends Lwsync {}
one sig op3 extends Write {}
one sig op4 extends Read {}
one sig op5 extends Read {}

fact {
    P1.write[1, op1, x, 1]
    P1.lwsync[2, op2]
    P1.write[3, op3, y, 1]
    P2.read[4, op4, y, 1]
    P2.read[5, op5, x, 0] and op5.dep[op4]
}

Allowed:
    run { Allowed_PPC } for 4 int expect 1