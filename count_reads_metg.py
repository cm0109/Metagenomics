#!/usr/bin/python

# Created by Chiranjit Mukherjee, November 2020

# For counting FASTQ files by dividing number of lines by 4

# System Argument 1 (required): path to target directory
# System Argument 2: "gz" if zipped files
# System Argument 3: output file name, no extention needed, in quotes
# Ex1: python <path>count_lines.py (From within a directory which contains the fastq files) "<path>" "gz" "stat1"
# Ex2: python <path>count_lines.py (From within a directory which contains the fastq files) "<path>" "fq" "stat2"

import sys
import glob
import gzip

dir1 = sys.argv[1]
outfile = sys.argv[3]

with open(outfile , 'w') as out:
    list_of_files = sorted(glob.glob(dir1 + '/*.fastq*'))
    for file_name in list_of_files:
        if sys.argv[2] == "gz":
            with gzip.open(file_name, 'r') as f:
                count = sum(1 for line in f)/4  # (Sum of lines)/4
                out.write('{f}\t{c}\n'.format(c = int(count), f = file_name))
        else:
            with open(file_name, 'r') as f:
                count = sum(1 for line in f)/4 # (Sum of lines)/4
                out.write('{f}\t{c}\n'.format(c = int(count), f = file_name))
