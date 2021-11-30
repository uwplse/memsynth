# Result of running `tso0-unique.rkt`

<!-- * Rosette 4.0 is campatible with z3 binary file in rosette 2.2 but opposite is incampatible.
*  -->

## Docker Contianer (z3 with rosette 2.2)

**Conclusion: small version and normal version generate same result.**

### small version

```shell

root@cbb9e1987565:~/memsynth# racket case-studies/synthesis/x86/tso0-unique.rkt -s
===== TSO_0: uniqueness experiment =====

----- Generating TSO_0... -----

Tests: 10
  positive: 2
  negative: 8

Sketch state space: 2^560

Synthesizing...

Synthesis complete!
time: 2970 ms
tests used: 6/10

solution: ppo: (& po (+ (-> Writes (& (& Writes MemoryEvent) (- MemoryEvent Atomics))) (-> (+ Atomics Reads) (- MemoryEvent (& Atomics Reads)))))
          grf: (& rf (- (-> univ univ) (- (join loc (~ loc)) (- (-> univ univ) (& (join proc (~ proc)) rf)))))
           ab: (-> none none)

Verifying solution...
Verified 10 litmus tests


----- Making TSO_0 unique... -----
Litmus test sketch:
  Up to 2 threads, with up to 5 total instructions.

Making model unique...
New distinguishing test [#1]:
Test disambig0
=============================
P0            | P1           
-----------------------------
r1 <- [B]     | LOCK [A] <- 1
r2 <- [A]     | LOCK [B] <- 1
=============================
r1=1 /\ r2=0
Allowed by oracle? #f

New distinguishing test [#2]:
Test disambig1
=============================
P0            | P1           
-----------------------------
r1 <- [A]     | [B] <- 1     
r2 <- [B]     | LOCK [A] <- 1
=============================
r1=1 /\ r2=0
Allowed by oracle? #f

New distinguishing test [#3]:
Test disambig2
=============================
P0            | P1           
-----------------------------
r1 <- [B]     | r2 <- [A]    
[A] <- 1      | LOCK [B] <- 1
=============================
r1=1 /\ r2=1
Allowed by oracle? #f


Model is now unique!
time: 543806 ms
new tests: 3

solution: ppo: (& po (- (+ (& (join loc (~ loc)) (-> Atomics Atomics)) (+ po (-> Reads Reads))) (& (-> (+ MemoryEvent Atomics) Reads) (-> (- Writes Atomics) MemoryEvent))))
          grf: (& rf (- (-> univ univ) (& (join proc (~ proc)) rf)))

```

### normal version

```shell

root@cbb9e1987565:~/memsynth/case-studies/synthesis/x86# racket tso0-unique.rkt
===== TSO_0: uniqueness experiment =====

----- Generating TSO_0... -----

Tests: 10
  positive: 2
  negative: 8

Sketch state space: 2^560

Synthesizing...

Synthesis complete!
time: 2892 ms
tests used: 6/10

solution: ppo: (& po (+ (-> Writes (& (& Writes MemoryEvent) (- MemoryEvent Atomics))) (-> (+ Atomics Reads) (- MemoryEvent (& Atomics Reads)))))
          grf: (& rf (- (-> univ univ) (- (join loc (~ loc)) (- (-> univ univ) (& (join proc (~ proc)) rf)))))
           ab: (-> none none)

Verifying solution...
Verified 10 litmus tests


----- Making TSO_0 unique... -----
Litmus test sketch:
  Up to 4 threads, with up to 6 total instructions.

Making model unique...
New distinguishing test [#1]:
Test disambig0
=============================
P0            | P1           
-----------------------------
r1 <- [B]     | LOCK [A] <- 1
r2 <- [A]     | LOCK [B] <- 1
=============================
r1=1 /\ r2=0
Allowed by oracle? #f

New distinguishing test [#2]:
Test disambig1
=============================
P0            | P1           
-----------------------------
r1 <- [A]     | [B] <- 1     
r2 <- [B]     | LOCK [A] <- 1
=============================
r1=1 /\ r2=0
Allowed by oracle? #f

New distinguishing test [#3]:
Test disambig2
=============================
P0            | P1           
-----------------------------
r1 <- [B]     | r2 <- [A]    
[A] <- 1      | LOCK [B] <- 1
=============================
r1=1 /\ r2=1
Allowed by oracle? #f


Model is now unique!
time: 19753408 ms
new tests: 3

solution: ppo: (& po (- (+ (& (join loc (~ loc)) (-> Atomics Atomics)) (+ po (-> Reads Reads))) (& (-> (+ MemoryEvent Atomics) Reads) (-> (- Writes Atomics) MemoryEvent))))
          grf: (& rf (- (-> univ univ) (& (join proc (~ proc)) rf)))
           ab: (-> none none)

```

## Local Host (rosette 2.0)

Conclusion:

* Small version: Generated model doesn't change after unique process
* Normal version: produce 4 new test and unique process doesn't terminate
* Using ppc sketch will narrow search space down to 2^560 and it will terminate this time.

### small version

```shell
===== TSO_0: uniqueness experiment =====

----- Generating TSO_0... -----

Tests: 10
  positive: 2
  negative: 8

Sketch state space: 2^624

Synthesizing...

Synthesis complete!
time: 4228 ms
tests used: 6/10

solution: ppo: (& po (+ (- (& po (-> Writes MemoryEvent)) (& po (-> MemoryEvent Reads))) (+ (& (join loc (~ loc)) (-> Atomics Atomics)) (-> (+ Atomics Reads) MemoryEvent))))
          grf: (& rf (- (join loc (~ loc)) (& (join proc (~ proc)) rf)))
           ab: (-> none none)

Verifying solution...
Verified 10 litmus tests


----- Making TSO_0 unique... -----
Litmus test sketch:
  Up to 2 threads, with up to 5 total instructions.

Making model unique...
New distinguishing test [#1]:
Test disambig0
=============================
P0            | P1           
-----------------------------
r1 <- [B]     | [A] <- 1     
r2 <- [A]     | LOCK [B] <- 1
=============================
r1=1 /\ r2=0
Allowed by oracle? #f

New distinguishing test [#2]:
Test disambig1
=============================
P0            | P1           
-----------------------------
r1 <- [A]     | LOCK [B] <- 1
r2 <- [B]     | LOCK [A] <- 1
=============================
r1=1 /\ r2=0
Allowed by oracle? #f

New distinguishing test [#3]:
Test disambig2
=============================
P0            | P1           
-----------------------------
r1 <- [B]     | r2 <- [A]    
[A] <- 1      | LOCK [B] <- 1
=============================
r1=1 /\ r2=1
Allowed by oracle? #f


Model is now unique!
time: 425958 ms
new tests: 3

solution: ppo: (& po (+ (- (& po (-> Writes MemoryEvent)) (& po (-> MemoryEvent Reads))) (+ (& (join loc (~ loc)) (-> Atomics Atomics)) (-> (+ Atomics Reads) MemoryEvent))))
          grf: (& rf (- (join loc (~ loc)) (& (join proc (~ proc)) rf)))
           ab: (-> none none)
```

### normal version

```shell
===== TSO_0: uniqueness experiment =====

----- Generating TSO_0... -----

Tests: 10
  positive: 2
  negative: 8

Sketch state space: 2^624

Synthesizing...

Synthesis complete!
time: 2667 ms
tests used: 6/10

solution: ppo: (& po (+ (- (& po (-> Writes MemoryEvent)) (& po (-> MemoryEvent Reads))) (+ (& (join loc (~ loc)) (-> Atomics Atomics)) (-> (+ Atomics Reads) MemoryEvent))))
          grf: (& rf (- (join loc (~ loc)) (& (join proc (~ proc)) rf)))
           ab: (-> none none)

Verifying solution...
Verified 10 litmus tests


----- Making TSO_0 unique... -----
Litmus test sketch:
  Up to 4 threads, with up to 6 total instructions.

Making model unique...
New distinguishing test [#1]:
Test disambig0
=============================
P0            | P1           
-----------------------------
r1 <- [A]     | [B] <- 1     
r2 <- [B]     | LOCK [A] <- 1
=============================
r1=1 /\ r2=0
Allowed by oracle? #f

New distinguishing test [#2]:
Test disambig1
=============================
P0            | P1           
-----------------------------
r1 <- [B]     | LOCK [A] <- 1
r2 <- [A]     | LOCK [B] <- 1
=============================
r1=1 /\ r2=0
Allowed by oracle? #f

New distinguishing test [#3]:
Test disambig2
=============================
P0            | P1           
-----------------------------
r1 <- [B]     | r2 <- [A]    
LOCK [A] <- 1 | [B] <- 1     
=============================
r1=1 /\ r2=1
Allowed by oracle? #f

New distinguishing test [#4]:
Test disambig3
=============================
P0            | P1           
-----------------------------
[A] <- 1      | LOCK [B] <- 1
sync          | r2 <- [A]    
r1 <- [B]     |              
=============================
r1=0 /\ r2=0
Allowed by oracle? #f
```

### with ppc sketch

```shell
===== TSO_0: uniqueness experiment =====

----- Generating TSO_0... -----

Tests: 10
  positive: 2
  negative: 8

Sketch state space: 2^560

Synthesizing...

Synthesis complete!
time: 2625 ms
tests used: 6/10

solution: ppo: (& po (+ (+ (- (-> Atomics Atomics) (& (join loc (~ loc)) (-> Atomics Atomics))) (-> (+ Writes Atomics) (+ Writes Atomics))) (-> (+ Reads (& Writes Atomics)) (+ Writes (- MemoryEvent Atomics)))))
          grf: (& rf (- (- (-> univ univ) (& (join proc (~ proc)) rf)) (& (join loc (~ loc)) (& (join proc (~ proc)) rf))))
           ab: (-> none none)

Verifying solution...
Verified 10 litmus tests


----- Making TSO_0 unique... -----
Litmus test sketch:
  Up to 4 threads, with up to 6 total instructions.

Making model unique...
New distinguishing test [#1]:
Test disambig0
=============================
P0            | P1           
-----------------------------
r1 <- [A]     | [B] <- 1     
r2 <- [B]     | LOCK [A] <- 1
=============================
r1=1 /\ r2=0
Allowed by oracle? #f

New distinguishing test [#2]:
Test disambig1
=============================
P0            | P1           
-----------------------------
r1 <- [A]     | LOCK [B] <- 1
r2 <- [B]     | LOCK [A] <- 1
=============================
r1=1 /\ r2=0
Allowed by oracle? #f

New distinguishing test [#3]:
Test disambig2
=============================
P0            | P1           
-----------------------------
r1 <- [B]     | r2 <- [A]    
[A] <- 1      | LOCK [B] <- 1
=============================
r1=1 /\ r2=1
Allowed by oracle? #f

New distinguishing test [#4]:
Test disambig3
=============================
P0            | P1           
-----------------------------
[A] <- 1      | LOCK [B] <- 1
sync          | r2 <- [A]    
r1 <- [B]     |              
=============================
r1=0 /\ r2=0
Allowed by oracle? #f


Model is now unique!
time: 20146653 ms
new tests: 4

solution: ppo: (& po (& (& (- po dp) (+ po (-> Atomics MemoryEvent))) (- po (- (-> Writes Reads) (-> Atomics Reads)))))
          grf: (& rf (& (join loc (~ loc)) (& rf (- (- rf (join proc (~ proc))) (& (join proc (~ proc)) rf)))))
           ab: (-> none none)
```
