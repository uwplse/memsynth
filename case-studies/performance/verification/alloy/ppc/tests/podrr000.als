module tests/podrr000

open program
open model

/**
PPC podrr000
"Fre SyncdWW Rfe PodRR"
Cycle=Fre SyncdWW Rfe PodRR
Relax=PodRR
Safe=Fre BCSyncdWW
{
0:r2=y; 0:r4=x;
1:r2=x; 1:r4=y;
}
 P0           | P1           ;
 li r1,1      | lwz r1,0(r2) ;
 stw r1,0(r2) | lwz r3,0(r4) ;
 sync         |              ;
 li r3,1      |              ;
 stw r3,0(r4) |              ;
exists
(1:r1=1 /\ 1:r3=0)


**/


one sig x, y extends Location {}

one sig P1, P2 extends Processor {}

one sig op1 extends Write {}
one sig op2 extends Sync {}
one sig op3 extends Write {}
one sig op4 extends Read {}
one sig op5 extends Read {}

fact {
    P1.write[1, op1, y, 1]
    P1.sync[2, op2]
    P1.write[3, op3, x, 1]
    P2.read[4, op4, x, 1]
    P2.read[5, op5, y, 0]
}

Allowed:
    run { Allowed_PPC } for 4 int expect 1