module tests/aclwdrr025

open program
open model

/**
PPC aclwdrr025
"Fre SyncsWW Rfe LwSyncdRR Fre SyncdWW Rfe LwSyncdRR"
Cycle=Fre SyncsWW Rfe LwSyncdRR Fre SyncdWW Rfe LwSyncdRR
Relax=ACLwSyncdRR
Safe=Fre SyncsWW SyncdWW
{
0:r2=z;
1:r2=z; 1:r4=x;
2:r2=x; 2:r4=y;
3:r2=y; 3:r4=z;
}
 P0           | P1           | P2           | P3           ;
 li r1,1      | lwz r1,0(r2) | li r1,1      | lwz r1,0(r2) ;
 stw r1,0(r2) | lwsync       | stw r1,0(r2) | lwsync       ;
 sync         | lwz r3,0(r4) | sync         | lwz r3,0(r4) ;
 li r3,2      |              | li r3,1      |              ;
 stw r3,0(r2) |              | stw r3,0(r4) |              ;
exists
(z=2 /\ 1:r1=2 /\ 1:r3=0 /\ 3:r1=1 /\ 3:r3=0)


**/


one sig x, y, z extends Location {}

one sig P1, P2, P3, P4 extends Processor {}

one sig op1 extends Write {}
one sig op2 extends Sync {}
one sig op3 extends Write {}
one sig op4 extends Read {}
one sig op5 extends Lwsync {}
one sig op6 extends Read {}
one sig op7 extends Write {}
one sig op8 extends Sync {}
one sig op9 extends Write {}
one sig op10 extends Read {}
one sig op11 extends Lwsync {}
one sig op12 extends Read {}

fact {
    P1.write[1, op1, z, 1]
    P1.sync[2, op2]
    P1.write[3, op3, z, 2]
    P2.read[4, op4, z, 2]
    P2.lwsync[5, op5]
    P2.read[6, op6, x, 0]
    P3.write[7, op7, x, 1]
    P3.sync[8, op8]
    P3.write[9, op9, y, 1]
    P4.read[10, op10, y, 1]
    P4.lwsync[11, op11]
    P4.read[12, op12, z, 0]
}

fact {
    z.final[2]
}

Allowed:
    run { Allowed_PPC } for 5 int expect 0