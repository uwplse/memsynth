module tests/rfe001

open program
open model

/**
PPC rfe001
"DpdW Rfe DpdW Rfe DpdW Rfe"
Cycle=DpdW Rfe DpdW Rfe DpdW Rfe
Relax=Rfe
Safe=DpdW
{
0:r2=x; 0:r5=y;
1:r2=y; 1:r5=z;
2:r2=z; 2:r5=x;
}
 P0            | P1            | P2            ;
 lwz r1,0(r2)  | lwz r1,0(r2)  | lwz r1,0(r2)  ;
 xor r3,r1,r1  | xor r3,r1,r1  | xor r3,r1,r1  ;
 li r4,1       | li r4,1       | li r4,1       ;
 stwx r4,r3,r5 | stwx r4,r3,r5 | stwx r4,r3,r5 ;
exists
(0:r1=1 /\ 1:r1=1 /\ 2:r1=1)


**/


one sig x, y, z extends Location {}

one sig P1, P2, P3 extends Processor {}

one sig op1 extends Read {}
one sig op2 extends Write {}
one sig op3 extends Read {}
one sig op4 extends Write {}
one sig op5 extends Read {}
one sig op6 extends Write {}

fact {
    P1.read[1, op1, x, 1]
    P1.write[2, op2, y, 1] and op2.dep[op1]
    P2.read[3, op3, y, 1]
    P2.write[4, op4, z, 1] and op4.dep[op3]
    P3.read[5, op5, z, 1]
    P3.write[6, op6, x, 1] and op6.dep[op5]
}

Allowed:
    run { Allowed_PPC } for 4 int expect 0