#!/bin/bash
set -e

FILE="memsynth/equivalence.rkt"

raco make $FILE

echo "Comparing with Memsynth..."
racket $FILE
