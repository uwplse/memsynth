module tests/podrr004

open program
open model

/**
PPC podrr004
"Fre SyncdWW Rfe SyncdRW Rfe SyncdRW Rfe PodRR"
Cycle=Fre SyncdWW Rfe SyncdRW Rfe SyncdRW Rfe PodRR
Relax=PodRR
Safe=Fre BCSyncdWW BCSyncdRW
{
0:r2=a; 0:r4=x;
1:r2=x; 1:r4=y;
2:r2=y; 2:r4=z;
3:r2=z; 3:r4=a;
}
 P0           | P1           | P2           | P3           ;
 li r1,1      | lwz r1,0(r2) | lwz r1,0(r2) | lwz r1,0(r2) ;
 stw r1,0(r2) | sync         | sync         | lwz r3,0(r4) ;
 sync         | li r3,1      | li r3,1      |              ;
 li r3,1      | stw r3,0(r4) | stw r3,0(r4) |              ;
 stw r3,0(r4) |              |              |              ;
exists
(1:r1=1 /\ 2:r1=1 /\ 3:r1=1 /\ 3:r3=0)


**/


one sig a, x, y, z extends Location {}

one sig P1, P2, P3, P4 extends Processor {}

one sig op1 extends Write {}
one sig op2 extends Sync {}
one sig op3 extends Write {}
one sig op4 extends Read {}
one sig op5 extends Sync {}
one sig op6 extends Write {}
one sig op7 extends Read {}
one sig op8 extends Sync {}
one sig op9 extends Write {}
one sig op10 extends Read {}
one sig op11 extends Read {}

fact {
    P1.write[1, op1, a, 1]
    P1.sync[2, op2]
    P1.write[3, op3, x, 1]
    P2.read[4, op4, x, 1]
    P2.sync[5, op5]
    P2.write[6, op6, y, 1]
    P3.read[7, op7, y, 1]
    P3.sync[8, op8]
    P3.write[9, op9, z, 1]
    P4.read[10, op10, z, 1]
    P4.read[11, op11, a, 0]
}

Allowed:
    run { Allowed_PPC } for 5 int expect 1