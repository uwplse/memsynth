module tests/safe297

open program
open model

/**
PPC safe297
"Rfe SyncdRR Fre SyncsWW Rfe DpdW Wsi"
Cycle=Rfe SyncdRR Fre SyncsWW Rfe DpdW Wsi
Relax=
Safe=Fre Wsi DpdW ACSyncdRR BCSyncsWW
{
0:r2=y; 0:r4=x;
1:r2=x;
2:r2=x; 2:r5=y;
}
 P0           | P1           | P2            ;
 lwz r1,0(r2) | li r1,1      | lwz r1,0(r2)  ;
 sync         | stw r1,0(r2) | xor r3,r1,r1  ;
 lwz r3,0(r4) | sync         | li r4,1       ;
              | li r3,2      | stwx r4,r3,r5 ;
              | stw r3,0(r2) | li r6,2       ;
              |              | stw r6,0(r5)  ;
exists
(x=2 /\ y=2 /\ 0:r1=2 /\ 0:r3=0 /\ 2:r1=2)


**/


one sig x, y extends Location {}

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
    P1.read[1, op1, y, 2]
    P1.sync[2, op2]
    P1.read[3, op3, x, 0]
    P2.write[4, op4, x, 1]
    P2.sync[5, op5]
    P2.write[6, op6, x, 2]
    P3.read[7, op7, x, 2]
    P3.write[8, op8, y, 1] and op8.dep[op7]
    P3.write[9, op9, y, 2]
}

fact {
    y.final[2]
    x.final[2]
}

Allowed:
    run { Allowed_PPC } for 5 int expect 0