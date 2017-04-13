module tests/rfe006

open program
open model

/**
PPC rfe006
"DpdR Fre Rfe DpdR Fre Rfe"
Cycle=DpdR Fre Rfe DpdR Fre Rfe
Relax=Rfe
Safe=Fre DpdR
{
0:r2=x; 0:r5=y;
1:r2=y;
2:r2=y; 2:r5=x;
3:r2=x;
}
 P0            | P1           | P2            | P3           ;
 lwz r1,0(r2)  | li r1,1      | lwz r1,0(r2)  | li r1,1      ;
 xor r3,r1,r1  | stw r1,0(r2) | xor r3,r1,r1  | stw r1,0(r2) ;
 lwzx r4,r3,r5 |              | lwzx r4,r3,r5 |              ;
exists
(0:r1=1 /\ 0:r4=0 /\ 2:r1=1 /\ 2:r4=0)


**/


one sig x, y extends Location {}

one sig P1, P2, P3, P4 extends Processor {}

one sig op1 extends Read {}
one sig op2 extends Read {}
one sig op3 extends Write {}
one sig op4 extends Read {}
one sig op5 extends Read {}
one sig op6 extends Write {}

fact {
    P1.read[1, op1, x, 1]
    P1.read[2, op2, y, 0] and op2.dep[op1]
    P2.write[3, op3, y, 1]
    P3.read[4, op4, y, 1]
    P3.read[5, op5, x, 0] and op5.dep[op4]
    P4.write[6, op6, x, 1]
}

Allowed:
    run { Allowed_PPC } for 4 int expect 1