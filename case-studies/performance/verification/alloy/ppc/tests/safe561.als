module tests/safe561

open program
open model

/**
PPC safe561
"Rfe SyncdRW Rfe SyncsRW Rfe SyncdRW Rfe SyncsRW"
Cycle=Rfe SyncdRW Rfe SyncsRW Rfe SyncdRW Rfe SyncsRW
Relax=
Safe=ACSyncsRW ACSyncdRW
{
0:r2=y; 0:r4=x;
1:r2=x;
2:r2=x; 2:r4=y;
3:r2=y;
}
 P0           | P1           | P2           | P3           ;
 lwz r1,0(r2) | lwz r1,0(r2) | lwz r1,0(r2) | lwz r1,0(r2) ;
 sync         | sync         | sync         | sync         ;
 li r3,1      | li r3,2      | li r3,1      | li r3,2      ;
 stw r3,0(r4) | stw r3,0(r2) | stw r3,0(r4) | stw r3,0(r2) ;
exists
(x=2 /\ y=2 /\ 0:r1=2 /\ 1:r1=1 /\ 2:r1=2 /\ 3:r1=1)


**/


one sig x, y extends Location {}

one sig P1, P2, P3, P4 extends Processor {}

one sig op1 extends Read {}
one sig op2 extends Sync {}
one sig op3 extends Write {}
one sig op4 extends Read {}
one sig op5 extends Sync {}
one sig op6 extends Write {}
one sig op7 extends Read {}
one sig op8 extends Sync {}
one sig op9 extends Write {}
one sig op10 extends Read {}
one sig op11 extends Sync {}
one sig op12 extends Write {}

fact {
    P1.read[1, op1, y, 2]
    P1.sync[2, op2]
    P1.write[3, op3, x, 1]
    P2.read[4, op4, x, 1]
    P2.sync[5, op5]
    P2.write[6, op6, x, 2]
    P3.read[7, op7, x, 2]
    P3.sync[8, op8]
    P3.write[9, op9, y, 1]
    P4.read[10, op10, y, 1]
    P4.sync[11, op11]
    P4.write[12, op12, y, 2]
}

fact {
    y.final[2]
    x.final[2]
}

Allowed:
    run { Allowed_PPC } for 5 int expect 0