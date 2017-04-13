module tests/bclwdww004

open program
open model

/**
PPC bclwdww004
"DpsR Fre LwSyncdWW Rfe DpdW Wse LwSyncdWW Rfe"
Cycle=DpsR Fre LwSyncdWW Rfe DpdW Wse LwSyncdWW Rfe
Relax=BCLwSyncdWW
Safe=Fre Wse DpsR DpdW
{
0:r2=z; 0:r4=x;
1:r2=x; 1:r5=y;
2:r2=y; 2:r4=z;
3:r2=z;
}
 P0           | P1            | P2           | P3            ;
 li r1,2      | lwz r1,0(r2)  | li r1,2      | lwz r1,0(r2)  ;
 stw r1,0(r2) | xor r3,r1,r1  | stw r1,0(r2) | xor r3,r1,r1  ;
 lwsync       | li r4,1       | lwsync       | lwzx r4,r3,r2 ;
 li r3,1      | stwx r4,r3,r5 | li r3,1      |               ;
 stw r3,0(r4) |               | stw r3,0(r4) |               ;
exists
(y=2 /\ z=2 /\ 1:r1=1 /\ 3:r1=1 /\ 3:r4=1)


**/


one sig x, y, z extends Location {}

one sig P1, P2, P3, P4 extends Processor {}

one sig op1 extends Write {}
one sig op2 extends Lwsync {}
one sig op3 extends Write {}
one sig op4 extends Read {}
one sig op5 extends Write {}
one sig op6 extends Write {}
one sig op7 extends Lwsync {}
one sig op8 extends Write {}
one sig op9 extends Read {}
one sig op10 extends Read {}

fact {
    P1.write[1, op1, z, 2]
    P1.lwsync[2, op2]
    P1.write[3, op3, x, 1]
    P2.read[4, op4, x, 1]
    P2.write[5, op5, y, 1] and op5.dep[op4]
    P3.write[6, op6, y, 2]
    P3.lwsync[7, op7]
    P3.write[8, op8, z, 1]
    P4.read[9, op9, z, 1]
    P4.read[10, op10, z, 1] and op10.dep[op9]
}

fact {
    y.final[2]
    z.final[2]
}

Allowed:
    run { Allowed_PPC } for 5 int expect 1