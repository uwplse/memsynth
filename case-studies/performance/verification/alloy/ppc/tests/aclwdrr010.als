module tests/aclwdrr010

open program
open model

/**
PPC aclwdrr010
"Fre Rfe LwSyncdRR Fre Rfe LwSyncdRR"
Cycle=Fre Rfe LwSyncdRR Fre Rfe LwSyncdRR
Relax=ACLwSyncdRR
Safe=Fre
{
0:r2=y; 0:r4=x;
1:r2=x;
2:r2=x; 2:r4=y;
3:r2=y;
}
 P0           | P1           | P2           | P3           ;
 lwz r1,0(r2) | li r1,1      | lwz r1,0(r2) | li r1,1      ;
 lwsync       | stw r1,0(r2) | lwsync       | stw r1,0(r2) ;
 lwz r3,0(r4) |              | lwz r3,0(r4) |              ;
exists
(0:r1=1 /\ 0:r3=0 /\ 2:r1=1 /\ 2:r3=0)


**/


one sig x, y extends Location {}

one sig P1, P2, P3, P4 extends Processor {}

one sig op1 extends Read {}
one sig op2 extends Lwsync {}
one sig op3 extends Read {}
one sig op4 extends Write {}
one sig op5 extends Read {}
one sig op6 extends Lwsync {}
one sig op7 extends Read {}
one sig op8 extends Write {}

fact {
    P1.read[1, op1, y, 1]
    P1.lwsync[2, op2]
    P1.read[3, op3, x, 0]
    P2.write[4, op4, x, 1]
    P3.read[5, op5, x, 1]
    P3.lwsync[6, op6]
    P3.read[7, op7, y, 0]
    P4.write[8, op8, y, 1]
}

Allowed:
    run { Allowed_PPC } for 5 int expect 1