module tests/podrwposwr019

open program
open model

/**
PPC podrwposwr019
"Fre SyncdWW Rfe PodRW PosWR"
Cycle=Fre SyncdWW Rfe PodRW PosWR
Relax=[PodRW,PosWR]
Safe=Fre BCSyncdWW
{
0:r2=y; 0:r4=x;
1:r2=x; 1:r4=y;
}
 P0           | P1           ;
 li r1,2      | lwz r1,0(r2) ;
 stw r1,0(r2) | li r3,1      ;
 sync         | stw r3,0(r4) ;
 li r3,1      | lwz r5,0(r4) ;
 stw r3,0(r4) |              ;
exists
(y=2 /\ 1:r1=1 /\ 1:r5=1)


**/


one sig x, y extends Location {}

one sig P1, P2 extends Processor {}

one sig op1 extends Write {}
one sig op2 extends Sync {}
one sig op3 extends Write {}
one sig op4 extends Read {}
one sig op5 extends Write {}
one sig op6 extends Read {}

fact {
    P1.write[1, op1, y, 2]
    P1.sync[2, op2]
    P1.write[3, op3, x, 1]
    P2.read[4, op4, x, 1]
    P2.write[5, op5, y, 1]
    P2.read[6, op6, y, 1]
}

fact {
    y.final[2]
}

Allowed:
    run { Allowed_PPC } for 4 int expect 1