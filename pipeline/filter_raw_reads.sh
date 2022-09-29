#!/bin/bash
set -e

# Takes sample id (eg.: SRR16235395) as input, aligns the reads against the feline
# and viral reference genome. Matches against those references are filtered out. 

# Read name
INPUT=$1
BASENAME=$(basename $INPUT)
WS=$2

# Path to PEAR binary
PEAR_BINARY=$WS/pipeline/pear-0.9.11-linux-x86_64/bin/pear

INPUT_1="$WS/data/raw_reads/${BASENAME}_1.fastq"
INPUT_2="$WS/data/raw_reads/${BASENAME}_2.fastq"

BWA_OUTPUT_DIR="$WS/data/bwa/aligned"
# Path to python filter script
FILTER_SCRIPT="$WS/pipeline/exclude_from_fq.py"

PEAR_FORWARD="$WS/data/pear_reads/$BASENAME.unassembled.forward.fastq"
PEAR_REVERSE="$WS/data/pear_reads/$BASENAME.unassembled.reverse.fastq"
PEAR_MERGED="$WS/data/pear_reads/$BASENAME.assembled.fastq"

# Path to Reference genome
CAT_REFERENCE_GENOME="$WS/data/bwa/GCF_000181335.3_Felis_catus_9.0_genomic.fna.gz"
VIRAL_REFERENCE_GENOME="$WS/data/bwa/viral_merged.faa"

SAM_UNMERGED="$BWA_OUTPUT_DIR/$BASENAME.pe.sam"
SAM_MERGED="$BWA_OUTPUT_DIR/$BASENAME.merged.sam"

INDEX_FILE_UNMERGED="$WS/data/extracted/$BASENAME.pe.index"
INDEX_FILE_MERGED="$WS/data/extracted/$BASENAME.merged.index"

NOCAT_FORWARD="$WS/data/extracted/$BASENAME.forward.nocat.fq"
NOCAT_REVERSE="$WS/data/extracted/$BASENAME.reverse.nocat.fq"
NOCAT_MERGED="$WS/data/extracted/$BASENAME.merged.nocat.fq"

NOCAT_SAM_UNMERGED="$BWA_OUTPUT_DIR/$BASENAME.nocat.pe.sam"
NOCAT_SAM_MERGED="$BWA_OUTPUT_DIR/$BASENAME.nocat.merged.sam"

TRIMMED_PATH="$WS/data/trimmed"

NOCAT_INDEX_FILE_UNMERGED="$WS/data/extracted/$BASENAME.nocat.pe.index"
NOCAT_INDEX_FILE_MERGED="$WS/data/extracted/$BASENAME.nocat.merged.index"

# trimming reads
PAIRED_TRIMMED_FORWARD=$TRIMMED_PATH/"${BASENAME}.ptf.fastq"
UNPAIRED_TRIMMED_FORWARD=$TRIMMED_PATH/"${BASENAME}.utf.fastq"
PAIRED_TRIMMED_REVERSE=$TRIMMED_PATH/"${BASENAME}.ptr.fastq"
UNPAIRED_TRIMMED_REVERSE=$TRIMMED_PATH/"${BASENAME}.utr.fastq"

UNPAIRED_MERGED=$TRIMMED_PATH/"${BASENAME}.um.fastq"

echo "Trimming reads."
trimmomatic PE -threads 60 \
    -trimlog $WS/"${BASENAME}.trim.log" \
    $INPUT_1 $INPUT_2 \
    $PAIRED_TRIMMED_FORWARD $UNPAIRED_TRIMMED_FORWARD \
    $PAIRED_TRIMMED_REVERSE $UNPAIRED_TRIMMED_REVERSE \
    ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 MINLEN:36

# pear reads

echo "PEAR reads"
$PEAR_BINARY -f $PAIRED_TRIMMED_FORWARD \
     -r $PAIRED_TRIMMED_REVERSE \
     -o $WS/pear_reads/$BASENAME \
     -j 60 # threads

# merging PEAR and trimmomatic stuff

cat $PEAR_MERGED $UNPAIRED_TRIMMED_FORWARD $UNPAIRED_TRIMMED_REVERSE > $UNPAIRED_MERGED

# filter cat


echo "Map vs. cat reference."
echo "Filtering cats. 1/2"
bwa mem -t 60 \
   $CAT_REFERENCE_GENOME \
   $PEAR_FORWARD $PEAR_REVERSE \
   -o "$BWA_OUTPUT_DIR/$BASENAME.cataligned.pe.bam"
echo "Filtering cats. 2/2"
bwa mem -t 60 \
   $CAT_REFERENCE_GENOME \
   $UNPAIRED_MERGED \
   -o "$BWA_OUTPUT_DIR/$BASENAME.cataligned.merged.bam"

echo "Extracting headers."
samtools view -Shf 4 -h $BWA_OUTPUT_DIR/"$BASENAME.cataligned.pe.bam" > $SAM_UNMERGED
samtools view -Shf 4 -h $BWA_OUTPUT_DIR/"$BASENAME.cataligned.merged.bam" > $SAM_MERGED

echo "Creating extracted ID list."
grep -v "@" $SAM_UNMERGED  | awk NF=1 > $INDEX_FILE_UNMERGED
grep -v "@" $SAM_MERGED  | awk NF=1 > $INDEX_FILE_MERGED

echo "Filtering reads."
python3 $FILTER_SCRIPT -l $INDEX_FILE_UNMERGED -fq $PEAR_FORWARD -o $NOCAT_FORWARD
python3 $FILTER_SCRIPT -l $INDEX_FILE_UNMERGED -fq $PEAR_REVERSE -o $NOCAT_REVERSE
python3 $FILTER_SCRIPT -l $INDEX_FILE_MERGED -fq $UNPAIRED_MERGED -o $NOCAT_MERGED

# filter virus

echo "Map vs. virus reference."
echo "Filtering viruses. 1/2"
bwa mem -t 60 $VIRAL_REFERENCE_GENOME $NOCAT_FORWARD $NOCAT_REVERSE -o $BWA_OUTPUT_DIR/"$BASENAME.virusaligned.nocat.pe.bam"
echo "Filtering viruses. 2/2"
bwa mem -t 60 $VIRAL_REFERENCE_GENOME $NOCAT_MERGED -o $BWA_OUTPUT_DIR/"$BASENAME.virusaligned.nocat.merged.bam"

echo "Extracting headers."
samtools view -Shf 4 -h $BWA_OUTPUT_DIR/"$BASENAME.virusaligned.nocat.pe.bam" > $NOCAT_SAM_UNMERGED
samtools view -Shf 4 -h $BWA_OUTPUT_DIR/"$BASENAME.virusaligned.nocat.merged.bam" > $NOCAT_SAM_MERGED

echo "Creating extracted ID list."
grep -v "@" $NOCAT_SAM_UNMERGED  | awk NF=1 > $NOCAT_INDEX_FILE_UNMERGED
grep -v "@" $NOCAT_SAM_MERGED  | awk NF=1 > $NOCAT_INDEX_FILE_MERGED

echo "Filtering reads."
python3 $FILTER_SCRIPT -l $NOCAT_INDEX_FILE_UNMERGED -fq $NOCAT_FORWARD -o "$WS/data/extracted/$BASENAME.forward.filtered.fq"
python3 $FILTER_SCRIPT -l $NOCAT_INDEX_FILE_UNMERGED -fq $NOCAT_REVERSE -o "$WS/data/extracted/$BASENAME.reverse.filtered.fq"
python3 $FILTER_SCRIPT -l $NOCAT_INDEX_FILE_MERGED -fq $NOCAT_MERGED -o "$WS/data/extracted/$BASENAME.merged.filtered.fq"

echo "Create fastqc reports"
fastqc -t 20 $TRIMMED_PATH/*.fastq \
    || fastqc -t 20 $WS/data/pear_reads/*.fastq \
    || fastqc -t 20 $WS/data/extracted/*.fq \
    || true

chmod -R 771 $TRIMMED_PATH \
    || chmod -R 771 $BWA_OUTPUT_DIR \
    || chmod -R 771 $WS/data/extracted \
    || chmod -R 771 $WS/data/pear_reads \
    || true

