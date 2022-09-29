#!/bin/bash
set -e

# Creates a metagenomic reference using megahit
# Takes 4 sample ids as input
WS=$5

INPUT_1=$1
ID_1=$(basename $INPUT_1)
INPUT_2=$2
ID_2=$(basename $INPUT_2)
INPUT_3=$3
ID_3=$(basename $INPUT_3)
INPUT_4=$4
ID_4=$(basename $INPUT_4)

megahit -1 $ID_1.forward.filtered.fq,$ID_2.forward.filtered.fq,$ID_3.forward.filtered.fq,$ID_4.forward.filtered.fq \
    -2 $ID_1.reverse.filtered.fq,$ID_2.reverse.filtered.fq,$ID_3.reverse.filtered.fq,$ID_4.reverse.filtered.fq \
    -r $ID_1.merged.filtered.fq,$ID_2.merged.filtered.fq,$ID_3.merged.filtered.fq,$ID_4.merged.filtered.fq \
    -t 48 \
    -o $WS/data/assembly
