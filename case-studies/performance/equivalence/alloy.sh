#!/bin/bash
set -e

FILE="alloy/equivalence.rkt"

raco make $FILE

echo "Comparing with Alloy*..."
racket $FILE
