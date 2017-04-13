module tests/lwdwr020

open program
open model

/**
PPC lwdwr020
"Fre LwSyncdWR Fre LwSyncdWR"
Cycle=Fre LwSyncdWR Fre LwSyncdWR
Relax=LwSyncdWR
Safe=Fre
{
0:r2=y; 0:r4=x;
1:r2=x; 1:r4=y;
}
 P0           | P1           ;
 li r1,1      | li r1,1      ;
 stw r1,0(r2) | stw r1,0(r2) ;
 lwsync       | lwsync       ;
 lwz r3,0(r4) | lwz r3,0(r4) ;
exists
(0:r3=0 /\ 1:r3=0)


**/


one sig x, y extends Location {}

one sig P1, P2 extends Processor {}

one sig op1 extends Write {}
one sig op2 extends Lwsync {}
one sig op3 extends Read {}
one sig op4 extends Write {}
one sig op5 extends Lwsync {}
one sig op6 extends Read {}

fact {
    P1.write[1, op1, y, 1]
    P1.lwsync[2, op2]
    P1.read[3, op3, x, 0]
    P2.write[4, op4, x, 1]
    P2.lwsync[5, op5]
    P2.read[6, op6, y, 0]
}

Allowed:
    run { Allowed_PPC } for 4 int expect 1