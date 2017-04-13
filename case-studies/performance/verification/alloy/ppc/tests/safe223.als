module tests/safe223

open program
open model

/**
PPC safe223
"SyncdWW Rfe DpdR Fre Rfe SyncdRW Wse"
Cycle=SyncdWW Rfe DpdR Fre Rfe SyncdRW Wse
Relax=
Safe=Fre Wse DpdR ACSyncdRW BCSyncdWW
{
0:r2=x; 0:r5=y;
1:r2=y;
2:r2=y; 2:r4=z;
3:r2=z; 3:r4=x;
}
 P0            | P1           | P2           | P3           ;
 lwz r1,0(r2)  | li r1,1      | lwz r1,0(r2) | li r1,2      ;
 xor r3,r1,r1  | stw r1,0(r2) | sync         | stw r1,0(r2) ;
 lwzx r4,r3,r5 |              | li r3,1      | sync         ;
               |              | stw r3,0(r4) | li r3,1      ;
               |              |              | stw r3,0(r4) ;
exists
(z=2 /\ 0:r1=1 /\ 0:r4=0 /\ 2:r1=1)


**/


one sig x, y, z extends Location {}

one sig P1, P2, P3, P4 extends Processor {}

one sig op1 extends Read {}
one sig op2 extends Read {}
one sig op3 extends Write {}
one sig op4 extends Read {}
one sig op5 extends Sync {}
one sig op6 extends Write {}
one sig op7 extends Write {}
one sig op8 extends Sync {}
one sig op9 extends Write {}

fact {
    P1.read[1, op1, x, 1]
    P1.read[2, op2, y, 0] and op2.dep[op1]
    P2.write[3, op3, y, 1]
    P3.read[4, op4, y, 1]
    P3.sync[5, op5]
    P3.write[6, op6, z, 1]
    P4.write[7, op7, z, 2]
    P4.sync[8, op8]
    P4.write[9, op9, x, 1]
}

fact {
    z.final[2]
}

Allowed:
    run { Allowed_PPC } for 5 int expect 0