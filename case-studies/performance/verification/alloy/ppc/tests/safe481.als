module tests/safe481

open program
open model

/**
PPC safe481
"SyncdWW Rfe SyncsRW Rfe DpdR Fri Rfe SyncsRR Fre"
Cycle=SyncdWW Rfe SyncsRW Rfe DpdR Fri Rfe SyncsRR Fre
Relax=
Safe=Fri Fre DpdR ACSyncsRR BCSyncsRW BCSyncdWW
{
0:r2=x;
1:r2=x; 1:r5=y;
2:r2=y;
3:r2=y; 3:r4=x;
}
 P0           | P1            | P2           | P3           ;
 lwz r1,0(r2) | lwz r1,0(r2)  | lwz r1,0(r2) | li r1,2      ;
 sync         | xor r3,r1,r1  | sync         | stw r1,0(r2) ;
 li r3,2      | lwzx r4,r3,r5 | lwz r3,0(r2) | sync         ;
 stw r3,0(r2) | li r6,1       |              | li r3,1      ;
              | stw r6,0(r5)  |              | stw r3,0(r4) ;
exists
(x=2 /\ y=2 /\ 0:r1=1 /\ 1:r1=2 /\ 1:r4=0 /\ 2:r1=1 /\ 2:r3=1)


**/


one sig x, y extends Location {}

one sig P1, P2, P3, P4 extends Processor {}

one sig op1 extends Read {}
one sig op2 extends Sync {}
one sig op3 extends Write {}
one sig op4 extends Read {}
one sig op5 extends Read {}
one sig op6 extends Write {}
one sig op7 extends Read {}
one sig op8 extends Sync {}
one sig op9 extends Read {}
one sig op10 extends Write {}
one sig op11 extends Sync {}
one sig op12 extends Write {}

fact {
    P1.read[1, op1, x, 1]
    P1.sync[2, op2]
    P1.write[3, op3, x, 2]
    P2.read[4, op4, x, 2]
    P2.read[5, op5, y, 0] and op5.dep[op4]
    P2.write[6, op6, y, 1]
    P3.read[7, op7, y, 1]
    P3.sync[8, op8]
    P3.read[9, op9, y, 1]
    P4.write[10, op10, y, 2]
    P4.sync[11, op11]
    P4.write[12, op12, x, 1]
}

fact {
    y.final[2]
    x.final[2]
}

Allowed:
    run { Allowed_PPC } for 5 int expect 0