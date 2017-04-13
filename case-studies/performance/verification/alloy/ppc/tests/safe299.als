module tests/safe299

open program
open model

/**
PPC safe299
"Rfe SyncdRR Fre SyncdWW Rfe SyncsRW Rfe DpdW Wsi"
Cycle=Rfe SyncdRR Fre SyncdWW Rfe SyncsRW Rfe DpdW Wsi
Relax=
Safe=Fre Wsi DpdW ACSyncdRR BCSyncsRW BCSyncdWW
{
0:r2=z; 0:r4=x;
1:r2=x; 1:r4=y;
2:r2=y;
3:r2=y; 3:r5=z;
}
 P0           | P1           | P2           | P3            ;
 lwz r1,0(r2) | li r1,1      | lwz r1,0(r2) | lwz r1,0(r2)  ;
 sync         | stw r1,0(r2) | sync         | xor r3,r1,r1  ;
 lwz r3,0(r4) | sync         | li r3,2      | li r4,1       ;
              | li r3,1      | stw r3,0(r2) | stwx r4,r3,r5 ;
              | stw r3,0(r4) |              | li r6,2       ;
              |              |              | stw r6,0(r5)  ;
exists
(y=2 /\ z=2 /\ 0:r1=2 /\ 0:r3=0 /\ 2:r1=1 /\ 3:r1=2)


**/


one sig x, y, z extends Location {}

one sig P1, P2, P3, P4 extends Processor {}

one sig op1 extends Read {}
one sig op2 extends Sync {}
one sig op3 extends Read {}
one sig op4 extends Write {}
one sig op5 extends Sync {}
one sig op6 extends Write {}
one sig op7 extends Read {}
one sig op8 extends Sync {}
one sig op9 extends Write {}
one sig op10 extends Read {}
one sig op11 extends Write {}
one sig op12 extends Write {}

fact {
    P1.read[1, op1, z, 2]
    P1.sync[2, op2]
    P1.read[3, op3, x, 0]
    P2.write[4, op4, x, 1]
    P2.sync[5, op5]
    P2.write[6, op6, y, 1]
    P3.read[7, op7, y, 1]
    P3.sync[8, op8]
    P3.write[9, op9, y, 2]
    P4.read[10, op10, y, 2]
    P4.write[11, op11, z, 1] and op11.dep[op10]
    P4.write[12, op12, z, 2]
}

fact {
    y.final[2]
    z.final[2]
}

Allowed:
    run { Allowed_PPC } for 5 int expect 0