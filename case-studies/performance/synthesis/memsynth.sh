#!/bin/bash
set -e

FILE="memsynth/synthesis.rkt"

raco make $FILE

echo "Synthesizing with Memsynth..."
racket $FILE
