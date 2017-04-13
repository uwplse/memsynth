module tests/bclwdww024

open program
open model

/**
PPC bclwdww024
"DpsR Fre LwSyncdWW Rfe DpsR Fre LwSyncdWW Rfe"
Cycle=DpsR Fre LwSyncdWW Rfe DpsR Fre LwSyncdWW Rfe
Relax=BCLwSyncdWW
Safe=Fre DpsR
{
0:r2=y; 0:r4=x;
1:r2=x;
2:r2=x; 2:r4=y;
3:r2=y;
}
 P0           | P1            | P2           | P3            ;
 li r1,2      | lwz r1,0(r2)  | li r1,2      | lwz r1,0(r2)  ;
 stw r1,0(r2) | xor r3,r1,r1  | stw r1,0(r2) | xor r3,r1,r1  ;
 lwsync       | lwzx r4,r3,r2 | lwsync       | lwzx r4,r3,r2 ;
 li r3,1      |               | li r3,1      |               ;
 stw r3,0(r4) |               | stw r3,0(r4) |               ;
exists
(x=2 /\ y=2 /\ 1:r1=1 /\ 1:r4=1 /\ 3:r1=1 /\ 3:r4=1)


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
    P1.write[1, op1, y, 2]
    P1.lwsync[2, op2]
    P1.write[3, op3, x, 1]
    P2.read[4, op4, x, 1]
    P2.read[5, op5, x, 1] and op5.dep[op4]
    P3.write[6, op6, x, 2]
    P3.lwsync[7, op7]
    P3.write[8, op8, y, 1]
    P4.read[9, op9, y, 1]
    P4.read[10, op10, y, 1] and op10.dep[op9]
}

fact {
    y.final[2]
    x.final[2]
}

Allowed:
    run { Allowed_PPC } for 5 int expect 0