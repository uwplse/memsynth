module tests/lwswr002

open program
open model

/**
PPC lwswr002
"DpdR Fre LwSyncsWR DpdR Fre LwSyncsWR"
Cycle=DpdR Fre LwSyncsWR DpdR Fre LwSyncsWR
Relax=LwSyncsWR
Safe=Fre DpdR
{
0:r2=x; 0:r6=y;
1:r2=y; 1:r6=x;
}
 P0            | P1            ;
 li r1,1       | li r1,1       ;
 stw r1,0(r2)  | stw r1,0(r2)  ;
 lwsync        | lwsync        ;
 lwz r3,0(r2)  | lwz r3,0(r2)  ;
 xor r4,r3,r3  | xor r4,r3,r3  ;
 lwzx r5,r4,r6 | lwzx r5,r4,r6 ;
exists
(0:r3=1 /\ 0:r5=0 /\ 1:r3=1 /\ 1:r5=0)


**/


one sig x, y extends Location {}

one sig P1, P2 extends Processor {}

one sig op1 extends Write {}
one sig op2 extends Lwsync {}
one sig op3 extends Read {}
one sig op4 extends Read {}
one sig op5 extends Write {}
one sig op6 extends Lwsync {}
one sig op7 extends Read {}
one sig op8 extends Read {}

fact {
    P1.write[1, op1, x, 1]
    P1.lwsync[2, op2]
    P1.read[3, op3, x, 1]
    P1.read[4, op4, y, 0] and op4.dep[op3]
    P2.write[5, op5, y, 1]
    P2.lwsync[6, op6]
    P2.read[7, op7, y, 1]
    P2.read[8, op8, x, 0] and op8.dep[op7]
}

Allowed:
    run { Allowed_PPC } for 5 int expect 1