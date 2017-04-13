module tests/bclwdww014

open program
open model

/**
PPC bclwdww014
"LwSyncdRW Wse LwSyncdWW Rfe LwSyncdRW Wse LwSyncdWW Rfe"
Cycle=LwSyncdRW Wse LwSyncdWW Rfe LwSyncdRW Wse LwSyncdWW Rfe
Relax=BCLwSyncdWW
Safe=Wse LwSyncdRW
{
0:r2=x; 0:r4=y;
1:r2=y; 1:r4=z;
2:r2=z; 2:r4=a;
3:r2=a; 3:r4=x;
}
 P0           | P1           | P2           | P3           ;
 li r1,2      | lwz r1,0(r2) | li r1,2      | lwz r1,0(r2) ;
 stw r1,0(r2) | lwsync       | stw r1,0(r2) | lwsync       ;
 lwsync       | li r3,1      | lwsync       | li r3,1      ;
 li r3,1      | stw r3,0(r4) | li r3,1      | stw r3,0(r4) ;
 stw r3,0(r4) |              | stw r3,0(r4) |              ;
exists
(x=2 /\ z=2 /\ 1:r1=1 /\ 3:r1=1)


**/


one sig a, x, y, z extends Location {}

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
one sig op11 extends Lwsync {}
one sig op12 extends Write {}

fact {
    P1.write[1, op1, x, 2]
    P1.lwsync[2, op2]
    P1.write[3, op3, y, 1]
    P2.read[4, op4, y, 1]
    P2.lwsync[5, op5]
    P2.write[6, op6, z, 1]
    P3.write[7, op7, z, 2]
    P3.lwsync[8, op8]
    P3.write[9, op9, a, 1]
    P4.read[10, op10, a, 1]
    P4.lwsync[11, op11]
    P4.write[12, op12, x, 1]
}

fact {
    x.final[2]
    z.final[2]
}

Allowed:
    run { Allowed_PPC } for 5 int expect 0