module tests/aclwsrr003

open program
open model

/**
PPC aclwsrr003
"Fre SyncdWW Rfe LwSyncsRR DpdR Fre Rfe LwSyncsRR"
Cycle=Fre SyncdWW Rfe LwSyncsRR DpdR Fre Rfe LwSyncsRR
Relax=ACLwSyncsRR
Safe=Fre SyncdWW DpdR
{
0:r2=y; 0:r4=x;
1:r2=x; 1:r6=y;
2:r2=y;
3:r2=y;
}
 P0           | P1            | P2           | P3           ;
 li r1,2      | lwz r1,0(r2)  | li r1,1      | lwz r1,0(r2) ;
 stw r1,0(r2) | lwsync        | stw r1,0(r2) | lwsync       ;
 sync         | lwz r3,0(r2)  |              | lwz r3,0(r2) ;
 li r3,1      | xor r4,r3,r3  |              |              ;
 stw r3,0(r4) | lwzx r5,r4,r6 |              |              ;
exists
(y=2 /\ 1:r1=1 /\ 1:r3=1 /\ 1:r5=0 /\ 3:r1=1 /\ 3:r3=1)


**/


one sig x, y extends Location {}

one sig P1, P2, P3, P4 extends Processor {}

one sig op1 extends Write {}
one sig op2 extends Sync {}
one sig op3 extends Write {}
one sig op4 extends Read {}
one sig op5 extends Lwsync {}
one sig op6 extends Read {}
one sig op7 extends Read {}
one sig op8 extends Write {}
one sig op9 extends Read {}
one sig op10 extends Lwsync {}
one sig op11 extends Read {}

fact {
    P1.write[1, op1, y, 2]
    P1.sync[2, op2]
    P1.write[3, op3, x, 1]
    P2.read[4, op4, x, 1]
    P2.lwsync[5, op5]
    P2.read[6, op6, x, 1]
    P2.read[7, op7, y, 0] and op7.dep[op6]
    P3.write[8, op8, y, 1]
    P4.read[9, op9, y, 1]
    P4.lwsync[10, op10]
    P4.read[11, op11, y, 1]
}

fact {
    y.final[2]
}

Allowed:
    run { Allowed_PPC } for 5 int expect 0