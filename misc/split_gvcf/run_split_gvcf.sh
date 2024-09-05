#!/bin/bash

# This script splits g.vcf.gz files in a specified input directory into multiple files in a predefined output directory
# Usage: ./split_gvcf_batch.sh /path/to/input_dir

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <input_dir>"
  exit 1
fi

# Input directory containing the g.vcf.gz files (not split)
input_dir="$1"

# Predefined output directory for split files
output_dir="../../results/split_gvcf"

# Check if the input directory exists
if [ ! -d "$input_dir" ]; then
  echo "Error: Input directory '$input_dir' does not exist."
  exit 1
fi

# Check if the output directory exists, create it if it doesn't
if [ ! -d "$output_dir" ]; then
  mkdir -p "$output_dir"
  if [ $? -ne 0 ]; then
    echo "Error: Failed to create output directory '$output_dir'."
    exit 1
  fi
fi

# Loop through each g.vcf.gz file in the input directory
for file in "$input_dir"/*.g.vcf.gz; do
  # Check if there are any g.vcf.gz files
  if [ -e "$file" ]; then
    echo "Processing file: $file"

    # Run the sbatch command to split each file
    sbatch split_single_gvcf.sh "$file" "$output_dir"
    
  else
    echo "No g.vcf.gz files found in '$input_dir'."
    exit 1
  fi
done

echo "All g.vcf.gz files have been processed."
