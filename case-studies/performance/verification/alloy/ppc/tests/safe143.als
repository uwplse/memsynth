module tests/safe143

open program
open model

/**
PPC safe143
"Rfe SyncdRW Wse LwSyncdWW Wse"
Cycle=Rfe SyncdRW Wse LwSyncdWW Wse
Relax=
Safe=Wse LwSyncdWW ACSyncdRW
{
0:r2=y; 0:r4=x;
1:r2=x; 1:r4=y;
2:r2=y;
}
 P0           | P1           | P2           ;
 lwz r1,0(r2) | li r1,2      | li r1,2      ;
 sync         | stw r1,0(r2) | stw r1,0(r2) ;
 li r3,1      | lwsync       |              ;
 stw r3,0(r4) | li r3,1      |              ;
              | stw r3,0(r4) |              ;
exists
(x=2 /\ y=2 /\ 0:r1=2)


**/


one sig x, y extends Location {}

one sig P1, P2, P3 extends Processor {}

one sig op1 extends Read {}
one sig op2 extends Sync {}
one sig op3 extends Write {}
one sig op4 extends Write {}
one sig op5 extends Lwsync {}
one sig op6 extends Write {}
one sig op7 extends Write {}

fact {
    P1.read[1, op1, y, 2]
    P1.sync[2, op2]
    P1.write[3, op3, x, 1]
    P2.write[4, op4, x, 2]
    P2.lwsync[5, op5]
    P2.write[6, op6, y, 1]
    P3.write[7, op7, y, 2]
}

fact {
    y.final[2]
    x.final[2]
}

Allowed:
    run { Allowed_PPC } for 4 int expect 0