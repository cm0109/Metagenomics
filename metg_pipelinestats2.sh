# This script will generate stats for human removal and k2br scripts
# Created by Chiranjit Mukherjee, November 23rd, 2020

# Run from batchn_process directory
# arg1: batch number (example: 8)

# Get stats for raw fastq files (zipped)
python /home/chiranjit/scripts/count_reads_metg.py batch$1_fastqs "gz" "stat1.txt"

# Get stats for human removed fastq files
python /home/chiranjit/scripts/count_reads_metg.py batch$1_human_removed "fq" "stat2.txt"

# Get stats for human removed fastq files
python /home/chiranjit/scripts/count_reads_metg.py batch$1_trk2br/batch$1_trimmed_fqs "fq" "stat3.txt"

# Combine files
paste  stat1.txt  stat2.txt stat3.txt | column -s $'\t' -t > batch$1_stat_comb.txt

# Clean columns and generate final stat file
cat batch$1_stat_comb.txt | tr -s '\/' '\t' | awk '{print $2 "\t" $3 "\t" $6 "\t" $10}' > batch$1_stats.txt

# Add headers
sed -i $'1 i\\\nfile\traw\thum_rem\tfilt' batch$1_stats.txt

# Remove temporary files
rm stat1.txt  stat2.txt stat3.txt batch$1_stat_comb.txt

echo "Finished!"