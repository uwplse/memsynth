module tests/podrwposwr000

open program
open model

/**
PPC podrwposwr000
"Fre SyncdWW Rfe DpdR PodRW PosWR"
Cycle=Fre SyncdWW Rfe DpdR PodRW PosWR
Relax=[PodRW,PosWR]
Safe=Fre DpdR BCSyncdWW
{
0:r2=z; 0:r4=x;
1:r2=x; 1:r5=y; 1:r7=z;
}
 P0           | P1            ;
 li r1,2      | lwz r1,0(r2)  ;
 stw r1,0(r2) | xor r3,r1,r1  ;
 sync         | lwzx r4,r3,r5 ;
 li r3,1      | li r6,1       ;
 stw r3,0(r4) | stw r6,0(r7)  ;
              | lwz r8,0(r7)  ;
exists
(z=2 /\ 1:r1=1 /\ 1:r8=1)


**/


one sig x, z extends Location {}

one sig P1, P2 extends Processor {}

one sig op1 extends Write {}
one sig op2 extends Sync {}
one sig op3 extends Write {}
one sig op4 extends Read {}
one sig op5 extends Write {}
one sig op6 extends Read {}

fact {
    P1.write[1, op1, z, 2]
    P1.sync[2, op2]
    P1.write[3, op3, x, 1]
    P2.read[4, op4, x, 1]
    P2.write[5, op5, z, 1]
    P2.read[6, op6, z, 1]
}

fact {
    z.final[2]
}

Allowed:
    run { Allowed_PPC } for 4 int expect 1