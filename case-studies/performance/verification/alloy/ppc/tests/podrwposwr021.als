module tests/podrwposwr021

open program
open model

/**
PPC podrwposwr021
"DpdR Fre SyncdWW Rfe PodRW PosWR Fre SyncdWW Rfe PodRW PosWR"
Cycle=DpdR Fre SyncdWW Rfe PodRW PosWR Fre SyncdWW Rfe PodRW PosWR
Relax=[PodRW,PosWR]
Safe=Fre DpdR BCSyncdWW
{
0:r2=x; 0:r4=y;
1:r2=y; 1:r4=z;
2:r2=z; 2:r4=a;
3:r2=a; 3:r4=b; 3:r8=x;
}
 P0           | P1           | P2           | P3            ;
 li r1,1      | lwz r1,0(r2) | li r1,2      | lwz r1,0(r2)  ;
 stw r1,0(r2) | li r3,1      | stw r1,0(r2) | li r3,1       ;
 sync         | stw r3,0(r4) | sync         | stw r3,0(r4)  ;
 li r3,1      | lwz r5,0(r4) | li r3,1      | lwz r5,0(r4)  ;
 stw r3,0(r4) |              | stw r3,0(r4) | xor r6,r5,r5  ;
              |              |              | lwzx r7,r6,r8 ;
exists
(z=2 /\ 1:r1=1 /\ 1:r5=1 /\ 3:r1=1 /\ 3:r7=0)


**/


one sig a, b, x, y, z extends Location {}

one sig P1, P2, P3, P4 extends Processor {}

one sig op1 extends Write {}
one sig op2 extends Sync {}
one sig op3 extends Write {}
one sig op4 extends Read {}
one sig op5 extends Write {}
one sig op6 extends Read {}
one sig op7 extends Write {}
one sig op8 extends Sync {}
one sig op9 extends Write {}
one sig op10 extends Read {}
one sig op11 extends Write {}
one sig op12 extends Read {}
one sig op13 extends Read {}

fact {
    P1.write[1, op1, x, 1]
    P1.sync[2, op2]
    P1.write[3, op3, y, 1]
    P2.read[4, op4, y, 1]
    P2.write[5, op5, z, 1]
    P2.read[6, op6, z, 1]
    P3.write[7, op7, z, 2]
    P3.sync[8, op8]
    P3.write[9, op9, a, 1]
    P4.read[10, op10, a, 1]
    P4.write[11, op11, b, 1]
    P4.read[12, op12, b, 1]
    P4.read[13, op13, x, 0] and op13.dep[op12]
}

fact {
    z.final[2]
}

Allowed:
    run { Allowed_PPC } for 5 int expect 1