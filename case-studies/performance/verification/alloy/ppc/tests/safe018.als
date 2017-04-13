module tests/safe018

open program
open model

/**
PPC safe018
"LwSyncdWW Rfe SyncdRW Wse SyncdWW Rfe DpdW Wse"
Cycle=LwSyncdWW Rfe SyncdRW Wse SyncdWW Rfe DpdW Wse
Relax=
Safe=Wse LwSyncdWW DpdW ACSyncdRW BCSyncdWW
{
0:r2=x; 0:r4=y;
1:r2=y; 1:r4=z;
2:r2=z; 2:r5=a;
3:r2=a; 3:r4=x;
}
 P0           | P1           | P2            | P3           ;
 lwz r1,0(r2) | li r1,2      | lwz r1,0(r2)  | li r1,2      ;
 sync         | stw r1,0(r2) | xor r3,r1,r1  | stw r1,0(r2) ;
 li r3,1      | sync         | li r4,1       | lwsync       ;
 stw r3,0(r4) | li r3,1      | stwx r4,r3,r5 | li r3,1      ;
              | stw r3,0(r4) |               | stw r3,0(r4) ;
exists
(a=2 /\ y=2 /\ 0:r1=1 /\ 2:r1=1)


**/


one sig a, x, y, z extends Location {}

one sig P1, P2, P3, P4 extends Processor {}

one sig op1 extends Read {}
one sig op2 extends Sync {}
one sig op3 extends Write {}
one sig op4 extends Write {}
one sig op5 extends Sync {}
one sig op6 extends Write {}
one sig op7 extends Read {}
one sig op8 extends Write {}
one sig op9 extends Write {}
one sig op10 extends Lwsync {}
one sig op11 extends Write {}

fact {
    P1.read[1, op1, x, 1]
    P1.sync[2, op2]
    P1.write[3, op3, y, 1]
    P2.write[4, op4, y, 2]
    P2.sync[5, op5]
    P2.write[6, op6, z, 1]
    P3.read[7, op7, z, 1]
    P3.write[8, op8, a, 1] and op8.dep[op7]
    P4.write[9, op9, a, 2]
    P4.lwsync[10, op10]
    P4.write[11, op11, x, 1]
}

fact {
    a.final[2]
    y.final[2]
}

Allowed:
    run { Allowed_PPC } for 5 int expect 0