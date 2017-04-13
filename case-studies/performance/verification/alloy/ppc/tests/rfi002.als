module tests/rfi002

open program
open model

/**
PPC rfi002
"DpdW Wse Rfi DpdW Wse Rfi"
Cycle=DpdW Wse Rfi DpdW Wse Rfi
Relax=Rfi
Safe=Wse DpdW
{
0:r2=x; 0:r6=y;
1:r2=y; 1:r6=x;
}
 P0            | P1            ;
 li r1,2       | li r1,2       ;
 stw r1,0(r2)  | stw r1,0(r2)  ;
 lwz r3,0(r2)  | lwz r3,0(r2)  ;
 xor r4,r3,r3  | xor r4,r3,r3  ;
 li r5,1       | li r5,1       ;
 stwx r5,r4,r6 | stwx r5,r4,r6 ;
exists
(x=2 /\ y=2 /\ 0:r3=2 /\ 1:r3=2)


**/


one sig x, y extends Location {}

one sig P1, P2 extends Processor {}

one sig op1 extends Write {}
one sig op2 extends Read {}
one sig op3 extends Write {}
one sig op4 extends Write {}
one sig op5 extends Read {}
one sig op6 extends Write {}

fact {
    P1.write[1, op1, x, 2]
    P1.read[2, op2, x, 2]
    P1.write[3, op3, y, 1] and op3.dep[op2]
    P2.write[4, op4, y, 2]
    P2.read[5, op5, y, 2]
    P2.write[6, op6, x, 1] and op6.dep[op5]
}

fact {
    y.final[2]
    x.final[2]
}

Allowed:
    run { Allowed_PPC } for 4 int expect 1