module tests/safe138

open program
open model

/**
PPC safe138
"SyncdWR Fre LwSyncdWW Wse LwSyncdWW Wse"
Cycle=SyncdWR Fre LwSyncdWW Wse LwSyncdWW Wse
Relax=
Safe=Fre Wse SyncdWR LwSyncdWW
{
0:r2=x; 0:r4=y;
1:r2=y; 1:r4=z;
2:r2=z; 2:r4=x;
}
 P0           | P1           | P2           ;
 li r1,1      | li r1,2      | li r1,2      ;
 stw r1,0(r2) | stw r1,0(r2) | stw r1,0(r2) ;
 lwsync       | lwsync       | sync         ;
 li r3,1      | li r3,1      | lwz r3,0(r4) ;
 stw r3,0(r4) | stw r3,0(r4) |              ;
exists
(y=2 /\ z=2 /\ 2:r3=0)


**/


one sig x, y, z extends Location {}

one sig P1, P2, P3 extends Processor {}

one sig op1 extends Write {}
one sig op2 extends Lwsync {}
one sig op3 extends Write {}
one sig op4 extends Write {}
one sig op5 extends Lwsync {}
one sig op6 extends Write {}
one sig op7 extends Write {}
one sig op8 extends Sync {}
one sig op9 extends Read {}

fact {
    P1.write[1, op1, x, 1]
    P1.lwsync[2, op2]
    P1.write[3, op3, y, 1]
    P2.write[4, op4, y, 2]
    P2.lwsync[5, op5]
    P2.write[6, op6, z, 1]
    P3.write[7, op7, z, 2]
    P3.sync[8, op8]
    P3.read[9, op9, x, 0]
}

fact {
    y.final[2]
    z.final[2]
}

Allowed:
    run { Allowed_PPC } for 5 int expect 0