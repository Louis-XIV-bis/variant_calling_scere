#!/bin/bash

# Input gVCF file and output directory from arguments
input_gvcf="$1"
output_dir="$2"

# List of contigs based on your provided data : TO ADAPT
contigs=("ref|NC_001133|" "ref|NC_001134|" "ref|NC_001135|" "ref|NC_001136|"
         "ref|NC_001137|" "ref|NC_001138|" "ref|NC_001139|" "ref|NC_001140|"
         "ref|NC_001141|" "ref|NC_001142|" "ref|NC_001143|" "ref|NC_001144|"
         "ref|NC_001145|" "ref|NC_001146|" "ref|NC_001147|" "ref|NC_001148|"
         "ref|NC_001224|")

# Get the base name of the file (without the .gz extension)
base_name=$(basename "$input_gvcf" .gz)

# Unzip the file
gunzip -c "$input_gvcf" > "$base_name"

# Extract header lines and save to a temporary file (the strain name change between headers)
grep '^##' "$base_name" > header_$base_name.txt
grep '^#CHROM' "$base_name" >> header_$base_name.txt

# Split the input gVCF by contig
for contig in "${contigs[@]}"; do
  output_gvcf="${output_dir}/${base_name%.g.vcf}_${contig//|/}.g.vcf"
  
  # Write header to the new gVCF file
  cat header_$base_name.txt > "$output_gvcf"
  
  # Extract lines for the specific contig and append to the file
  awk -v contig="$contig" '$1 == contig' "$base_name" >> "$output_gvcf"
  
  # Compress the output file
  bgzip "$output_gvcf"

  # Remove "refNC_" from the file name : TO ADAPT 
  new_output_gvcf="${output_gvcf//refNC_/}"
  mv "${output_gvcf}.gz" "${new_output_gvcf}.gz"

  # Create an index file used by the other tools
  gatk IndexFeatureFile -I "${new_output_gvcf}.gz"
  
done

# Clean up temporary files
rm "$base_name"
rm header_$base_name.txt