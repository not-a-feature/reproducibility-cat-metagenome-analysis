#!/bin/bash
set -e

# Main script to compute the complete pipeline
# Please check the memory / threads parameters in the sub-files and adapt if necessary.

WS="/workspace/reproducibility-cat-metagenome-analysis"
CONDA_SH_PATH="/workspace/kreuerju/miniconda3/etc/profile.d/conda.sh"


# Sample ids
ID_1="SRR16235395"
ID_2="SRR16235398"
ID_3="SRR16235394"
ID_4="SRR16235406"


# Create conda enviroments
source $CONDA_SH_PATH

conda activate cat-base-env

# Download files
$WS/pipeline/downlad_data.sh $ID_1 $ID_2 $ID_3 $ID_4

# Filter cat and viral contamination
$WS/pipeline/filter_raw_reads.sh $ID_1 $WS
$WS/pipeline/filter_raw_reads.sh $ID_2 $WS
$WS/pipeline/filter_raw_reads.sh $ID_3 $WS
$WS/pipeline/filter_raw_reads.sh $ID_4 $WS


# Create metagenomic reference
conda activate cat-megahit-env
$WS/pipeline/megathit.sh $ID_1 $ID_2 $ID_3 $ID_4 $WS

# Filter metagenomic reference and annotate it
conda activate cat-diamond-env
$WS/pipeline/filter_cdhit_diamond_megan.sh $WS/data/assembly/final.contigs.fa $WS

# Align preprocessed reads against metagenomic reference
conda activate cat-base-env

$WS/pipeline/bwa_metagenome.sh $ID_1 $WS
$WS/pipeline/bwa_metagenome.sh $ID_2 $WS
$WS/pipeline/bwa_metagenome.sh $ID_3 $WS
$WS/pipeline/bwa_metagenome.sh $ID_4 $WS
