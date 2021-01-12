#!/bin/bash

# This script runs Trimmomatic & Kraken2 on paired FASTQ files & Bracken on K2 report file

# Required: Human removed fastq files


# arg 1: batch number
# arg 2: path to target fastqs (human removed)
# arg 3: number of threads
# arg 4: path to K2 db

# Make script executable: chmod +x trim_k2br_R_bk.sh

# To run:
# Ex: trim_k2br_R_bk.sh 8 batch8_human_removed 20 k2db_oct2020_cm/


# Create working directory
mkdir batch$1_trk2br

# Make symbolic links for quality trimming
find $2 -type f -exec ln -s {} batch$1_trk2br/ \;

# Set fastq directory as cwd
cd batch$1_trk2br

# Set Conda environment
eval "$(conda shell.bash hook)"

conda create -y -n k2br -c conda-forge -c bioconda -c defaults \
kraken2=2.0.9beta bracken=2.6.0 trimmomatic

conda activate k2br

# Copy trimmomatic adapter seq info to cwd
cp /home/chiranjit/scripts/TruSeq3-PE.fa .


# Trimming FASTQ files with Trimmomatic

# Create new directory for unpaired fastqs
mkdir batch$1_trimmed_fqs
mkdir batch$1_unpaired_fqs

# For each fastq file
for f in *_R1.fastq # for each sample F

do
    n=${f%%_R1.fastq} # strip part of file name

	trimmomatic PE -threads $3 ${n}_R1.fastq  ${n}_R2.fastq \
	batch$1_trimmed_fqs/${n}_R1_trimmed.fastq \
	batch$1_unpaired_fqs/${n}_R1_unpaired.fastq \
	batch$1_trimmed_fqs/${n}_R2_trimmed.fastq \
	batch$1_unpaired_fqs/${n}_R2_unpaired.fastq \
	ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 LEADING:3 TRAILING:3 \
	SLIDINGWINDOW:4:15 MINLEN:36

done



# Classifying reads with Kraken2

# Create new directory for Kraken2 output 
mkdir batch$1_k2_results

# For each trimmed fastq file
for k in batch$1_trimmed_fqs/*_R1_trimmed.fastq # for each trimmed sample

do
    l=$(basename $k)
    m=${l%%_R1_trimmed.fastq} # strip part of file name

	kraken2 --threads $3 --db $4 \
	--paired batch$1_trimmed_fqs/${m}_R1_trimmed.fastq \
	batch$1_trimmed_fqs/${m}_R2_trimmed.fastq \
	--output batch$1_k2_results/${m}_kraken2_out.txt \
	--report batch$1_k2_results/${m}_kraken2_report.txt

done



# Estimating abundances with Bracken

# Create new directory for Bracken output 
mkdir batch$1_br_results

# For each Kraken2 report
for b in batch$1_k2_results/*_kraken2_report.txt # for each sample k2 report file

do
	p=$(basename $b)
    o=${p%%_kraken2_report.txt} # strip part of file name

	bracken -r 150 -d $4 \
	-i batch$1_k2_results/${o}_kraken2_report.txt \
	-o batch$1_br_results/${o}_bracken_out.txt

done

conda deactivate

# Process results with R
/home/chiranjit/scripts/bracken_to_counts.R batch$1_br_results $1


echo "Finished!"
