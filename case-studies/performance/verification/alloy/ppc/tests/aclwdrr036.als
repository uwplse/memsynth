module tests/aclwdrr036

open program
open model

/**
PPC aclwdrr036
"Fre LwSyncdWW Rfe LwSyncdRR"
Cycle=Fre LwSyncdWW Rfe LwSyncdRR
Relax=ACLwSyncdRR
Safe=Fre LwSyncdWW
{
0:r2=y; 0:r4=x;
1:r2=x; 1:r4=y;
}
 P0           | P1           ;
 li r1,1      | lwz r1,0(r2) ;
 stw r1,0(r2) | lwsync       ;
 lwsync       | lwz r3,0(r4) ;
 li r3,1      |              ;
 stw r3,0(r4) |              ;
exists
(1:r1=1 /\ 1:r3=0)


**/


one sig x, y extends Location {}

one sig P1, P2 extends Processor {}

one sig op1 extends Write {}
one sig op2 extends Lwsync {}
one sig op3 extends Write {}
one sig op4 extends Read {}
one sig op5 extends Lwsync {}
one sig op6 extends Read {}

fact {
    P1.write[1, op1, y, 1]
    P1.lwsync[2, op2]
    P1.write[3, op3, x, 1]
    P2.read[4, op4, x, 1]
    P2.lwsync[5, op5]
    P2.read[6, op6, y, 0]
}

Allowed:
    run { Allowed_PPC } for 4 int expect 1