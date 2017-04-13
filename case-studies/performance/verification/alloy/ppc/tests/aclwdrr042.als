module tests/aclwdrr042

open program
open model

/**
PPC aclwdrr042
"Fre SyncdWR Fre LwSyncsWW Rfe LwSyncdRR"
Cycle=Fre SyncdWR Fre LwSyncsWW Rfe LwSyncdRR
Relax=ACLwSyncdRR
Safe=Fre SyncdWR LwSyncsWW
{
0:r2=y; 0:r4=x;
1:r2=x;
2:r2=x; 2:r4=y;
}
 P0           | P1           | P2           ;
 li r1,1      | li r1,1      | lwz r1,0(r2) ;
 stw r1,0(r2) | stw r1,0(r2) | lwsync       ;
 sync         | lwsync       | lwz r3,0(r4) ;
 lwz r3,0(r4) | li r3,2      |              ;
              | stw r3,0(r2) |              ;
exists
(x=2 /\ 0:r3=0 /\ 2:r1=2 /\ 2:r3=0)


**/


one sig x, y extends Location {}

one sig P1, P2, P3 extends Processor {}

one sig op1 extends Write {}
one sig op2 extends Sync {}
one sig op3 extends Read {}
one sig op4 extends Write {}
one sig op5 extends Lwsync {}
one sig op6 extends Write {}
one sig op7 extends Read {}
one sig op8 extends Lwsync {}
one sig op9 extends Read {}

fact {
    P1.write[1, op1, y, 1]
    P1.sync[2, op2]
    P1.read[3, op3, x, 0]
    P2.write[4, op4, x, 1]
    P2.lwsync[5, op5]
    P2.write[6, op6, x, 2]
    P3.read[7, op7, x, 2]
    P3.lwsync[8, op8]
    P3.read[9, op9, y, 0]
}

fact {
    x.final[2]
}

Allowed:
    run { Allowed_PPC } for 5 int expect 1