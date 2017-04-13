module tests/podww000

open program
open model

/**
PPC podww000
"Wse PodWW Wse PodWW"
Cycle=Wse PodWW Wse PodWW
Relax=PodWW
Safe=Wse
{
0:r2=y; 0:r4=x;
1:r2=x; 1:r4=y;
}
 P0           | P1           ;
 li r1,2      | li r1,2      ;
 stw r1,0(r2) | stw r1,0(r2) ;
 li r3,1      | li r3,1      ;
 stw r3,0(r4) | stw r3,0(r4) ;
exists
(x=2 /\ y=2)


**/


one sig x, y extends Location {}

one sig P1, P2 extends Processor {}

one sig op1 extends Write {}
one sig op2 extends Write {}
one sig op3 extends Write {}
one sig op4 extends Write {}

fact {
    P1.write[1, op1, y, 2]
    P1.write[2, op2, x, 1]
    P2.write[3, op3, x, 2]
    P2.write[4, op4, y, 1]
}

fact {
    y.final[2]
    x.final[2]
}

Allowed:
    run { Allowed_PPC } for 4 int expect 1