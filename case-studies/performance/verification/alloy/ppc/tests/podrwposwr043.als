module tests/podrwposwr043

open program
open model

/**
PPC podrwposwr043
"Fre SyncdWW Rfe DpdW Wse SyncdWW Rfe PodRW PosWR"
Cycle=Fre SyncdWW Rfe DpdW Wse SyncdWW Rfe PodRW PosWR
Relax=[PodRW,PosWR]
Safe=Fre Wse DpdW BCSyncdWW
{
0:r2=a; 0:r4=x;
1:r2=x; 1:r5=y;
2:r2=y; 2:r4=z;
3:r2=z; 3:r4=a;
}
 P0           | P1            | P2           | P3           ;
 li r1,2      | lwz r1,0(r2)  | li r1,2      | lwz r1,0(r2) ;
 stw r1,0(r2) | xor r3,r1,r1  | stw r1,0(r2) | li r3,1      ;
 sync         | li r4,1       | sync         | stw r3,0(r4) ;
 li r3,1      | stwx r4,r3,r5 | li r3,1      | lwz r5,0(r4) ;
 stw r3,0(r4) |               | stw r3,0(r4) |              ;
exists
(a=2 /\ y=2 /\ 1:r1=1 /\ 3:r1=1 /\ 3:r5=1)


**/


one sig a, x, y, z extends Location {}

one sig P1, P2, P3, P4 extends Processor {}

one sig op1 extends Write {}
one sig op2 extends Sync {}
one sig op3 extends Write {}
one sig op4 extends Read {}
one sig op5 extends Write {}
one sig op6 extends Write {}
one sig op7 extends Sync {}
one sig op8 extends Write {}
one sig op9 extends Read {}
one sig op10 extends Write {}
one sig op11 extends Read {}

fact {
    P1.write[1, op1, a, 2]
    P1.sync[2, op2]
    P1.write[3, op3, x, 1]
    P2.read[4, op4, x, 1]
    P2.write[5, op5, y, 1] and op5.dep[op4]
    P3.write[6, op6, y, 2]
    P3.sync[7, op7]
    P3.write[8, op8, z, 1]
    P4.read[9, op9, z, 1]
    P4.write[10, op10, a, 1]
    P4.read[11, op11, a, 1]
}

fact {
    a.final[2]
    y.final[2]
}

Allowed:
    run { Allowed_PPC } for 5 int expect 1