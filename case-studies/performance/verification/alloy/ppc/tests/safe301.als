module tests/safe301

open program
open model

/**
PPC safe301
"Rfe SyncdRR Fre SyncdWW Rfe DpdW Wsi"
Cycle=Rfe SyncdRR Fre SyncdWW Rfe DpdW Wsi
Relax=
Safe=Fre Wsi DpdW ACSyncdRR BCSyncdWW
{
0:r2=z; 0:r4=x;
1:r2=x; 1:r4=y;
2:r2=y; 2:r5=z;
}
 P0           | P1           | P2            ;
 lwz r1,0(r2) | li r1,1      | lwz r1,0(r2)  ;
 sync         | stw r1,0(r2) | xor r3,r1,r1  ;
 lwz r3,0(r4) | sync         | li r4,1       ;
              | li r3,1      | stwx r4,r3,r5 ;
              | stw r3,0(r4) | li r6,2       ;
              |              | stw r6,0(r5)  ;
exists
(z=2 /\ 0:r1=2 /\ 0:r3=0 /\ 2:r1=1)


**/


one sig x, y, z extends Location {}

one sig P1, P2, P3 extends Processor {}

one sig op1 extends Read {}
one sig op2 extends Sync {}
one sig op3 extends Read {}
one sig op4 extends Write {}
one sig op5 extends Sync {}
one sig op6 extends Write {}
one sig op7 extends Read {}
one sig op8 extends Write {}
one sig op9 extends Write {}

fact {
    P1.read[1, op1, z, 2]
    P1.sync[2, op2]
    P1.read[3, op3, x, 0]
    P2.write[4, op4, x, 1]
    P2.sync[5, op5]
    P2.write[6, op6, y, 1]
    P3.read[7, op7, y, 1]
    P3.write[8, op8, z, 1] and op8.dep[op7]
    P3.write[9, op9, z, 2]
}

fact {
    z.final[2]
}

Allowed:
    run { Allowed_PPC } for 5 int expect 0