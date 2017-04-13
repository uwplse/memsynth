module tests/bclwsww000

open program
open model

/**
PPC bclwsww000
"DpdR Fre LwSyncsWW Rfe DpdR Fre LwSyncsWW Rfe"
Cycle=DpdR Fre LwSyncsWW Rfe DpdR Fre LwSyncsWW Rfe
Relax=BCLwSyncsWW
Safe=Fre DpdR
{
0:r2=x;
1:r2=x; 1:r5=y;
2:r2=y;
3:r2=y; 3:r5=x;
}
 P0           | P1            | P2           | P3            ;
 li r1,1      | lwz r1,0(r2)  | li r1,1      | lwz r1,0(r2)  ;
 stw r1,0(r2) | xor r3,r1,r1  | stw r1,0(r2) | xor r3,r1,r1  ;
 lwsync       | lwzx r4,r3,r5 | lwsync       | lwzx r4,r3,r5 ;
 li r3,2      |               | li r3,2      |               ;
 stw r3,0(r2) |               | stw r3,0(r2) |               ;
exists
(x=2 /\ y=2 /\ 1:r1=2 /\ 1:r4=0 /\ 3:r1=2 /\ 3:r4=0)


**/


one sig x, y extends Location {}

one sig P1, P2, P3, P4 extends Processor {}

one sig op1 extends Write {}
one sig op2 extends Lwsync {}
one sig op3 extends Write {}
one sig op4 extends Read {}
one sig op5 extends Read {}
one sig op6 extends Write {}
one sig op7 extends Lwsync {}
one sig op8 extends Write {}
one sig op9 extends Read {}
one sig op10 extends Read {}

fact {
    P1.write[1, op1, x, 1]
    P1.lwsync[2, op2]
    P1.write[3, op3, x, 2]
    P2.read[4, op4, x, 2]
    P2.read[5, op5, y, 0] and op5.dep[op4]
    P3.write[6, op6, y, 1]
    P3.lwsync[7, op7]
    P3.write[8, op8, y, 2]
    P4.read[9, op9, y, 2]
    P4.read[10, op10, x, 0] and op10.dep[op9]
}

fact {
    y.final[2]
    x.final[2]
}

Allowed:
    run { Allowed_PPC } for 5 int expect 1