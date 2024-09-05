#!/bin/bash

# This script processes VCF files based on the mode specified as an argument.
# The mode can be either 'split' or 'merged'.
# 'split' mode processes multiple VCF files based on contig IDs.
# 'merged' mode processes a single merged VCF file.

# Check if an argument was provided
if [ -z "$1" ]; then
  echo "Usage: $0 <split|merged>"
  exit 1
fi

# Read the argument
mode=$1

# Define the path to the directory containing VCF files
path_vcf="../../results/vcf"

# Check if the mode is 'split'
if [ "$mode" == "split" ]; then

    # Array of contigs to be processed in 'split' mode
    # You can change these IDs based on your species or data
    contigs=("001133" "001134" "001135" "001136" "001137" "001138" "001139" "001140"
             "001141" "001142" "001143" "001144" "001145" "001146" "001147" "001148" "001224")

    # Loop through each contig and process the corresponding VCF file
    for contig in "${contigs[@]}"; do
        input_vcf="${path_vcf}/unfiltered_merged_strains_${contig}.vcf.gz"
        output_table="table_scores_${contig}.tsv"
        # Submitting the job with sbatch to process each VCF file
        sbatch get_data_scores.sh $input_vcf $output_table
    done

# Check if the mode is 'merged'
elif [ "$mode" == "merged" ]; then
    
    input_vcf="${path_vcf}/unfiltered_merged_strains.vcf.gz"
    output_table="table_scores_merged.tsv"
    # Submitting the job with sbatch to process the merged VCF file
    sbatch get_data_scores.sh $input_vcf $output_table

# Handle invalid mode
else
  echo "Invalid argument: $mode"
  echo "Usage: $0 <split|merged>"
  exit 1
fi
