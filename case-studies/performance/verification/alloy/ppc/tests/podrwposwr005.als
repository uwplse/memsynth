module tests/podrwposwr005

open program
open model

/**
PPC podrwposwr005
"Fre SyncdWR Fre SyncdWW Rfe DpdR PodRW PosWR"
Cycle=Fre SyncdWR Fre SyncdWW Rfe DpdR PodRW PosWR
Relax=[PodRW,PosWR]
Safe=Fre SyncdWR DpdR BCSyncdWW
{
0:r2=a; 0:r4=x;
1:r2=x; 1:r4=y;
2:r2=y; 2:r5=z; 2:r7=a;
}
 P0           | P1           | P2            ;
 li r1,2      | li r1,1      | lwz r1,0(r2)  ;
 stw r1,0(r2) | stw r1,0(r2) | xor r3,r1,r1  ;
 sync         | sync         | lwzx r4,r3,r5 ;
 lwz r3,0(r4) | li r3,1      | li r6,1       ;
              | stw r3,0(r4) | stw r6,0(r7)  ;
              |              | lwz r8,0(r7)  ;
exists
(a=2 /\ 0:r3=0 /\ 2:r1=1 /\ 2:r8=1)


**/


one sig a, x, y extends Location {}

one sig P1, P2, P3 extends Processor {}

one sig op1 extends Write {}
one sig op2 extends Sync {}
one sig op3 extends Read {}
one sig op4 extends Write {}
one sig op5 extends Sync {}
one sig op6 extends Write {}
one sig op7 extends Read {}
one sig op8 extends Write {}
one sig op9 extends Read {}

fact {
    P1.write[1, op1, a, 2]
    P1.sync[2, op2]
    P1.read[3, op3, x, 0]
    P2.write[4, op4, x, 1]
    P2.sync[5, op5]
    P2.write[6, op6, y, 1]
    P3.read[7, op7, y, 1]
    P3.write[8, op8, a, 1]
    P3.read[9, op9, a, 1]
}

fact {
    a.final[2]
}

Allowed:
    run { Allowed_PPC } for 5 int expect 1