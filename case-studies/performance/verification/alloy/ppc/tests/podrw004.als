module tests/podrw004

open program
open model

/**
PPC podrw004
"Wse SyncdWW Rfe SyncdRW Rfe SyncdRW Rfe SyncdRW Rfe PodRW"
Cycle=Wse SyncdWW Rfe SyncdRW Rfe SyncdRW Rfe SyncdRW Rfe PodRW
Relax=PodRW
Safe=Wse BCSyncdWW BCSyncdRW
{
0:r2=b; 0:r4=x;
1:r2=x; 1:r4=y;
2:r2=y; 2:r4=z;
3:r2=z; 3:r4=a;
4:r2=a; 4:r4=b;
}
 P0           | P1           | P2           | P3           | P4           ;
 li r1,2      | lwz r1,0(r2) | lwz r1,0(r2) | lwz r1,0(r2) | lwz r1,0(r2) ;
 stw r1,0(r2) | sync         | sync         | sync         | li r3,1      ;
 sync         | li r3,1      | li r3,1      | li r3,1      | stw r3,0(r4) ;
 li r3,1      | stw r3,0(r4) | stw r3,0(r4) | stw r3,0(r4) |              ;
 stw r3,0(r4) |              |              |              |              ;
exists
(b=2 /\ 1:r1=1 /\ 2:r1=1 /\ 3:r1=1 /\ 4:r1=1)


**/


one sig a, b, x, y, z extends Location {}

one sig P1, P2, P3, P4, P5 extends Processor {}

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
one sig op11 extends Sync {}
one sig op12 extends Write {}
one sig op13 extends Read {}
one sig op14 extends Write {}

fact {
    P1.write[1, op1, b, 2]
    P1.sync[2, op2]
    P1.write[3, op3, x, 1]
    P2.read[4, op4, x, 1]
    P2.sync[5, op5]
    P2.write[6, op6, y, 1]
    P3.read[7, op7, y, 1]
    P3.sync[8, op8]
    P3.write[9, op9, z, 1]
    P4.read[10, op10, z, 1]
    P4.sync[11, op11]
    P4.write[12, op12, a, 1]
    P5.read[13, op13, a, 1]
    P5.write[14, op14, b, 1]
}

fact {
    b.final[2]
}

Allowed:
    run { Allowed_PPC } for 5 int expect 1