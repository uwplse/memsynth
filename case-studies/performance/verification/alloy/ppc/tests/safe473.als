module tests/safe473

open program
open model

/**
PPC safe473
"SyncdWW Rfe LwSyncsRR Fre SyncdWW Rfe LwSyncsRR Fre"
Cycle=SyncdWW Rfe LwSyncsRR Fre SyncdWW Rfe LwSyncsRR Fre
Relax=
Safe=Fre LwSyncsRR BCSyncdWW
{
0:r2=x;
1:r2=x; 1:r4=y;
2:r2=y;
3:r2=y; 3:r4=x;
}
 P0           | P1           | P2           | P3           ;
 lwz r1,0(r2) | li r1,2      | lwz r1,0(r2) | li r1,2      ;
 lwsync       | stw r1,0(r2) | lwsync       | stw r1,0(r2) ;
 lwz r3,0(r2) | sync         | lwz r3,0(r2) | sync         ;
              | li r3,1      |              | li r3,1      ;
              | stw r3,0(r4) |              | stw r3,0(r4) ;
exists
(x=2 /\ y=2 /\ 0:r1=1 /\ 0:r3=1 /\ 2:r1=1 /\ 2:r3=1)


**/


one sig x, y extends Location {}

one sig P1, P2, P3, P4 extends Processor {}

one sig op1 extends Read {}
one sig op2 extends Lwsync {}
one sig op3 extends Read {}
one sig op4 extends Write {}
one sig op5 extends Sync {}
one sig op6 extends Write {}
one sig op7 extends Read {}
one sig op8 extends Lwsync {}
one sig op9 extends Read {}
one sig op10 extends Write {}
one sig op11 extends Sync {}
one sig op12 extends Write {}

fact {
    P1.read[1, op1, x, 1]
    P1.lwsync[2, op2]
    P1.read[3, op3, x, 1]
    P2.write[4, op4, x, 2]
    P2.sync[5, op5]
    P2.write[6, op6, y, 1]
    P3.read[7, op7, y, 1]
    P3.lwsync[8, op8]
    P3.read[9, op9, y, 1]
    P4.write[10, op10, y, 2]
    P4.sync[11, op11]
    P4.write[12, op12, x, 1]
}

fact {
    y.final[2]
    x.final[2]
}

Allowed:
    run { Allowed_PPC } for 5 int expect 0