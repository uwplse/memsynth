module tests/bclwdww000

open program
open model

/**
PPC bclwdww000
"DpdW Wse LwSyncdWW Rfe"
Cycle=DpdW Wse LwSyncdWW Rfe
Relax=BCLwSyncdWW
Safe=Wse DpdW
{
0:r2=x; 0:r4=y;
1:r2=y; 1:r5=x;
}
 P0           | P1            ;
 li r1,2      | lwz r1,0(r2)  ;
 stw r1,0(r2) | xor r3,r1,r1  ;
 lwsync       | li r4,1       ;
 li r3,1      | stwx r4,r3,r5 ;
 stw r3,0(r4) |               ;
exists
(x=2 /\ 1:r1=1)


**/


one sig x, y extends Location {}

one sig P1, P2 extends Processor {}

one sig op1 extends Write {}
one sig op2 extends Lwsync {}
one sig op3 extends Write {}
one sig op4 extends Read {}
one sig op5 extends Write {}

fact {
    P1.write[1, op1, x, 2]
    P1.lwsync[2, op2]
    P1.write[3, op3, y, 1]
    P2.read[4, op4, y, 1]
    P2.write[5, op5, x, 1] and op5.dep[op4]
}

fact {
    x.final[2]
}

Allowed:
    run { Allowed_PPC } for 4 int expect 1