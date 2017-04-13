module tests/safe175

open program
open model

/**
PPC safe175
"SyncdWW Rfe DpdW Rfe SyncsRR Fre LwSyncdWW Wse"
Cycle=SyncdWW Rfe DpdW Rfe SyncsRR Fre LwSyncdWW Wse
Relax=
Safe=Fre Wse LwSyncdWW DpdW ACSyncsRR BCSyncdWW
{
0:r2=x; 0:r5=y;
1:r2=y;
2:r2=y; 2:r4=z;
3:r2=z; 3:r4=x;
}
 P0            | P1           | P2           | P3           ;
 lwz r1,0(r2)  | lwz r1,0(r2) | li r1,2      | li r1,2      ;
 xor r3,r1,r1  | sync         | stw r1,0(r2) | stw r1,0(r2) ;
 li r4,1       | lwz r3,0(r2) | lwsync       | sync         ;
 stwx r4,r3,r5 |              | li r3,1      | li r3,1      ;
               |              | stw r3,0(r4) | stw r3,0(r4) ;
exists
(y=2 /\ z=2 /\ 0:r1=1 /\ 1:r1=1 /\ 1:r3=1)


**/


one sig x, y, z extends Location {}

one sig P1, P2, P3, P4 extends Processor {}

one sig op1 extends Read {}
one sig op2 extends Write {}
one sig op3 extends Read {}
one sig op4 extends Sync {}
one sig op5 extends Read {}
one sig op6 extends Write {}
one sig op7 extends Lwsync {}
one sig op8 extends Write {}
one sig op9 extends Write {}
one sig op10 extends Sync {}
one sig op11 extends Write {}

fact {
    P1.read[1, op1, x, 1]
    P1.write[2, op2, y, 1] and op2.dep[op1]
    P2.read[3, op3, y, 1]
    P2.sync[4, op4]
    P2.read[5, op5, y, 1]
    P3.write[6, op6, y, 2]
    P3.lwsync[7, op7]
    P3.write[8, op8, z, 1]
    P4.write[9, op9, z, 2]
    P4.sync[10, op10]
    P4.write[11, op11, x, 1]
}

fact {
    y.final[2]
    z.final[2]
}

Allowed:
    run { Allowed_PPC } for 5 int expect 0