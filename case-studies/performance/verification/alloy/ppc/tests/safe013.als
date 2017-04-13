module tests/safe013

open program
open model

/**
PPC safe013
"SyncdWW Wse SyncdWW Rfe DpdW Wse"
Cycle=SyncdWW Wse SyncdWW Rfe DpdW Wse
Relax=
Safe=Wse SyncdWW DpdW BCSyncdWW
{
0:r2=x; 0:r4=y;
1:r2=y; 1:r5=z;
2:r2=z; 2:r4=x;
}
 P0           | P1            | P2           ;
 li r1,2      | lwz r1,0(r2)  | li r1,2      ;
 stw r1,0(r2) | xor r3,r1,r1  | stw r1,0(r2) ;
 sync         | li r4,1       | sync         ;
 li r3,1      | stwx r4,r3,r5 | li r3,1      ;
 stw r3,0(r4) |               | stw r3,0(r4) ;
exists
(x=2 /\ z=2 /\ 1:r1=1)


**/


one sig x, y, z extends Location {}

one sig P1, P2, P3 extends Processor {}

one sig op1 extends Write {}
one sig op2 extends Sync {}
one sig op3 extends Write {}
one sig op4 extends Read {}
one sig op5 extends Write {}
one sig op6 extends Write {}
one sig op7 extends Sync {}
one sig op8 extends Write {}

fact {
    P1.write[1, op1, x, 2]
    P1.sync[2, op2]
    P1.write[3, op3, y, 1]
    P2.read[4, op4, y, 1]
    P2.write[5, op5, z, 1] and op5.dep[op4]
    P3.write[6, op6, z, 2]
    P3.sync[7, op7]
    P3.write[8, op8, x, 1]
}

fact {
    x.final[2]
    z.final[2]
}

Allowed:
    run { Allowed_PPC } for 5 int expect 0