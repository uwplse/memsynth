module tests/podwr001

open program
open model

/**
PPC podwr001
"Fre PodWR Fre PodWR Fre PodWR"
Cycle=Fre PodWR Fre PodWR Fre PodWR
Relax=PodWR
Safe=Fre
{
0:r2=z; 0:r4=x;
1:r2=x; 1:r4=y;
2:r2=y; 2:r4=z;
}
 P0           | P1           | P2           ;
 li r1,1      | li r1,1      | li r1,1      ;
 stw r1,0(r2) | stw r1,0(r2) | stw r1,0(r2) ;
 lwz r3,0(r4) | lwz r3,0(r4) | lwz r3,0(r4) ;
exists
(0:r3=0 /\ 1:r3=0 /\ 2:r3=0)


**/


one sig x, y, z extends Location {}

one sig P1, P2, P3 extends Processor {}

one sig op1 extends Write {}
one sig op2 extends Read {}
one sig op3 extends Write {}
one sig op4 extends Read {}
one sig op5 extends Write {}
one sig op6 extends Read {}

fact {
    P1.write[1, op1, z, 1]
    P1.read[2, op2, x, 0]
    P2.write[3, op3, x, 1]
    P2.read[4, op4, y, 0]
    P3.write[5, op5, y, 1]
    P3.read[6, op6, z, 0]
}

Allowed:
    run { Allowed_PPC } for 4 int expect 1