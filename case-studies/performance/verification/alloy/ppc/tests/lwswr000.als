module tests/lwswr000

open program
open model

/**
PPC lwswr000
"DpdR Fre LwSyncsWR Fre LwSyncsWR DpdR Fre LwSyncsWR Fre LwSyncsWR"
Cycle=DpdR Fre LwSyncsWR Fre LwSyncsWR DpdR Fre LwSyncsWR Fre LwSyncsWR
Relax=LwSyncsWR
Safe=Fre DpdR
{
0:r2=x;
1:r2=x; 1:r6=y;
2:r2=y;
3:r2=y; 3:r6=x;
}
 P0           | P1            | P2           | P3            ;
 li r1,1      | li r1,2       | li r1,1      | li r1,2       ;
 stw r1,0(r2) | stw r1,0(r2)  | stw r1,0(r2) | stw r1,0(r2)  ;
 lwsync       | lwsync        | lwsync       | lwsync        ;
 lwz r3,0(r2) | lwz r3,0(r2)  | lwz r3,0(r2) | lwz r3,0(r2)  ;
              | xor r4,r3,r3  |              | xor r4,r3,r3  ;
              | lwzx r5,r4,r6 |              | lwzx r5,r4,r6 ;
exists
(x=2 /\ y=2 /\ 0:r3=1 /\ 1:r3=2 /\ 1:r5=0 /\ 2:r3=1 /\ 3:r3=2 /\ 3:r5=0)


**/


one sig x, y extends Location {}

one sig P1, P2, P3, P4 extends Processor {}

one sig op1 extends Write {}
one sig op2 extends Lwsync {}
one sig op3 extends Read {}
one sig op4 extends Write {}
one sig op5 extends Lwsync {}
one sig op6 extends Read {}
one sig op7 extends Read {}
one sig op8 extends Write {}
one sig op9 extends Lwsync {}
one sig op10 extends Read {}
one sig op11 extends Write {}
one sig op12 extends Lwsync {}
one sig op13 extends Read {}
one sig op14 extends Read {}

fact {
    P1.write[1, op1, x, 1]
    P1.lwsync[2, op2]
    P1.read[3, op3, x, 1]
    P2.write[4, op4, x, 2]
    P2.lwsync[5, op5]
    P2.read[6, op6, x, 2]
    P2.read[7, op7, y, 0] and op7.dep[op6]
    P3.write[8, op8, y, 1]
    P3.lwsync[9, op9]
    P3.read[10, op10, y, 1]
    P4.write[11, op11, y, 2]
    P4.lwsync[12, op12]
    P4.read[13, op13, y, 2]
    P4.read[14, op14, x, 0] and op14.dep[op13]
}

fact {
    y.final[2]
    x.final[2]
}

Allowed:
    run { Allowed_PPC } for 5 int expect 1