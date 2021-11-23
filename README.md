# MemSynth

[![Build Status](https://travis-ci.org/uwplse/memsynth.svg?branch=master)](https://travis-ci.org/uwplse/memsynth)

[MemSynth](http://memsynth.uwplse.org)
is a system for automatic synthesis of axiomatic memory model specifications from litmus tests.

Read more about MemSynth in our [PLDI 2017 paper](http://memsynth.uwplse.org/memsynth-pldi17.pdf).

## Getting started

MemSynth requires [Racket](https://download.racket-lang.org/), [Rosette](http://emina.github.io/rosette/), and [Ocelot](https://github.com/jamesbornholt/ocelot).

Assuming you have Racket installed, run:

    raco pkg install --auto ocelot

to install Ocelot and Rosette.

To check that everything is working, run MemSynth's tests:

    make test

### Reproducing our experiments

Our [artifact evaluation guide](http://memsynth.uwplse.org/pldi17-aec/)
contains a thorough walkthrough to reproducing all the results from our paper.

### Exploring the MemSynth API

One of our case studies uses MemSynth to automatically repair an existing
memory model framework.
[This example](case-studies/repair/repair.rkt)
also serves as a readable walkthrough of verification and synthesis using the MemSynth API.

## Memory model synthesis

MemSynth (in the [`memsynth`](memsynth/) directory) provides
synthesis and verification algorithms for memory models.
These algorithms take as input a memory model *framework sketch*.
Two examples of framework sketches are included
in the [`frameworks`](frameworks/) directory:
one based on work by [Alglave et al.](http://www0.cs.ucl.ac.uk/staff/J.Alglave/papers/cav10.pdf) 
and the other by [Mador-Haim et al.](http://dl.acm.org/citation.cfm?id=2024842).

We use the Alglave framework to synthesize
a specification of the PowerPC memory model;
that demonstration is in [ppc0.rkt](case-studies/synthesis/ppc/ppc0.rkt). 
It uses 768 litmus tests from Alglave's work, 
which are defined in our litmus test DSL in [ppc-all.rkt](litmus/tests/ppc-all.rkt).

## Interacting with other tools

MemSynth supports the [Herd](http://diy.inria.fr) format for litmus tests.
We provide a [compiler](litmus/herd/compile.rkt) from that format
(supporting only PowerPC tests, without control flow)
to MemSynth's litmus test DSL.

## Folder Structure

* Depends: `ocelot`, `rosette`, `opencl-racket`
  * you will need to run `cd opencl-racket && raco pkg install` inorder to install `opencl-racket`
  * then, you will need to run `cd..; cd rosette && raco pkg install` inorder to install `rosette`
  * finally, you will need to run `cd..; cd ocelot && raco pkg install` inorder to install `ocelot`
    * ocelot depends on rosette, so do not attempt to install ocelot before rosette
* Memsynth Source Files: `memsynth`
* Our Source Files: `gpu`
