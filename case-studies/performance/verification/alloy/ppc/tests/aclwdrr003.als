module tests/aclwdrr003

open program
open model

/**
PPC aclwdrr003
"Fre SyncdWR Fre SyncdWW Wse Rfe LwSyncdRR"
Cycle=Fre SyncdWR Fre SyncdWW Wse Rfe LwSyncdRR
Relax=ACLwSyncdRR
Safe=Fre Wse SyncdWW SyncdWR
{
0:r2=z; 0:r4=x;
1:r2=x; 1:r4=y;
2:r2=y;
3:r2=y; 3:r4=z;
}
 P0           | P1           | P2           | P3           ;
 li r1,1      | li r1,1      | li r1,2      | lwz r1,0(r2) ;
 stw r1,0(r2) | stw r1,0(r2) | stw r1,0(r2) | lwsync       ;
 sync         | sync         |              | lwz r3,0(r4) ;
 lwz r3,0(r4) | li r3,1      |              |              ;
              | stw r3,0(r4) |              |              ;
exists
(y=2 /\ 0:r3=0 /\ 3:r1=2 /\ 3:r3=0)


**/


one sig x, y, z extends Location {}

one sig P1, P2, P3, P4 extends Processor {}

one sig op1 extends Write {}
one sig op2 extends Sync {}
one sig op3 extends Read {}
one sig op4 extends Write {}
one sig op5 extends Sync {}
one sig op6 extends Write {}
one sig op7 extends Write {}
one sig op8 extends Read {}
one sig op9 extends Lwsync {}
one sig op10 extends Read {}

fact {
    P1.write[1, op1, z, 1]
    P1.sync[2, op2]
    P1.read[3, op3, x, 0]
    P2.write[4, op4, x, 1]
    P2.sync[5, op5]
    P2.write[6, op6, y, 1]
    P3.write[7, op7, y, 2]
    P4.read[8, op8, y, 2]
    P4.lwsync[9, op9]
    P4.read[10, op10, z, 0]
}

fact {
    y.final[2]
}

Allowed:
    run { Allowed_PPC } for 5 int expect 1