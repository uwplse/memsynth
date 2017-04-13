module tests/aclwdrr032

open program
open model

/**
PPC aclwdrr032
"Fre LwSyncsWW Rfe LwSyncdRR Fre SyncsWW Rfe LwSyncdRR"
Cycle=Fre LwSyncsWW Rfe LwSyncdRR Fre SyncsWW Rfe LwSyncdRR
Relax=ACLwSyncdRR
Safe=Fre SyncsWW LwSyncsWW
{
0:r2=y;
1:r2=y; 1:r4=x;
2:r2=x;
3:r2=x; 3:r4=y;
}
 P0           | P1           | P2           | P3           ;
 li r1,1      | lwz r1,0(r2) | li r1,1      | lwz r1,0(r2) ;
 stw r1,0(r2) | lwsync       | stw r1,0(r2) | lwsync       ;
 lwsync       | lwz r3,0(r4) | sync         | lwz r3,0(r4) ;
 li r3,2      |              | li r3,2      |              ;
 stw r3,0(r2) |              | stw r3,0(r2) |              ;
exists
(x=2 /\ y=2 /\ 1:r1=2 /\ 1:r3=0 /\ 3:r1=2 /\ 3:r3=0)


**/


one sig x, y extends Location {}

one sig P1, P2, P3, P4 extends Processor {}

one sig op1 extends Write {}
one sig op2 extends Lwsync {}
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
    P1.write[1, op1, y, 1]
    P1.lwsync[2, op2]
    P1.write[3, op3, y, 2]
    P2.read[4, op4, y, 2]
    P2.lwsync[5, op5]
    P2.read[6, op6, x, 0]
    P3.write[7, op7, x, 1]
    P3.sync[8, op8]
    P3.write[9, op9, x, 2]
    P4.read[10, op10, x, 2]
    P4.lwsync[11, op11]
    P4.read[12, op12, y, 0]
}

fact {
    y.final[2]
    x.final[2]
}

Allowed:
    run { Allowed_PPC } for 5 int expect 1