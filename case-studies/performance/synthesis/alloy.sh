#!/bin/bash
set -e

FILE="alloy/synthesis.rkt"

raco make $FILE

echo "Synthesizing with Alloy*..."
racket $FILE
