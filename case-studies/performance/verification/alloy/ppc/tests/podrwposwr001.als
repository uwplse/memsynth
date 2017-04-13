module tests/podrwposwr001

open program
open model

/**
PPC podrwposwr001
"Fre SyncdWW Rfe DpdR PodRW PosWR Fre SyncdWW Rfe DpdR PodRW PosWR"
Cycle=Fre SyncdWW Rfe DpdR PodRW PosWR Fre SyncdWW Rfe DpdR PodRW PosWR
Relax=[PodRW,PosWR]
Safe=Fre DpdR BCSyncdWW
{
0:r2=c; 0:r4=x;
1:r2=x; 1:r5=y; 1:r7=z;
2:r2=z; 2:r4=a;
3:r2=a; 3:r5=b; 3:r7=c;
}
 P0           | P1            | P2           | P3            ;
 li r1,2      | lwz r1,0(r2)  | li r1,2      | lwz r1,0(r2)  ;
 stw r1,0(r2) | xor r3,r1,r1  | stw r1,0(r2) | xor r3,r1,r1  ;
 sync         | lwzx r4,r3,r5 | sync         | lwzx r4,r3,r5 ;
 li r3,1      | li r6,1       | li r3,1      | li r6,1       ;
 stw r3,0(r4) | stw r6,0(r7)  | stw r3,0(r4) | stw r6,0(r7)  ;
              | lwz r8,0(r7)  |              | lwz r8,0(r7)  ;
exists
(c=2 /\ z=2 /\ 1:r1=1 /\ 1:r8=1 /\ 3:r1=1 /\ 3:r8=1)


**/


one sig a, c, x, z extends Location {}

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

fact {
    P1.write[1, op1, c, 2]
    P1.sync[2, op2]
    P1.write[3, op3, x, 1]
    P2.read[4, op4, x, 1]
    P2.write[5, op5, z, 1]
    P2.read[6, op6, z, 1]
    P3.write[7, op7, z, 2]
    P3.sync[8, op8]
    P3.write[9, op9, a, 1]
    P4.read[10, op10, a, 1]
    P4.write[11, op11, c, 1]
    P4.read[12, op12, c, 1]
}

fact {
    c.final[2]
    z.final[2]
}

Allowed:
    run { Allowed_PPC } for 5 int expect 1