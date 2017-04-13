module tests/podrwposwr009

open program
open model

/**
PPC podrwposwr009
"Fre SyncdWW Rfe PodRW PosWR DpdW Wse SyncdWW Rfe DpdR PodRW PosWR"
Cycle=Fre SyncdWW Rfe PodRW PosWR DpdW Wse SyncdWW Rfe DpdR PodRW PosWR
Relax=[PodRW,PosWR]
Safe=Fre Wse DpdW DpdR BCSyncdWW
{
0:r2=c; 0:r4=x;
1:r2=x; 1:r4=y; 1:r8=z;
2:r2=z; 2:r4=a;
3:r2=a; 3:r5=b; 3:r7=c;
}
 P0           | P1            | P2           | P3            ;
 li r1,2      | lwz r1,0(r2)  | li r1,2      | lwz r1,0(r2)  ;
 stw r1,0(r2) | li r3,1       | stw r1,0(r2) | xor r3,r1,r1  ;
 sync         | stw r3,0(r4)  | sync         | lwzx r4,r3,r5 ;
 li r3,1      | lwz r5,0(r4)  | li r3,1      | li r6,1       ;
 stw r3,0(r4) | xor r6,r5,r5  | stw r3,0(r4) | stw r6,0(r7)  ;
              | li r7,1       |              | lwz r8,0(r7)  ;
              | stwx r7,r6,r8 |              |               ;
exists
(c=2 /\ z=2 /\ 1:r1=1 /\ 3:r1=1 /\ 3:r8=1)


**/


one sig a, c, x, y, z extends Location {}

one sig P1, P2, P3, P4 extends Processor {}

one sig op1 extends Write {}
one sig op2 extends Sync {}
one sig op3 extends Write {}
one sig op4 extends Read {}
one sig op5 extends Write {}
one sig op6 extends Read {}
one sig op7 extends Write {}
one sig op8 extends Write {}
one sig op9 extends Sync {}
one sig op10 extends Write {}
one sig op11 extends Read {}
one sig op12 extends Write {}
one sig op13 extends Read {}

fact {
    P1.write[1, op1, c, 2]
    P1.sync[2, op2]
    P1.write[3, op3, x, 1]
    P2.read[4, op4, x, 1]
    P2.write[5, op5, y, 1]
    P2.read[6, op6, y, 1]
    P2.write[7, op7, z, 1] and op7.dep[op6]
    P3.write[8, op8, z, 2]
    P3.sync[9, op9]
    P3.write[10, op10, a, 1]
    P4.read[11, op11, a, 1]
    P4.write[12, op12, c, 1]
    P4.read[13, op13, c, 1]
}

fact {
    c.final[2]
    z.final[2]
}

Allowed:
    run { Allowed_PPC } for 5 int expect 1