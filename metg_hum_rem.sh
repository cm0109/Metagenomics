# Created by: Chiranjit Mukherjee
# Updated: 10/20/2020
# For M2020 GI Metagenomics Pipeline

# This script removed host (human) reads from whole metagenome shotgun sequencing fastq files

# Required arguments for the script: 
# arg 1: batch number (for directory naming)
# arg 2: path to data directory
# arg 3: number of threads

# Example: /home/chiranjit/scripts/metg_hum_rem.sh 8 hum_test 12

# Make new processing folder & switch to it
mkdir batch$1_process
cd batch$1_process

# Make new fastq directory for the batch
mkdir batch$1_fastqs

# Find fastq files in the downloaded data directory and move to fastq directory
find $2 -type f -name "*.fastq.gz" -exec cp '{}' batch$1_fastqs/ \;

# Set fastq directory as cwd
cd batch$1_fastqs

# Set Conda environment
eval "$(conda shell.bash hook)"

conda create -y -n sam_bed -c conda-forge -c bioconda -c defaults \
samtools bedtools

conda activate sam_bed


# For each fastq file
for f in *_R1_001.fastq.gz # for each sample F

do
    n=${f%%_R1_001.fastq.gz} # strip part of file name

	bowtie2 -x /home/chiranjit/databases/hg38/host_db -1 ${n}_R1_001.fastq.gz \
	-2 ${n}_R2_001.fastq.gz -S ${n}_mapped_unmapped.sam -p $3
	
	samtools view -bS ${n}_mapped_unmapped.sam > ${n}_mapped_unmapped.bam
	
	samtools view -b -f 12 -F 256 ${n}_mapped_unmapped.bam \
	> ${n}_bothEndsUnmapped.bam
	
	samtools sort -n ${n}_bothEndsUnmapped.bam \
	> ${n}_bothEndsUnmapped_sorted.bam
	
	bedtools bamtofastq -i ${n}_bothEndsUnmapped_sorted.bam -fq \
	${n}_nohuman_R1.fastq -fq2 ${n}_nohuman_R2.fastq

done

# Find SAM files and delete (to save space)
find . -type f -name "*.sam" -exec rm -rf {} \;

# Create new directory for intermediate files 
mkdir batch$1_hum_intermeds

# Find intermedediate files and move them to designated directory
find . -type f -name "*.bam" -exec mv '{}' batch$1_hum_intermeds/ \;

# Create new directory for human reads removed fastq files
mkdir batch$1_human_removed
find . -type f -name "*_nohuman_*" -exec mv '{}' batch$1_human_removed/ \;

# Move directories up one level to processing directory
mv batch$1_hum_intermeds batch$1_human_removed ..

conda deactivate

echo "Completed!"
