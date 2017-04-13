module tests/aclwdrr021

open program
open model

/**
PPC aclwdrr021
"Fre SyncdWW Wse SyncdWW Rfe LwSyncdRR"
Cycle=Fre SyncdWW Wse SyncdWW Rfe LwSyncdRR
Relax=ACLwSyncdRR
Safe=Fre Wse SyncdWW
{
0:r2=z; 0:r4=x;
1:r2=x; 1:r4=y;
2:r2=y; 2:r4=z;
}
 P0           | P1           | P2           ;
 li r1,1      | li r1,2      | lwz r1,0(r2) ;
 stw r1,0(r2) | stw r1,0(r2) | lwsync       ;
 sync         | sync         | lwz r3,0(r4) ;
 li r3,1      | li r3,1      |              ;
 stw r3,0(r4) | stw r3,0(r4) |              ;
exists
(x=2 /\ 2:r1=1 /\ 2:r3=0)


**/


one sig x, y, z extends Location {}

one sig P1, P2, P3 extends Processor {}

one sig op1 extends Write {}
one sig op2 extends Sync {}
one sig op3 extends Write {}
one sig op4 extends Write {}
one sig op5 extends Sync {}
one sig op6 extends Write {}
one sig op7 extends Read {}
one sig op8 extends Lwsync {}
one sig op9 extends Read {}

fact {
    P1.write[1, op1, z, 1]
    P1.sync[2, op2]
    P1.write[3, op3, x, 1]
    P2.write[4, op4, x, 2]
    P2.sync[5, op5]
    P2.write[6, op6, y, 1]
    P3.read[7, op7, y, 1]
    P3.lwsync[8, op8]
    P3.read[9, op9, z, 0]
}

fact {
    x.final[2]
}

Allowed:
    run { Allowed_PPC } for 5 int expect 0