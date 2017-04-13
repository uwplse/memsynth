module tests/posrr000

open program
open model

/**
PPC posrr000
"Fre SyncdWW Rfe PosRR DpdR PosRR"
Cycle=Fre SyncdWW Rfe PosRR DpdR PosRR
Relax=PosRR
Safe=Fre DpdR BCSyncdWW
{
0:r2=y; 0:r4=x;
1:r2=x; 1:r6=y;
}
 P0           | P1            ;
 li r1,1      | lwz r1,0(r2)  ;
 stw r1,0(r2) | lwz r3,0(r2)  ;
 sync         | xor r4,r3,r3  ;
 li r3,1      | lwzx r5,r4,r6 ;
 stw r3,0(r4) | lwz r7,0(r6)  ;
exists
(1:r1=1 /\ 1:r3=1 /\ 1:r5=0 /\ 1:r7=0)


**/


one sig x, y extends Location {}

one sig P1, P2 extends Processor {}

one sig op1 extends Write {}
one sig op2 extends Sync {}
one sig op3 extends Write {}
one sig op4 extends Read {}
one sig op5 extends Read {}
one sig op6 extends Read {}
one sig op7 extends Read {}

fact {
    P1.write[1, op1, y, 1]
    P1.sync[2, op2]
    P1.write[3, op3, x, 1]
    P2.read[4, op4, x, 1]
    P2.read[5, op5, x, 1]
    P2.read[6, op6, y, 0] and op6.dep[op5]
    P2.read[7, op7, y, 0]
}

Allowed:
    run { Allowed_PPC } for 4 int expect 0