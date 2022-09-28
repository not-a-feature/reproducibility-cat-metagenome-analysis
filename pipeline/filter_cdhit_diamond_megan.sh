#!/bin/bash
set -e

# Takes the megahit reference, filters it, and assignes a taxonomy to it using diamond and megan
# Saves the meganized daa to data/diamond/metagen_red_matches.daa

# INPUT = reference fasta

INPUT=$1
WS=$2

PYTHON_SCRIPT="$WS/pipeline/filter_short_contigs.py"
PY_OUT_PATH="$WS/data/assembly/metagen_ref_filtered.fa"

# Path to cd-hit-est binary
# Or replace: CDHIT_BIN="cd-hit-est" when using the conda installation

CDHIT_BIN="$WS/pipeline/cdhit/cd-hit-est"

OUT_PATH="$WS/data/assembly/metagen_ref_filtered_cdhit.fa"
BWA_PATH="$WS/data/bwa_indiv/metagen_ref.fa"
CLASSIFICATION_PATH="$WS/data/classification"

# Filter short contigs
python3 $PYTHON_SCRIPT -fa $INPUT -l 400 -o $PY_OUT_PATH
# Filter redundant contigs
$CDHIT_BIN  -i $PY_OUT_PATH -o $OUT_PATH -c 0.95 -M 90000 -T 0

# Runs diamond and megan to assign taxonomy
DAA_OUT_PATH="$WS/data/diamond/metagen_ref_matches.daa"
DIAMONDDB="$WS/data/diamond/annotree.dmnd"
MEGANDB="$WS/pipeline/diamond/megan-mapping-annotree-June-2021.db"

diamond blastx -p 60 -d $DIAMONDDB -q $OUT_PATH -o $DAA_OUT_PATH --outfmt 100
daa-meganizer -i $DAA_OUT_PATH -mdb $MEGANDB 

daa2info -i $DAA_OUT_PATH -r2c Taxonomy -n >> $CLASSIFICATION_PATH



# BWA index for individual alignment of samples against metagenomic reference
cp $OUT_PATH $BWA_PATH
bwa index $BWA_PATH