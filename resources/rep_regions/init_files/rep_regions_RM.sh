#!/bin/bash

## Université Paris-Saclay
## Lab : LISN ~ UMR9015 ~ BIOINFO team

ref_genome="../ref/S288C_reference_sequence_R64-4-1_20230830.fasta"

RepeatMasker -species "Saccharomyces cerevisiae" -engine rmblast -dir ./output $ref_genome
# rmblast (modif of NCBI BLAST): faster, same accuracy as Crossmatch, actively maintenaned by NCBI

# Convert .out to bed format for further usage
awk 'BEGIN {OFS="\t"} !/^#/ && NR > 3 {print $5, $6-1, $7}' output/S288C_reference_sequence_R64-4-1_20230830.fasta.out > ../repeated_regions_RM.bed

# OFS="\t" sets the output field separator to a tab.
# !/^#/ && NR > 3 skips the header lines in the .out file.
# print $5, $6-1, $7, $10, $11, $9 extracts and formats the relevant columns from the .out file to .BED format:
# Column 1: Chromosome or scaffold name.
# Column 2: Start position (converted to 0-based).
# Column 3: End position.
# Column 4: Name of the repeat element.
# Column 5: Score or percent divergence.