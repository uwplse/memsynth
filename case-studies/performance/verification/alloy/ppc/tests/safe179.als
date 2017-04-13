module tests/safe179

open program
open model

/**
PPC safe179
"LwSyncdWW Rfe SyncdRW Rfe SyncsRR Fre LwSyncdWW Wse"
Cycle=LwSyncdWW Rfe SyncdRW Rfe SyncsRR Fre LwSyncdWW Wse
Relax=
Safe=Fre Wse LwSyncdWW ACSyncsRR ACSyncdRW
{
0:r2=x; 0:r4=y;
1:r2=y;
2:r2=y; 2:r4=z;
3:r2=z; 3:r4=x;
}
 P0           | P1           | P2           | P3           ;
 lwz r1,0(r2) | lwz r1,0(r2) | li r1,2      | li r1,2      ;
 sync         | sync         | stw r1,0(r2) | stw r1,0(r2) ;
 li r3,1      | lwz r3,0(r2) | lwsync       | lwsync       ;
 stw r3,0(r4) |              | li r3,1      | li r3,1      ;
              |              | stw r3,0(r4) | stw r3,0(r4) ;
exists
(y=2 /\ z=2 /\ 0:r1=1 /\ 1:r1=1 /\ 1:r3=1)


**/


one sig x, y, z extends Location {}

one sig P1, P2, P3, P4 extends Processor {}

one sig op1 extends Read {}
one sig op2 extends Sync {}
one sig op3 extends Write {}
one sig op4 extends Read {}
one sig op5 extends Sync {}
one sig op6 extends Read {}
one sig op7 extends Write {}
one sig op8 extends Lwsync {}
one sig op9 extends Write {}
one sig op10 extends Write {}
one sig op11 extends Lwsync {}
one sig op12 extends Write {}

fact {
    P1.read[1, op1, x, 1]
    P1.sync[2, op2]
    P1.write[3, op3, y, 1]
    P2.read[4, op4, y, 1]
    P2.sync[5, op5]
    P2.read[6, op6, y, 1]
    P3.write[7, op7, y, 2]
    P3.lwsync[8, op8]
    P3.write[9, op9, z, 1]
    P4.write[10, op10, z, 2]
    P4.lwsync[11, op11]
    P4.write[12, op12, x, 1]
}

fact {
    y.final[2]
    z.final[2]
}

Allowed:
    run { Allowed_PPC } for 5 int expect 0