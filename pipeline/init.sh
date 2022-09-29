#!/bin/bash
set -e

# Initialisation script to prepare everything for the complete pipeline
# Please check the memory / threads parameters in the sub-files and adapt if necessary.

# This will install version 4.8.1 of cd-hit
# For the version 3.7 download the binary manually
# In any case: go to "pipeline/filter_cdhit_diamond_megan.sh" and set the correct path/command

WS="/workspace/reproducibility-cat-metagenome-analysis"
CONDA_SH_PATH="/workspace/kreuerju/miniconda3/etc/profile.d/conda.sh"

# Create the necessary structure
mkdir -p $WS/pipeline

# Folder for binaries manual to add
mkdir -p $WS/pipeline/cdhit # Optional see bottom of file
mkdir -p $WS/pipeline/pear-0.9.11-linux-x86_64


mkdir -p $WS/data
mkdir -p $WS/data/assembly
mkdir -p $WS/data/bwa
mkdir -p $WS/data/bwa/aligned
mkdir -p $WS/data/bwa_indiv
mkdir -p $WS/data/classification
mkdir -p $WS/data/contigs
mkdir -p $WS/data/diamond
mkdir -p $WS/data/extracted
mkdir -p $WS/data/pear_reads
mkdir -p $WS/data/raw_reads
mkdir -p $WS/data/relfreqs
mkdir -p $WS/data/trimmed

# Create conda enviroments
source $CONDA_SH_PATH

conda env remove -n cat-base-env
conda env remove -n cat-diamond-env
conda env remove -n cat-megahit-env

conda env create --file $WS/data/cat-base-env.yaml
conda env create --file $WS/data/cat-diamond-env.yaml
conda env create --file $WS/data/cat-megahit-env.yaml


