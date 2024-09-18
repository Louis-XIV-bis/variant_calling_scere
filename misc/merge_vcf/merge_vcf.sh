#!/bin/bash

#SBATCH --job-name=merge_vcf
#SBATCH --mem=1000G
#SBATCH --cpus-per-task=8

# Activate your conda env
conda activate your_env

# Upload your own list of VCF if it's not the same 
input_vcfs="vcf_list.list"
output_vcf="../../results/vcf/filtered_repremoved_yeast_strains.vcf.gz"

# Fuse the input VCF (same samples but different chromosomes so we use concat)
xargs bcftools concat -o $output_vcf -O z < $input_vcfs

# Index the final vcf
tabix -p vcf $output_vcf

