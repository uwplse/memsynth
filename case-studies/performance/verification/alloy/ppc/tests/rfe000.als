module tests/rfe000

open program
open model

/**
PPC rfe000
"DpdW Rfe DpdW Rfe"
Cycle=DpdW Rfe DpdW Rfe
Relax=Rfe
Safe=DpdW
{
0:r2=x; 0:r5=y;
1:r2=y; 1:r5=x;
}
 P0            | P1            ;
 lwz r1,0(r2)  | lwz r1,0(r2)  ;
 xor r3,r1,r1  | xor r3,r1,r1  ;
 li r4,1       | li r4,1       ;
 stwx r4,r3,r5 | stwx r4,r3,r5 ;
exists
(0:r1=1 /\ 1:r1=1)


**/


one sig x, y extends Location {}

one sig P1, P2 extends Processor {}

one sig op1 extends Read {}
one sig op2 extends Write {}
one sig op3 extends Read {}
one sig op4 extends Write {}

fact {
    P1.read[1, op1, x, 1]
    P1.write[2, op2, y, 1] and op2.dep[op1]
    P2.read[3, op3, y, 1]
    P2.write[4, op4, x, 1] and op4.dep[op3]
}

Allowed:
    run { Allowed_PPC } for 4 int expect 0