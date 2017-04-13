module tests/podrwposwr041

open program
open model

/**
PPC podrwposwr041
"DpdW Wse SyncdWW Rfe PodRW PosWR"
Cycle=DpdW Wse SyncdWW Rfe PodRW PosWR
Relax=[PodRW,PosWR]
Safe=Wse DpdW BCSyncdWW
{
0:r2=x; 0:r4=y;
1:r2=y; 1:r4=z; 1:r8=x;
}
 P0           | P1            ;
 li r1,2      | lwz r1,0(r2)  ;
 stw r1,0(r2) | li r3,1       ;
 sync         | stw r3,0(r4)  ;
 li r3,1      | lwz r5,0(r4)  ;
 stw r3,0(r4) | xor r6,r5,r5  ;
              | li r7,1       ;
              | stwx r7,r6,r8 ;
exists
(x=2 /\ 1:r1=1)


**/


one sig x, y, z extends Location {}

one sig P1, P2 extends Processor {}

one sig op1 extends Write {}
one sig op2 extends Sync {}
one sig op3 extends Write {}
one sig op4 extends Read {}
one sig op5 extends Write {}
one sig op6 extends Read {}
one sig op7 extends Write {}

fact {
    P1.write[1, op1, x, 2]
    P1.sync[2, op2]
    P1.write[3, op3, y, 1]
    P2.read[4, op4, y, 1]
    P2.write[5, op5, z, 1]
    P2.read[6, op6, z, 1]
    P2.write[7, op7, x, 1] and op7.dep[op6]
}

fact {
    x.final[2]
}

Allowed:
    run { Allowed_PPC } for 4 int expect 1