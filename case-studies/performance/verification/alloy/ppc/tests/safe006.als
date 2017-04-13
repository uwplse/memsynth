module tests/safe006

open program
open model

/**
PPC safe006
"SyncdWW Rfe SyncsRW Rfe DpdW Wse"
Cycle=SyncdWW Rfe SyncsRW Rfe DpdW Wse
Relax=
Safe=Wse DpdW BCSyncsRW BCSyncdWW
{
0:r2=x;
1:r2=x; 1:r5=y;
2:r2=y; 2:r4=x;
}
 P0           | P1            | P2           ;
 lwz r1,0(r2) | lwz r1,0(r2)  | li r1,2      ;
 sync         | xor r3,r1,r1  | stw r1,0(r2) ;
 li r3,2      | li r4,1       | sync         ;
 stw r3,0(r2) | stwx r4,r3,r5 | li r3,1      ;
              |               | stw r3,0(r4) ;
exists
(x=2 /\ y=2 /\ 0:r1=1 /\ 1:r1=2)


**/


one sig x, y extends Location {}

one sig P1, P2, P3 extends Processor {}

one sig op1 extends Read {}
one sig op2 extends Sync {}
one sig op3 extends Write {}
one sig op4 extends Read {}
one sig op5 extends Write {}
one sig op6 extends Write {}
one sig op7 extends Sync {}
one sig op8 extends Write {}

fact {
    P1.read[1, op1, x, 1]
    P1.sync[2, op2]
    P1.write[3, op3, x, 2]
    P2.read[4, op4, x, 2]
    P2.write[5, op5, y, 1] and op5.dep[op4]
    P3.write[6, op6, y, 2]
    P3.sync[7, op7]
    P3.write[8, op8, x, 1]
}

fact {
    y.final[2]
    x.final[2]
}

Allowed:
    run { Allowed_PPC } for 5 int expect 0