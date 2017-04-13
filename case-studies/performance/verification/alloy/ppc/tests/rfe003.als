module tests/rfe003

open program
open model

/**
PPC rfe003
"DpdR Fre Rfe DpdW Rfe"
Cycle=DpdR Fre Rfe DpdW Rfe
Relax=Rfe
Safe=Fre DpdW DpdR
{
0:r2=x; 0:r5=y;
1:r2=y; 1:r5=x;
2:r2=x;
}
 P0            | P1            | P2           ;
 lwz r1,0(r2)  | lwz r1,0(r2)  | li r1,1      ;
 xor r3,r1,r1  | xor r3,r1,r1  | stw r1,0(r2) ;
 li r4,1       | lwzx r4,r3,r5 |              ;
 stwx r4,r3,r5 |               |              ;
exists
(0:r1=1 /\ 1:r1=1 /\ 1:r4=0)


**/


one sig x, y extends Location {}

one sig P1, P2, P3 extends Processor {}

one sig op1 extends Read {}
one sig op2 extends Write {}
one sig op3 extends Read {}
one sig op4 extends Read {}
one sig op5 extends Write {}

fact {
    P1.read[1, op1, x, 1]
    P1.write[2, op2, y, 1] and op2.dep[op1]
    P2.read[3, op3, y, 1]
    P2.read[4, op4, x, 0] and op4.dep[op3]
    P3.write[5, op5, x, 1]
}

Allowed:
    run { Allowed_PPC } for 4 int expect 1