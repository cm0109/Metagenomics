#!/bin/bash
# This script runs Kraken2 on paired FASTQ files
# Required: Kraken2 installed, trimmed FASTQs/links in CWD
# arg1: number of threads
# arg2: location of db
# to run: 
# chmod +x kraken2.sh
# <path>/kraken2.sh <number_of_threads> <location_of_db>
# Example: /kraken2.sh 42 /vol_b/kraken2-db/

for f in *_R1_trimmed.fastq.gz # for each sample F

do
    n=${f%%_R1_trimmed.fastq.gz} # strip part of file name

	kraken2 --threads $1 --db $2 \
	--paired ${n}_R1_trimmed.fastq.gz ${n}_R2_trimmed.fastq.gz \
	--output ${n}_kraken2_out.txt --report ${n}_kraken2_report.txt

done



