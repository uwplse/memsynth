module tests/bclwdww030

open program
open model

/**
PPC bclwdww030
"LwSyncsRR Fre LwSyncdWW Rfe LwSyncsRR Fre LwSyncdWW Rfe"
Cycle=LwSyncsRR Fre LwSyncdWW Rfe LwSyncsRR Fre LwSyncdWW Rfe
Relax=BCLwSyncdWW
Safe=Fre LwSyncsRR
{
0:r2=y; 0:r4=x;
1:r2=x;
2:r2=x; 2:r4=y;
3:r2=y;
}
 P0           | P1           | P2           | P3           ;
 li r1,2      | lwz r1,0(r2) | li r1,2      | lwz r1,0(r2) ;
 stw r1,0(r2) | lwsync       | stw r1,0(r2) | lwsync       ;
 lwsync       | lwz r3,0(r2) | lwsync       | lwz r3,0(r2) ;
 li r3,1      |              | li r3,1      |              ;
 stw r3,0(r4) |              | stw r3,0(r4) |              ;
exists
(x=2 /\ y=2 /\ 1:r1=1 /\ 1:r3=1 /\ 3:r1=1 /\ 3:r3=1)


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
one sig op8 extends Lwsync {}
one sig op9 extends Write {}
one sig op10 extends Read {}
one sig op11 extends Lwsync {}
one sig op12 extends Read {}

fact {
    P1.write[1, op1, y, 2]
    P1.lwsync[2, op2]
    P1.write[3, op3, x, 1]
    P2.read[4, op4, x, 1]
    P2.lwsync[5, op5]
    P2.read[6, op6, x, 1]
    P3.write[7, op7, x, 2]
    P3.lwsync[8, op8]
    P3.write[9, op9, y, 1]
    P4.read[10, op10, y, 1]
    P4.lwsync[11, op11]
    P4.read[12, op12, y, 1]
}

fact {
    y.final[2]
    x.final[2]
}

Allowed:
    run { Allowed_PPC } for 5 int expect 0