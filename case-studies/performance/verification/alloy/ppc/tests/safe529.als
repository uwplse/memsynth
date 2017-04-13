module tests/safe529

open program
open model

/**
PPC safe529
"SyncdWW Rfe SyncdRW Rfe LwSyncdRW Rfe SyncdRR Fre"
Cycle=SyncdWW Rfe SyncdRW Rfe LwSyncdRW Rfe SyncdRR Fre
Relax=
Safe=Fre LwSyncdRW ACSyncdRR BCSyncdWW BCSyncdRW
{
0:r2=x; 0:r4=y;
1:r2=y; 1:r4=z;
2:r2=z; 2:r4=a;
3:r2=a; 3:r4=x;
}
 P0           | P1           | P2           | P3           ;
 lwz r1,0(r2) | lwz r1,0(r2) | lwz r1,0(r2) | li r1,1      ;
 sync         | lwsync       | sync         | stw r1,0(r2) ;
 li r3,1      | li r3,1      | lwz r3,0(r4) | sync         ;
 stw r3,0(r4) | stw r3,0(r4) |              | li r3,1      ;
              |              |              | stw r3,0(r4) ;
exists
(0:r1=1 /\ 1:r1=1 /\ 2:r1=1 /\ 2:r3=0)


**/


one sig a, x, y, z extends Location {}

one sig P1, P2, P3, P4 extends Processor {}

one sig op1 extends Read {}
one sig op2 extends Sync {}
one sig op3 extends Write {}
one sig op4 extends Read {}
one sig op5 extends Lwsync {}
one sig op6 extends Write {}
one sig op7 extends Read {}
one sig op8 extends Sync {}
one sig op9 extends Read {}
one sig op10 extends Write {}
one sig op11 extends Sync {}
one sig op12 extends Write {}

fact {
    P1.read[1, op1, x, 1]
    P1.sync[2, op2]
    P1.write[3, op3, y, 1]
    P2.read[4, op4, y, 1]
    P2.lwsync[5, op5]
    P2.write[6, op6, z, 1]
    P3.read[7, op7, z, 1]
    P3.sync[8, op8]
    P3.read[9, op9, a, 0]
    P4.write[10, op10, a, 1]
    P4.sync[11, op11]
    P4.write[12, op12, x, 1]
}

Allowed:
    run { Allowed_PPC } for 5 int expect 0