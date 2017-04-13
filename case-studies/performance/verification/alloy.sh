#!/bin/bash
set -e

FILE="alloy/verification.rkt"

raco make $FILE
racket $FILE -c

echo "Verifying with Alloy..."
time racket $FILE