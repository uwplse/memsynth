module tests/posrr002

open program
open model

/**
PPC posrr002
"Fre SyncdWW Rfe DpdR PosRR"
Cycle=Fre SyncdWW Rfe DpdR PosRR
Relax=PosRR
Safe=Fre DpdR BCSyncdWW
{
0:r2=y; 0:r4=x;
1:r2=x; 1:r5=y;
}
 P0           | P1            ;
 li r1,1      | lwz r1,0(r2)  ;
 stw r1,0(r2) | xor r3,r1,r1  ;
 sync         | lwzx r4,r3,r5 ;
 li r3,1      | lwz r6,0(r5)  ;
 stw r3,0(r4) |               ;
exists
(1:r1=1 /\ 1:r4=0 /\ 1:r6=0)


**/


one sig x, y extends Location {}

one sig P1, P2 extends Processor {}

one sig op1 extends Write {}
one sig op2 extends Sync {}
one sig op3 extends Write {}
one sig op4 extends Read {}
one sig op5 extends Read {}
one sig op6 extends Read {}

fact {
    P1.write[1, op1, y, 1]
    P1.sync[2, op2]
    P1.write[3, op3, x, 1]
    P2.read[4, op4, x, 1]
    P2.read[5, op5, y, 0] and op5.dep[op4]
    P2.read[6, op6, y, 0]
}

Allowed:
    run { Allowed_PPC } for 4 int expect 0