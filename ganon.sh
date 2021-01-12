#!/bin/bash

# This script runs Ganon on paired FASTQ files & generates report file

# Required: Ganon installed, trimmed FASTQs/links in CWD, Ganon db built

# arg1: number of threads
# arg2: db prefix

# Make script executable: chmod +x kraken2_bracken.sh

# To run: 
# <path>/ganon.sh <number_of_threads> <db prefix>
# Example: ganon.sh 42 /vol_b/ganon-db/ganon-complete-genomes-arc-bac-human-viral-fungi

for f in *_R1_trimmed.fastq.gz # for each sample F

do
    n=${f%%_R1_trimmed.fastq.gz} # strip part of file name

	ganon classify --threads $1 --db-prefix $2 \
	--paired-reads ${n}_R1_trimmed.fastq.gz ${n}_R2_trimmed.fastq.gz \
	-o ${n}_ganon

done

for r in *_ganon.rep # for each sample ganon report file

do
    m=${r%%_ganon.rep} # strip part of file name
	
	ganon report --db-prefix $2 --rep-file ${m}_ganon.rep --ranks species \
	--output-report ${m}_ganon_species.txt

done