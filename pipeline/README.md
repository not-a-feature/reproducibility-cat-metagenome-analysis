# Pipeline
This folder includes all python / bash scripts used for the recreation of the original pipeline.

| Filename | Description |
| -------- | ----------  |
| exclude_from_fq.py  | Excludes fastq entries from file that are not in the in a list |
| filter_short_contigs.py | Removes contigs shorter 400 | 
| group_assignment_data.py | Assignment to phylum, only a data, no logic | 
| relative_frequencies.py | Takes the classification and computes the relative frequency |
| bwa_metagenome.sh | Aligns preprocessed reads against metagenomic reference |
| download_data.sh | Download and prepares raw data form NCBI archives |
| filter_cdhit_diamond_megan.sh | Filters metagenomic reference and assignes a taxonomy to it using diamond and megan |
| filter_raw_reads.sh | Preprocess raw reads, filter matche against feline / viral reference out | 
| init.sh | Create folder structure and conda enviroments with all required dependencies |
| main.sh | Main script to run the pipeline (run init.sh first) |
| megahit.sh | Creates a metagenomic reference using the preprocessed reads. |
| pipeline_overview.png | Overview of the pipeline |

## Overview
![Pipeline overview](pipeline_overview.png)