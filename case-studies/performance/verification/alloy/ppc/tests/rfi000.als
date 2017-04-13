module tests/rfi000

open program
open model

/**
PPC rfi000
"DpdR Fre Rfi DpdR Fre Rfi"
Cycle=DpdR Fre Rfi DpdR Fre Rfi
Relax=Rfi
Safe=Fre DpdR
{
0:r2=x; 0:r6=y;
1:r2=y; 1:r6=x;
}
 P0            | P1            ;
 li r1,1       | li r1,1       ;
 stw r1,0(r2)  | stw r1,0(r2)  ;
 lwz r3,0(r2)  | lwz r3,0(r2)  ;
 xor r4,r3,r3  | xor r4,r3,r3  ;
 lwzx r5,r4,r6 | lwzx r5,r4,r6 ;
exists
(0:r3=1 /\ 0:r5=0 /\ 1:r3=1 /\ 1:r5=0)


**/


one sig x, y extends Location {}

one sig P1, P2 extends Processor {}

one sig op1 extends Write {}
one sig op2 extends Read {}
one sig op3 extends Read {}
one sig op4 extends Write {}
one sig op5 extends Read {}
one sig op6 extends Read {}

fact {
    P1.write[1, op1, x, 1]
    P1.read[2, op2, x, 1]
    P1.read[3, op3, y, 0] and op3.dep[op2]
    P2.write[4, op4, y, 1]
    P2.read[5, op5, y, 1]
    P2.read[6, op6, x, 0] and op6.dep[op5]
}

Allowed:
    run { Allowed_PPC } for 4 int expect 1