module tests/rfe002

open program
open model

/**
PPC rfe002
"DpdW Wse Rfe DpdW Rfe"
Cycle=DpdW Wse Rfe DpdW Rfe
Relax=Rfe
Safe=Wse DpdW
{
0:r2=x; 0:r5=y;
1:r2=y; 1:r5=x;
2:r2=x;
}
 P0            | P1            | P2           ;
 lwz r1,0(r2)  | lwz r1,0(r2)  | li r1,2      ;
 xor r3,r1,r1  | xor r3,r1,r1  | stw r1,0(r2) ;
 li r4,1       | li r4,1       |              ;
 stwx r4,r3,r5 | stwx r4,r3,r5 |              ;
exists
(x=2 /\ 0:r1=2 /\ 1:r1=1)


**/


one sig x, y extends Location {}

one sig P1, P2, P3 extends Processor {}

one sig op1 extends Read {}
one sig op2 extends Write {}
one sig op3 extends Read {}
one sig op4 extends Write {}
one sig op5 extends Write {}

fact {
    P1.read[1, op1, x, 2]
    P1.write[2, op2, y, 1] and op2.dep[op1]
    P2.read[3, op3, y, 1]
    P2.write[4, op4, x, 1] and op4.dep[op3]
    P3.write[5, op5, x, 2]
}

fact {
    x.final[2]
}

Allowed:
    run { Allowed_PPC } for 4 int expect 1