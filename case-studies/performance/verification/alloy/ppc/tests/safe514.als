module tests/safe514

open program
open model

/**
PPC safe514
"SyncsWW Rfe DpdW Rfe SyncdRR Fre"
Cycle=SyncsWW Rfe DpdW Rfe SyncdRR Fre
Relax=
Safe=Fre DpdW ACSyncdRR BCSyncsWW
{
0:r2=y; 0:r5=x;
1:r2=x; 1:r4=y;
2:r2=y;
}
 P0            | P1           | P2           ;
 lwz r1,0(r2)  | lwz r1,0(r2) | li r1,1      ;
 xor r3,r1,r1  | sync         | stw r1,0(r2) ;
 li r4,1       | lwz r3,0(r4) | sync         ;
 stwx r4,r3,r5 |              | li r3,2      ;
               |              | stw r3,0(r2) ;
exists
(y=2 /\ 0:r1=2 /\ 1:r1=1 /\ 1:r3=0)


**/


one sig x, y extends Location {}

one sig P1, P2, P3 extends Processor {}

one sig op1 extends Read {}
one sig op2 extends Write {}
one sig op3 extends Read {}
one sig op4 extends Sync {}
one sig op5 extends Read {}
one sig op6 extends Write {}
one sig op7 extends Sync {}
one sig op8 extends Write {}

fact {
    P1.read[1, op1, y, 2]
    P1.write[2, op2, x, 1] and op2.dep[op1]
    P2.read[3, op3, x, 1]
    P2.sync[4, op4]
    P2.read[5, op5, y, 0]
    P3.write[6, op6, y, 1]
    P3.sync[7, op7]
    P3.write[8, op8, y, 2]
}

fact {
    y.final[2]
}

Allowed:
    run { Allowed_PPC } for 5 int expect 0