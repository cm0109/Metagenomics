#!/usr/bin/env Rscript

# Shell-executable R script
# Processes Bracken report files & generate counts
# Usage: ./bracken_to_counts.R "<directory path to bracken results>" "<batch>"

# For arguments
args <- commandArgs(trailingOnly = TRUE)

# Load library
if(!require(dplyr)){install.packages("dplyr")}

# Custom function for importing report files (3 arguments, file names, how many characters to keep, include header or not)
my_read_txt <- function(x, n, h) {
  out <- read.delim(x, sep = "\t", quote = "", stringsAsFactors = FALSE, header = h)
  sample <- substr(basename(x), 8, n) # basename removes directory, and substr selects 1:7 characters here
  cbind(accession=sample, out) # adding sample name as a column
}

# List all files in the bracken_out directory
brep_files <- list.files(path=args[1], pattern="*.txt", full.names=TRUE) 
brep.m <- bind_rows(lapply(brep_files, my_read_txt, 14, TRUE)) # apply the custom txt reading function to each file, and bind the list by row

# Write output file
write.table(brep.m, file=paste0("batch", args[2],"_k2br_est.txt"), sep="\t", quote = FALSE, row.names = FALSE)