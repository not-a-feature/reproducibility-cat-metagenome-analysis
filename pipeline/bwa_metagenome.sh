#!/bin/bash
set -e

# Takes sample id (eg.: SRR16235395) as input, aligns the preprocessed reads
# against the metagenome reference.

INPUT=$1
BASENAME=$(basename $INPUT)

WS=$2

METAGENOME="$WS/data/bwa_indiv/metagen_ref.fa"
RELFREQSCRIPT="$WS/pipeline/relative_frequencies.py"
TAXONOMY="$WS/data/classification"

BWA_OUTPUT_DIR="$WS/data/bwa_indiv"
CONTIGS_OUTPUT_DIR="$WS/data/contigs"
RELFREQ_OUTPUT_DIR="$WS/data/relfreqs"

PE_FORWARD="$WS/data/pear_reads/$BASENAME.unassembled.forward.fastq"
PE_REVERSE="$WS/data/pear_reads/$BASENAME.unassembled.reverse.fastq"

SAM_FILE="$CONTIGS_OUTPUT_DIR/$BASENAME.extracted.sam"
CONTIGS_FILE="$CONTIGS_OUTPUT_DIR/$BASENAME.contig.aligned"

#bwa mem
echo "Aligning against reference metagenom"
bwa mem -t 60 \
	$METAGENOME \
	$PE_FORWARD $PE_REVERSE \
	-o "$BWA_OUTPUT_DIR/$BASENAME.metaaligned.bam"


#samtools view IDs of aligned reads of metagenome and bam to sam

echo "Extracting aligned against reference contigs"
samtools view -h -o $SAM_FILE $BWA_OUTPUT_DIR/"$BASENAME.metaaligned.bam"

grep -v "@" $SAM_FILE | awk '{if ($3 != "*") print $3}' > $CONTIGS_FILE


#python script to calculate relative frequencies

echo "Calculating relative frequencies"
$RELFREQSCRIPT $TAXONOMY $CONTIGS_FILE > $RELFREQ_OUTPUT_DIR/"$BASENAME.relfreq"