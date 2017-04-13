module tests/safe197

open program
open model

/**
PPC safe197
"SyncdWR Fre SyncdWW Rfe SyncsRW Rfe LwSyncdRW Wse"
Cycle=SyncdWR Fre SyncdWW Rfe SyncsRW Rfe LwSyncdRW Wse
Relax=
Safe=Fre Wse SyncdWR LwSyncdRW BCSyncsRW BCSyncdWW
{
0:r2=x; 0:r4=y;
1:r2=y;
2:r2=y; 2:r4=z;
3:r2=z; 3:r4=x;
}
 P0           | P1           | P2           | P3           ;
 li r1,1      | lwz r1,0(r2) | lwz r1,0(r2) | li r1,2      ;
 stw r1,0(r2) | sync         | lwsync       | stw r1,0(r2) ;
 sync         | li r3,2      | li r3,1      | sync         ;
 li r3,1      | stw r3,0(r2) | stw r3,0(r4) | lwz r3,0(r4) ;
 stw r3,0(r4) |              |              |              ;
exists
(y=2 /\ z=2 /\ 1:r1=1 /\ 2:r1=2 /\ 3:r3=0)


**/


one sig x, y, z extends Location {}

one sig P1, P2, P3, P4 extends Processor {}

one sig op1 extends Write {}
one sig op2 extends Sync {}
one sig op3 extends Write {}
one sig op4 extends Read {}
one sig op5 extends Sync {}
one sig op6 extends Write {}
one sig op7 extends Read {}
one sig op8 extends Lwsync {}
one sig op9 extends Write {}
one sig op10 extends Write {}
one sig op11 extends Sync {}
one sig op12 extends Read {}

fact {
    P1.write[1, op1, x, 1]
    P1.sync[2, op2]
    P1.write[3, op3, y, 1]
    P2.read[4, op4, y, 1]
    P2.sync[5, op5]
    P2.write[6, op6, y, 2]
    P3.read[7, op7, y, 2]
    P3.lwsync[8, op8]
    P3.write[9, op9, z, 1]
    P4.write[10, op10, z, 2]
    P4.sync[11, op11]
    P4.read[12, op12, x, 0]
}

fact {
    y.final[2]
    z.final[2]
}

Allowed:
    run { Allowed_PPC } for 5 int expect 0