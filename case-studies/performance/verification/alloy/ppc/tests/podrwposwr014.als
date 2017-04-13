module tests/podrwposwr014

open program
open model

/**
PPC podrwposwr014
"Fre SyncdWW Rfe SyncdRW Wse SyncdWW Rfe DpdR PodRW PosWR"
Cycle=Fre SyncdWW Rfe SyncdRW Wse SyncdWW Rfe DpdR PodRW PosWR
Relax=[PodRW,PosWR]
Safe=Fre Wse SyncdRW DpdR BCSyncdWW
{
0:r2=b; 0:r4=x;
1:r2=x; 1:r4=y;
2:r2=y; 2:r4=z;
3:r2=z; 3:r5=a; 3:r7=b;
}
 P0           | P1           | P2           | P3            ;
 li r1,2      | lwz r1,0(r2) | li r1,2      | lwz r1,0(r2)  ;
 stw r1,0(r2) | sync         | stw r1,0(r2) | xor r3,r1,r1  ;
 sync         | li r3,1      | sync         | lwzx r4,r3,r5 ;
 li r3,1      | stw r3,0(r4) | li r3,1      | li r6,1       ;
 stw r3,0(r4) |              | stw r3,0(r4) | stw r6,0(r7)  ;
              |              |              | lwz r8,0(r7)  ;
exists
(b=2 /\ y=2 /\ 1:r1=1 /\ 3:r1=1 /\ 3:r8=1)


**/


one sig b, x, y, z extends Location {}

one sig P1, P2, P3, P4 extends Processor {}

one sig op1 extends Write {}
one sig op2 extends Sync {}
one sig op3 extends Write {}
one sig op4 extends Read {}
one sig op5 extends Sync {}
one sig op6 extends Write {}
one sig op7 extends Write {}
one sig op8 extends Sync {}
one sig op9 extends Write {}
one sig op10 extends Read {}
one sig op11 extends Write {}
one sig op12 extends Read {}

fact {
    P1.write[1, op1, b, 2]
    P1.sync[2, op2]
    P1.write[3, op3, x, 1]
    P2.read[4, op4, x, 1]
    P2.sync[5, op5]
    P2.write[6, op6, y, 1]
    P3.write[7, op7, y, 2]
    P3.sync[8, op8]
    P3.write[9, op9, z, 1]
    P4.read[10, op10, z, 1]
    P4.write[11, op11, b, 1]
    P4.read[12, op12, b, 1]
}

fact {
    y.final[2]
    b.final[2]
}

Allowed:
    run { Allowed_PPC } for 5 int expect 1