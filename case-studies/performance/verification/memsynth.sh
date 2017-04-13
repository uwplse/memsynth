#!/bin/bash
set -e

THIS_DIR=`dirname $BASH_SOURCE`
MEMSYNTH_ROOT="$THIS_DIR/../../../"
FILE="$MEMSYNTH_ROOT/frameworks/alglave/test/ppc/verify-test.rkt"

raco make $FILE

echo "Verifying with Memsynth..."
time (racket $FILE > /dev/null)
