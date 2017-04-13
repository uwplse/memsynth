module tests/safe069

open program
open model

/**
PPC safe069
"SyncdWR Fre SyncdWW Wse"
Cycle=SyncdWR Fre SyncdWW Wse
Relax=
Safe=Fre Wse SyncdWW SyncdWR
{
0:r2=x; 0:r4=y;
1:r2=y; 1:r4=x;
}
 P0           | P1           ;
 li r1,1      | li r1,2      ;
 stw r1,0(r2) | stw r1,0(r2) ;
 sync         | sync         ;
 li r3,1      | lwz r3,0(r4) ;
 stw r3,0(r4) |              ;
exists
(y=2 /\ 1:r3=0)


**/


one sig x, y extends Location {}

one sig P1, P2 extends Processor {}

one sig op1 extends Write {}
one sig op2 extends Sync {}
one sig op3 extends Write {}
one sig op4 extends Write {}
one sig op5 extends Sync {}
one sig op6 extends Read {}

fact {
    P1.write[1, op1, x, 1]
    P1.sync[2, op2]
    P1.write[3, op3, y, 1]
    P2.write[4, op4, y, 2]
    P2.sync[5, op5]
    P2.read[6, op6, x, 0]
}

fact {
    y.final[2]
}

Allowed:
    run { Allowed_PPC } for 4 int expect 0