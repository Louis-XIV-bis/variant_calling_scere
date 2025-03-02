#!/bin/bash

#SBATCH --job-name=get_data_scores
#SBATCH --mem=300G 

# This script extracts specific fields from a VCF file and outputs them to a CSV file.
# It is intended to be run on a compute cluster using the SLURM job scheduler.

# Activate your conda environment
# conda activate your_env 

module load bcftools 

# Input arguments
input_vcf=$1  
output_table=$2

# Check that the input VCF file exists
if [ ! -f "$input_vcf" ]; then
  echo "Error: Input VCF file '$input_vcf' does not exist."
  exit 1
fi

# Initialize the output TSV file with header
echo -e "CHROM\tPOS\tQUAL\tDP\tQD\tFS\tMQ\tMQRankSum\tReadPosRankSum\tSOR\tBaseQRankSum" > $output_table

# Extract the required fields from the VCF file and append them to the output TSV file
# The 'bcftools query' command is used for this purpose
bcftools query -f '%CHROM\t%POS\t%QUAL\t%DP\t%QD\t%FS\t%MQ\t%MQRankSum\t%ReadPosRankSum\t%SOR\t%BaseQRankSum\n' "$input_vcf" >> $output_table
