module tests/safe564

open program
open model

/**
PPC safe564
"Rfe SyncdRW Rfe SyncdRW"
Cycle=Rfe SyncdRW Rfe SyncdRW
Relax=
Safe=ACSyncdRW
{
0:r2=y; 0:r4=x;
1:r2=x; 1:r4=y;
}
 P0           | P1           ;
 lwz r1,0(r2) | lwz r1,0(r2) ;
 sync         | sync         ;
 li r3,1      | li r3,1      ;
 stw r3,0(r4) | stw r3,0(r4) ;
exists
(0:r1=1 /\ 1:r1=1)


**/


one sig x, y extends Location {}

one sig P1, P2 extends Processor {}

one sig op1 extends Read {}
one sig op2 extends Sync {}
one sig op3 extends Write {}
one sig op4 extends Read {}
one sig op5 extends Sync {}
one sig op6 extends Write {}

fact {
    P1.read[1, op1, y, 1]
    P1.sync[2, op2]
    P1.write[3, op3, x, 1]
    P2.read[4, op4, x, 1]
    P2.sync[5, op5]
    P2.write[6, op6, y, 1]
}

Allowed:
    run { Allowed_PPC } for 4 int expect 0