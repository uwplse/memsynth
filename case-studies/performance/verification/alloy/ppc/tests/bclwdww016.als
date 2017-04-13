module tests/bclwdww016

open program
open model

/**
PPC bclwdww016
"DpsR Fre LwSyncdWW Rfe LwSyncdRW Wse LwSyncdWW Rfe"
Cycle=DpsR Fre LwSyncdWW Rfe LwSyncdRW Wse LwSyncdWW Rfe
Relax=BCLwSyncdWW
Safe=Fre Wse LwSyncdRW DpsR
{
0:r2=z; 0:r4=x;
1:r2=x; 1:r4=y;
2:r2=y; 2:r4=z;
3:r2=z;
}
 P0           | P1           | P2           | P3            ;
 li r1,2      | lwz r1,0(r2) | li r1,2      | lwz r1,0(r2)  ;
 stw r1,0(r2) | lwsync       | stw r1,0(r2) | xor r3,r1,r1  ;
 lwsync       | li r3,1      | lwsync       | lwzx r4,r3,r2 ;
 li r3,1      | stw r3,0(r4) | li r3,1      |               ;
 stw r3,0(r4) |              | stw r3,0(r4) |               ;
exists
(y=2 /\ z=2 /\ 1:r1=1 /\ 3:r1=1 /\ 3:r4=1)


**/


one sig x, y, z extends Location {}

one sig P1, P2, P3, P4 extends Processor {}

one sig op1 extends Write {}
one sig op2 extends Lwsync {}
one sig op3 extends Write {}
one sig op4 extends Read {}
one sig op5 extends Lwsync {}
one sig op6 extends Write {}
one sig op7 extends Write {}
one sig op8 extends Lwsync {}
one sig op9 extends Write {}
one sig op10 extends Read {}
one sig op11 extends Read {}

fact {
    P1.write[1, op1, z, 2]
    P1.lwsync[2, op2]
    P1.write[3, op3, x, 1]
    P2.read[4, op4, x, 1]
    P2.lwsync[5, op5]
    P2.write[6, op6, y, 1]
    P3.write[7, op7, y, 2]
    P3.lwsync[8, op8]
    P3.write[9, op9, z, 1]
    P4.read[10, op10, z, 1]
    P4.read[11, op11, z, 1] and op11.dep[op10]
}

fact {
    y.final[2]
    z.final[2]
}

Allowed:
    run { Allowed_PPC } for 5 int expect 0