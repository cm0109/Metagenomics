#!/bin/bash
# arg1: number of threads
# to run: 
# chmod +x trim.sh
# <path>/trim.sh <number of threads>
# Example: ./trim.sh 40

for f in *_R1_001.fastq.gz # for each sample F

do
    n=${f%%_R1_001.fastq.gz} # strip part of file name

trimmomatic PE -threads $1 ${n}_R1_001.fastq.gz  ${n}_R2_001.fastq.gz \
${n}_R1_trimmed.fastq.gz ${n}_R1_unpaired.fastq.gz ${n}_R2_trimmed.fastq.gz \
${n}_R2_unpaired.fastq.gz ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 \
LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36

done