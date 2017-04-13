#!/bin/bash
set -e

TESTS="herd/tests/*.litmus"

echo "Verifying with Herd..."
time (herd7 -speedcheck fast $TESTS > /dev/null)
