#!/bin/bash
set -e

# Initialisation script to prepare everything for the complete pipeline
# Please check the memory / threads parameters in the sub-files and adapt if necessary.

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
conda env remove -n cat-megahit-env
conda env remove -n cat-diamond-env

conda create -n cat-base-env python=3.10 -y

conda activate cat-base-env 
conda install -c bioconda sra-tools=2.11.0 -y
conda install -c bioconda bwa=0.7.17 -y
conda install -c bioconda samtools=1.6 -y
conda install -c bioconda trimmomatic=0.39 -y
conda install -c conda-forge minifasta=2.4 -y
conda install -c bioconda fastq=1.2.2 -y
conda install -c bioconda fastqc -y

conda create -n cat-megahit-env python=3.6 -y

conda activate cat-megahit-env
conda install -c bioconda megahit=1.1.2 -y

conda create -n cat-diamond-env python=3.10 -y

conda activate cat-diamond-env
conda install -c bioconda diamond=2.0.15 -y
conda install -c bioconda megan=6.21.7 -y

# Install version 0.38 of cd-hit
# Or download the binary and adapt the path in "pipeline/filter_cdhit_diamond_megan.sh"
# conda install -c bioconda cd-hit -y

