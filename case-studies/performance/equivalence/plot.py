#!/usr/bin/env python

import matplotlib.pyplot as plt
import os
import sys

if not os.path.exists("memsynth.csv"):
    print "couldn't find memsynth.csv. you might need to run ./memsynth.sh first."
    sys.exit(1)
if not os.path.exists("alloy.csv"):
    print "couldn't find alloy.csv. you might need to run ./alloy.sh first."
    sys.exit(1)

# read the successful results from the CSVs
memsynth = []
alloy = []
with open("memsynth.csv") as f:
    for line in f:
        _, t, res = line.split(",")
        if res.strip() != "timeout":
            memsynth.append(float(t)/1000.0)
with open("alloy.csv") as f:
    for line in f:
        _, t, res = line.split(",")
        if res.strip() != "timeout":
            alloy.append(float(t)/1000.0)


# analysis: maximum times
memsynth_max = max(*memsynth)
alloy_max = max(*alloy)
print "Maximum time for MemSynth: %.2f secs" % memsynth_max
print "Maximum time for Alloy: %.2f secs" % alloy_max


# make sure the two end at the same x-axis point for prettier plot
if memsynth_max < alloy_max:
    memsynth.append(alloy_max)
else:
    alloy.append(memsynth_max)


# plot the graph
plot = plt.semilogx()

h1 = plt.hist(memsynth, cumulative=True, histtype='step', bins=1000, color="#C20003", label="MemSynth")
h2 = plt.hist(alloy, cumulative=True, histtype='step', bins=1000, color="#6BB7F5", label="Alloy")

plt.xlabel("Time per problem (s)")
plt.ylabel("Problems solved")
plt.title("Equivalence query")
plt.legend(loc='upper left')

plt.show()