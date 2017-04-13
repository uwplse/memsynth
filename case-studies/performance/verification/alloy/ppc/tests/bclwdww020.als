module tests/bclwdww020

open program
open model

/**
PPC bclwdww020
"DpdR Fre LwSyncdWW Rfe DpdR Fre LwSyncdWW Rfe"
Cycle=DpdR Fre LwSyncdWW Rfe DpdR Fre LwSyncdWW Rfe
Relax=BCLwSyncdWW
Safe=Fre DpdR
{
0:r2=x; 0:r4=y;
1:r2=y; 1:r5=z;
2:r2=z; 2:r4=a;
3:r2=a; 3:r5=x;
}
 P0           | P1            | P2           | P3            ;
 li r1,1      | lwz r1,0(r2)  | li r1,1      | lwz r1,0(r2)  ;
 stw r1,0(r2) | xor r3,r1,r1  | stw r1,0(r2) | xor r3,r1,r1  ;
 lwsync       | lwzx r4,r3,r5 | lwsync       | lwzx r4,r3,r5 ;
 li r3,1      |               | li r3,1      |               ;
 stw r3,0(r4) |               | stw r3,0(r4) |               ;
exists
(1:r1=1 /\ 1:r4=0 /\ 3:r1=1 /\ 3:r4=0)


**/


one sig a, x, y, z extends Location {}

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
    P1.write[3, op3, y, 1]
    P2.read[4, op4, y, 1]
    P2.read[5, op5, z, 0] and op5.dep[op4]
    P3.write[6, op6, z, 1]
    P3.lwsync[7, op7]
    P3.write[8, op8, a, 1]
    P4.read[9, op9, a, 1]
    P4.read[10, op10, x, 0] and op10.dep[op9]
}

Allowed:
    run { Allowed_PPC } for 5 int expect 1