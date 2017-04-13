## Performance case study

This directory contains case studies that compare MemSynth's performance
to existing tools on [verification](verification),
[equivalence](equivalence),
and [synthesis](synthesis) queries.

### Requirements

Alloy experiments require a Java JDK (to access `javac`).

Herd experiments require [`herdtools`](http://diy.inria.fr),
which can be installed via OPAM:

    opam install herdtools7

Plotting the graph for the [equivalence](equivalence) experiment
requires Python and matplotlib.