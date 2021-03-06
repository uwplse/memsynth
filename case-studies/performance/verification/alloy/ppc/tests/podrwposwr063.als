module tests/podrwposwr063

open program
open model

/**
PPC podrwposwr063
"DpdW Wse SyncdWW Rfe SyncdRW Rfe PodRW PosWR"
Cycle=DpdW Wse SyncdWW Rfe SyncdRW Rfe PodRW PosWR
Relax=[PodRW,PosWR]
Safe=Wse DpdW BCSyncdWW BCSyncdRW
{
0:r2=x; 0:r4=y;
1:r2=y; 1:r4=z;
2:r2=z; 2:r4=a; 2:r8=x;
}
 P0           | P1           | P2            ;
 li r1,2      | lwz r1,0(r2) | lwz r1,0(r2)  ;
 stw r1,0(r2) | sync         | li r3,1       ;
 sync         | li r3,1      | stw r3,0(r4)  ;
 li r3,1      | stw r3,0(r4) | lwz r5,0(r4)  ;
 stw r3,0(r4) |              | xor r6,r5,r5  ;
              |              | li r7,1       ;
              |              | stwx r7,r6,r8 ;
exists
(x=2 /\ 1:r1=1 /\ 2:r1=1)


**/


one sig a, x, y, z extends Location {}

one sig P1, P2, P3 extends Processor {}

one sig op1 extends Write {}
one sig op2 extends Sync {}
one sig op3 extends Write {}
one sig op4 extends Read {}
one sig op5 extends Sync {}
one sig op6 extends Write {}
one sig op7 extends Read {}
one sig op8 extends Write {}
one sig op9 extends Read {}
one sig op10 extends Write {}

fact {
    P1.write[1, op1, x, 2]
    P1.sync[2, op2]
    P1.write[3, op3, y, 1]
    P2.read[4, op4, y, 1]
    P2.sync[5, op5]
    P2.write[6, op6, z, 1]
    P3.read[7, op7, z, 1]
    P3.write[8, op8, a, 1]
    P3.read[9, op9, a, 1]
    P3.write[10, op10, x, 1] and op10.dep[op9]
}

fact {
    x.final[2]
}

Allowed:
    run { Allowed_PPC } for 5 int expect 1