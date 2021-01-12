#!/bin/bash

# This script runs Kraken2 on paired FASTQ files & Bracken on K2 report file

# Required: Kraken2 & Bracken installed, trimmed FASTQs/links in CWD


# arg 1: batch number
# arg 2: data directory
# arg 3: number of threads
# arg 4: location of db

# Make script executable: chmod +x kraken2_bracken.sh

# To run: 
# <path>/kraken2.sh <number_of_threads> <location_of_db>
# Example: /kraken2.sh 42 /vol_b/kraken2-db/


# Unzip files
find $2 -name "*.zip" -exec unzip {} -d $2 \;


# Make new fastq directory for the batch
mkdir batch$1_fastqs

# Find fastq files in the downloaded data directory and move to fastq directory
find $2 -type f -name "*.fastq.gz" -exec cp '{}' batch$1_fastqs/ \;

# Set fastq directory as cwd
cd batch$1_fastqs

# Set Conda environment

source /opt/miniconda3/etc/profile.d/conda.sh

conda create -y -n k2br -c conda-forge -c bioconda -c defaults \
kraken2=2.0.9beta bracken=2.6.0 trimmomatic

conda activate k2br

# Add trimmomatic adapter seq info
cp /opt/miniconda3/pkgs/trimmomatic-*/share/trimmomatic-*/adapters/TruSeq3-PE.fa .

# Trimming FASTQ files with Trimmomatic

# Create new directory for trimmed & unpaired fastqs 
mkdir batch$1_trimmed_fqs
mkdir batch$1_unpaired_fqs

# For each fastq file
for f in *_R1_001.fastq.gz # for each sample F

do
    n=${f%%_R1_001.fastq.gz} # strip part of file name

	trimmomatic PE -threads $3 ${n}_R1_001.fastq.gz  ${n}_R2_001.fastq.gz \
	batch$1_trimmed_fqs/${n}_R1_trimmed.fastq.gz \
	batch$1_unpaired_fqs/${n}_R1_unpaired.fastq.gz \
	batch$1_trimmed_fqs/${n}_R2_trimmed.fastq.gz \
	batch$1_unpaired_fqs/${n}_R2_unpaired.fastq.gz \
	ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 LEADING:3 TRAILING:3 \
	SLIDINGWINDOW:4:15 MINLEN:36

done



# Classifying reads with Kraken2

# Create new directory for Kraken2 output 
mkdir batch$1_k2_results



# For each trimmed fastq file
for k in batch$1_trimmed_fqs/*_R1_trimmed.fastq.gz # for each trimmed sample

do
    l=$(basename $k)
    m=${l%%_R1_trimmed.fastq.gz} # strip part of file name

	kraken2 --threads $3 --db $4 \
	--paired batch$1_trimmed_fqs/${m}_R1_trimmed.fastq.gz \
	batch$1_trimmed_fqs/${m}_R2_trimmed.fastq.gz \
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

# Process results with R
/home/cmicro/scripts/bracken_to_counts.R batch$1_br_results $2

conda deactivate

echo "Finished!"
