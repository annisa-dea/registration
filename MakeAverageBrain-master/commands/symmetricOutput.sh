#!/usr/bin/env bash

#$ -l h_vmem=6G

REGBINDIR="/home/emily/cmtk/build/bin"

export PATH="$REGBINDIR:$PATH"


NEWREFPATH=$1
SYMREFPATH=$2
GJROOT=$3
REGROOT=$4

cd "$REGROOT/commands"

R --no-save --args ${NEWREFPATH} ${SYMREFPATH} ${GJROOT} < MakeSymmetricStandardBrain.R
