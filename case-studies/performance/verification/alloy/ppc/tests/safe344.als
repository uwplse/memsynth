module tests/safe344

open program
open model

/**
PPC safe344
"SyncdWW Rfe DpsR Fre SyncdWW Rfe DpsR Fre"
Cycle=SyncdWW Rfe DpsR Fre SyncdWW Rfe DpsR Fre
Relax=
Safe=Fre DpsR BCSyncdWW
{
0:r2=x;
1:r2=x; 1:r4=y;
2:r2=y;
3:r2=y; 3:r4=x;
}
 P0            | P1           | P2            | P3           ;
 lwz r1,0(r2)  | li r1,2      | lwz r1,0(r2)  | li r1,2      ;
 xor r3,r1,r1  | stw r1,0(r2) | xor r3,r1,r1  | stw r1,0(r2) ;
 lwzx r4,r3,r2 | sync         | lwzx r4,r3,r2 | sync         ;
               | li r3,1      |               | li r3,1      ;
               | stw r3,0(r4) |               | stw r3,0(r4) ;
exists
(x=2 /\ y=2 /\ 0:r1=1 /\ 0:r4=1 /\ 2:r1=1 /\ 2:r4=1)


**/


one sig x, y extends Location {}

one sig P1, P2, P3, P4 extends Processor {}

one sig op1 extends Read {}
one sig op2 extends Read {}
one sig op3 extends Write {}
one sig op4 extends Sync {}
one sig op5 extends Write {}
one sig op6 extends Read {}
one sig op7 extends Read {}
one sig op8 extends Write {}
one sig op9 extends Sync {}
one sig op10 extends Write {}

fact {
    P1.read[1, op1, x, 1]
    P1.read[2, op2, x, 1] and op2.dep[op1]
    P2.write[3, op3, x, 2]
    P2.sync[4, op4]
    P2.write[5, op5, y, 1]
    P3.read[6, op6, y, 1]
    P3.read[7, op7, y, 1] and op7.dep[op6]
    P4.write[8, op8, y, 2]
    P4.sync[9, op9]
    P4.write[10, op10, x, 1]
}

fact {
    y.final[2]
    x.final[2]
}

Allowed:
    run { Allowed_PPC } for 5 int expect 0