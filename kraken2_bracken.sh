#!/bin/bash

# This script runs Kraken2 on paired FASTQ files & Bracken on K2 report file

# Required: Kraken2 & Bracken installed, trimmed FASTQs/links in CWD

# arg1: number of threads
# arg2: location of db

# Make script executable: chmod +x kraken2_bracken.sh

# To run: 
# <path>/kraken2.sh <number_of_threads> <location_of_db>
# Example: /kraken2.sh 42 /vol_b/kraken2-db/

for f in *_R1_trimmed.fastq.gz # for each sample F

do
    n=${f%%_R1_trimmed.fastq.gz} # strip part of file name

	kraken2 --threads $1 --db $2 \
	--paired ${n}_R1_trimmed.fastq.gz ${n}_R2_trimmed.fastq.gz \
	--output ${n}_kraken2_out.txt --report ${n}_kraken2_report.txt

done

for k in *_kraken2_report.txt # for each sample k2 report file

do
    m=${k%%_kraken2_report.txt} # strip part of file name

	bracken -r 150 -d $2 -i ${m}_kraken2_report.txt -o ${m}_bracken_out.txt

done
