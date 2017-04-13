module tests/safe242

open program
open model

/**
PPC safe242
"SyncdWW Rfe DpdW Rfe SyncdRW Wse"
Cycle=SyncdWW Rfe DpdW Rfe SyncdRW Wse
Relax=
Safe=Wse DpdW ACSyncdRW BCSyncdWW
{
0:r2=x; 0:r5=y;
1:r2=y; 1:r4=z;
2:r2=z; 2:r4=x;
}
 P0            | P1           | P2           ;
 lwz r1,0(r2)  | lwz r1,0(r2) | li r1,2      ;
 xor r3,r1,r1  | sync         | stw r1,0(r2) ;
 li r4,1       | li r3,1      | sync         ;
 stwx r4,r3,r5 | stw r3,0(r4) | li r3,1      ;
               |              | stw r3,0(r4) ;
exists
(z=2 /\ 0:r1=1 /\ 1:r1=1)


**/


one sig x, y, z extends Location {}

one sig P1, P2, P3 extends Processor {}

one sig op1 extends Read {}
one sig op2 extends Write {}
one sig op3 extends Read {}
one sig op4 extends Sync {}
one sig op5 extends Write {}
one sig op6 extends Write {}
one sig op7 extends Sync {}
one sig op8 extends Write {}

fact {
    P1.read[1, op1, x, 1]
    P1.write[2, op2, y, 1] and op2.dep[op1]
    P2.read[3, op3, y, 1]
    P2.sync[4, op4]
    P2.write[5, op5, z, 1]
    P3.write[6, op6, z, 2]
    P3.sync[7, op7]
    P3.write[8, op8, x, 1]
}

fact {
    z.final[2]
}

Allowed:
    run { Allowed_PPC } for 5 int expect 0