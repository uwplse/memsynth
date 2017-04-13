module tests/safe073

open program
open model

/**
PPC safe073
"Rfe SyncdRR Fre SyncdWR Fre SyncdWW Wse"
Cycle=Rfe SyncdRR Fre SyncdWR Fre SyncdWW Wse
Relax=
Safe=Fre Wse SyncdWW SyncdWR ACSyncdRR
{
0:r2=z; 0:r4=x;
1:r2=x; 1:r4=y;
2:r2=y; 2:r4=z;
3:r2=z;
}
 P0           | P1           | P2           | P3           ;
 lwz r1,0(r2) | li r1,1      | li r1,1      | li r1,2      ;
 sync         | stw r1,0(r2) | stw r1,0(r2) | stw r1,0(r2) ;
 lwz r3,0(r4) | sync         | sync         |              ;
              | lwz r3,0(r4) | li r3,1      |              ;
              |              | stw r3,0(r4) |              ;
exists
(z=2 /\ 0:r1=2 /\ 0:r3=0 /\ 1:r3=0)


**/


one sig x, y, z extends Location {}

one sig P1, P2, P3, P4 extends Processor {}

one sig op1 extends Read {}
one sig op2 extends Sync {}
one sig op3 extends Read {}
one sig op4 extends Write {}
one sig op5 extends Sync {}
one sig op6 extends Read {}
one sig op7 extends Write {}
one sig op8 extends Sync {}
one sig op9 extends Write {}
one sig op10 extends Write {}

fact {
    P1.read[1, op1, z, 2]
    P1.sync[2, op2]
    P1.read[3, op3, x, 0]
    P2.write[4, op4, x, 1]
    P2.sync[5, op5]
    P2.read[6, op6, y, 0]
    P3.write[7, op7, y, 1]
    P3.sync[8, op8]
    P3.write[9, op9, z, 1]
    P4.write[10, op10, z, 2]
}

fact {
    z.final[2]
}

Allowed:
    run { Allowed_PPC } for 5 int expect 0