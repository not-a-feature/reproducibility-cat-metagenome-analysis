#!/bin/bash
set -e

# Download and prepare all necessary files from the NCBI archives
# Takes 4 sample ids as input

WS="/workspace/reproducibility-cat-metagenome-analysis"
VIRAL_REFERENCE_GENOME="$WS/data/bwa/viral_merged.faa"

INPUT_1=$1
ID_1=$(basename $INPUT_1)
INPUT_2=$2
ID_2=$(basename $INPUT_2)
INPUT_3=$3
ID_3=$(basename $INPUT_3)
INPUT_4=$4
ID_4=$(basename $INPUT_4)

# Raw Reads
# Download 4 of the 16 raw reads from the SRA.
fastq-dump $ID_1 --split-3 --outdir $WS/data/raw_reads/
fastq-dump $ID_2 --split-3 --outdir $WS/data/raw_reads/
fastq-dump $ID_3 --split-3 --outdir $WS/data/raw_reads/
fastq-dump $ID_4 --split-3 --outdir $WS/data/raw_reads/

# Feline reference genome
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/181/335/GCF_000181335.3_Felis_catus_9.0/GCF_000181335.3_Felis_catus_9.0_genomic.fna.gz \
  -O $WS/data/bwa/GCF_000181335.3_Felis_catus_9.0_genomic.fna.gz

# Viral reference genome
wget ftp://ftp.ncbi.nlm.nih.gov/refseq/release/viral/viral.1.genomic.gbff.gz \
  -O $WS/data/bwa/viral.1.genomic.faa.gz

wget ftp://ftp.ncbi.nlm.nih.gov/refseq/release/viral/viral.2.genomic.gbff.gz \
  -O $WS/data/bwa/viral.2.genomic.faa.gz

wget ftp://ftp.ncbi.nlm.nih.gov/refseq/release/viral/viral.3.genomic.gbff.gz \
  -O $WS/data/bwa/viral.3.genomic.faa.gz

wget ftp://ftp.ncbi.nlm.nih.gov/refseq/release/viral/viral.4.genomic.gbff.gz \
  -O $WS/data/bwa/viral.4.genomic.faa.gz

# Unpack and merge
zcat $WS/data/bwa/viral.*.faa.gz > $WS/data/bwa/viral_merged.faa
# Index for further use
bwa index $VIRAL_REFERENCE_GENOME