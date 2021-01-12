#!/bin/bash

# This script runs Centrifuge on paired FASTQ files & generates Kraken style report

# Required: Centrifuge installed, trimmed FASTQs/links in CWD, Centrifuge db built

# arg1: number of threads
# arg2: db prefix

# Make script executable: chmod +x kraken2_bracken.sh

# To run: 
# <path>/centrifuge.sh <number_of_threads> <location_of_db>
# Example: /centrifuge.sh 42 #/vol_b/centrifuge-db/centrifuge-complete-genomes-arc-bac-human-viral-fungi


for f in *_R1_trimmed.fastq.gz # for each sample F

do
    n=${f%%_R1_trimmed.fastq.gz} # strip part of file name
	
	centrifuge -p $1 -x $2 -k 1 -1 ${n}_R1_trimmed.fastq.gz -2 ${n}_R2_trimmed.fastq.gz -S ${n}_centrifuge_out.txt --report-file \
	${n}_centrifuge_report.txt

done

for r in *_centrifuge_out.txt # for each sample output file

do
    m=${r%%_centrifuge_out.txt} # strip part of file name
	
	centrifuge-kreport -x $2 ${m}_centrifuge_out.txt > ${m}_centrifuge_reformatted_out.txt

done