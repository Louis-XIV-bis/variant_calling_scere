#!/bin/bash

# Define the path to the directory containing VCF files
path_vcf="../../results/vcf"

# Define input and output files
input_vcf="${path_vcf}/unfiltered_yeast_strains.vcf.gz"
output_table="results/table_scores_merged.tsv"

# Check if the input VCF file exists
if [ ! -f "$input_vcf" ]; then
    echo "Error: Input VCF file $input_vcf not found!"
    exit 1
fi

# Check if the output directory exists, if not, create it
output_dir=$(dirname "$output_table")
if [ ! -d "$output_dir" ]; then
    echo "Directory $output_dir does not exist. Creating it now..."
    mkdir -p "$output_dir"
fi

# Submitting the job with sbatch to process the merged VCF file
sbatch get_data_scores.sh "$input_vcf" "$output_table"

