module tests/safe300

open program
open model

/**
PPC safe300
"Rfe SyncdRW Rfe SyncsRR Fre SyncdWW Rfe DpdW Wsi"
Cycle=Rfe SyncdRW Rfe SyncsRR Fre SyncdWW Rfe DpdW Wsi
Relax=
Safe=Fre Wsi DpdW ACSyncsRR ACSyncdRW BCSyncdWW
{
0:r2=z; 0:r4=x;
1:r2=x;
2:r2=x; 2:r4=y;
3:r2=y; 3:r5=z;
}
 P0           | P1           | P2           | P3            ;
 lwz r1,0(r2) | lwz r1,0(r2) | li r1,2      | lwz r1,0(r2)  ;
 sync         | sync         | stw r1,0(r2) | xor r3,r1,r1  ;
 li r3,1      | lwz r3,0(r2) | sync         | li r4,1       ;
 stw r3,0(r4) |              | li r3,1      | stwx r4,r3,r5 ;
              |              | stw r3,0(r4) | li r6,2       ;
              |              |              | stw r6,0(r5)  ;
exists
(x=2 /\ z=2 /\ 0:r1=2 /\ 1:r1=1 /\ 1:r3=1 /\ 3:r1=1)


**/


one sig x, y, z extends Location {}

one sig P1, P2, P3, P4 extends Processor {}

one sig op1 extends Read {}
one sig op2 extends Sync {}
one sig op3 extends Write {}
one sig op4 extends Read {}
one sig op5 extends Sync {}
one sig op6 extends Read {}
one sig op7 extends Write {}
one sig op8 extends Sync {}
one sig op9 extends Write {}
one sig op10 extends Read {}
one sig op11 extends Write {}
one sig op12 extends Write {}

fact {
    P1.read[1, op1, z, 2]
    P1.sync[2, op2]
    P1.write[3, op3, x, 1]
    P2.read[4, op4, x, 1]
    P2.sync[5, op5]
    P2.read[6, op6, x, 1]
    P3.write[7, op7, x, 2]
    P3.sync[8, op8]
    P3.write[9, op9, y, 1]
    P4.read[10, op10, y, 1]
    P4.write[11, op11, z, 1] and op11.dep[op10]
    P4.write[12, op12, z, 2]
}

fact {
    x.final[2]
    z.final[2]
}

Allowed:
    run { Allowed_PPC } for 5 int expect 0