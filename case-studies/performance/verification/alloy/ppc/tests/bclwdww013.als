module tests/bclwdww013

open program
open model

/**
PPC bclwdww013
"LwSyncdRW Wse LwSyncdWW Rfe"
Cycle=LwSyncdRW Wse LwSyncdWW Rfe
Relax=BCLwSyncdWW
Safe=Wse LwSyncdRW
{
0:r2=x; 0:r4=y;
1:r2=y; 1:r4=x;
}
 P0           | P1           ;
 li r1,2      | lwz r1,0(r2) ;
 stw r1,0(r2) | lwsync       ;
 lwsync       | li r3,1      ;
 li r3,1      | stw r3,0(r4) ;
 stw r3,0(r4) |              ;
exists
(x=2 /\ 1:r1=1)


**/


one sig x, y extends Location {}

one sig P1, P2 extends Processor {}

one sig op1 extends Write {}
one sig op2 extends Lwsync {}
one sig op3 extends Write {}
one sig op4 extends Read {}
one sig op5 extends Lwsync {}
one sig op6 extends Write {}

fact {
    P1.write[1, op1, x, 2]
    P1.lwsync[2, op2]
    P1.write[3, op3, y, 1]
    P2.read[4, op4, y, 1]
    P2.lwsync[5, op5]
    P2.write[6, op6, x, 1]
}

fact {
    x.final[2]
}

Allowed:
    run { Allowed_PPC } for 4 int expect 0