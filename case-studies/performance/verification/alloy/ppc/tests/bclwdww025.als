module tests/bclwdww025

open program
open model

/**
PPC bclwdww025
"LwSyncdRR Fre LwSyncdWW Rfe DpsR Fre LwSyncdWW Rfe"
Cycle=LwSyncdRR Fre LwSyncdWW Rfe DpsR Fre LwSyncdWW Rfe
Relax=BCLwSyncdWW
Safe=Fre LwSyncdRR DpsR
{
0:r2=x; 0:r4=y;
1:r2=y;
2:r2=y; 2:r4=z;
3:r2=z; 3:r4=x;
}
 P0           | P1            | P2           | P3           ;
 li r1,1      | lwz r1,0(r2)  | li r1,2      | lwz r1,0(r2) ;
 stw r1,0(r2) | xor r3,r1,r1  | stw r1,0(r2) | lwsync       ;
 lwsync       | lwzx r4,r3,r2 | lwsync       | lwz r3,0(r4) ;
 li r3,1      |               | li r3,1      |              ;
 stw r3,0(r4) |               | stw r3,0(r4) |              ;
exists
(y=2 /\ 1:r1=1 /\ 1:r4=1 /\ 3:r1=1 /\ 3:r3=0)


**/


one sig x, y, z extends Location {}

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
one sig op10 extends Lwsync {}
one sig op11 extends Read {}

fact {
    P1.write[1, op1, x, 1]
    P1.lwsync[2, op2]
    P1.write[3, op3, y, 1]
    P2.read[4, op4, y, 1]
    P2.read[5, op5, y, 1] and op5.dep[op4]
    P3.write[6, op6, y, 2]
    P3.lwsync[7, op7]
    P3.write[8, op8, z, 1]
    P4.read[9, op9, z, 1]
    P4.lwsync[10, op10]
    P4.read[11, op11, x, 0]
}

fact {
    y.final[2]
}

Allowed:
    run { Allowed_PPC } for 5 int expect 1