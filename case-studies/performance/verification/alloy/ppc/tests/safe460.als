module tests/safe460

open program
open model

/**
PPC safe460
"SyncdWW Rfe LwSyncdRR Fre"
Cycle=SyncdWW Rfe LwSyncdRR Fre
Relax=
Safe=Fre LwSyncdRR BCSyncdWW
{
0:r2=x; 0:r4=y;
1:r2=y; 1:r4=x;
}
 P0           | P1           ;
 lwz r1,0(r2) | li r1,1      ;
 lwsync       | stw r1,0(r2) ;
 lwz r3,0(r4) | sync         ;
              | li r3,1      ;
              | stw r3,0(r4) ;
exists
(0:r1=1 /\ 0:r3=0)


**/


one sig x, y extends Location {}

one sig P1, P2 extends Processor {}

one sig op1 extends Read {}
one sig op2 extends Lwsync {}
one sig op3 extends Read {}
one sig op4 extends Write {}
one sig op5 extends Sync {}
one sig op6 extends Write {}

fact {
    P1.read[1, op1, x, 1]
    P1.lwsync[2, op2]
    P1.read[3, op3, y, 0]
    P2.write[4, op4, y, 1]
    P2.sync[5, op5]
    P2.write[6, op6, x, 1]
}

Allowed:
    run { Allowed_PPC } for 4 int expect 0