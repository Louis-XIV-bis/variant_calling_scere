#!/bin/bash

# List of contigs: you can change these IDs based on your species or data
contigs=("001133" "001134" "001135" "001136" "001137" "001138" "001139" "001140"
            "001141" "001142" "001143" "001144" "001145" "001146" "001147" "001148" "001224")

# Output file
output_file="table_scores_merged.tsv"

# Initialize a flag to track the header
header_written=false

# Loop through the contig IDs and merge the corresponding files
for contig in "${contigs[@]}"; do
    file="table_scores_${contig}.tsv"
    
    if [[ -f "$file" ]]; then
        if [[ "$header_written" = false ]]; then
            # Write the header and content of the first file
            cat "$file" > "$output_file"
            header_written=true
        else
            # Skip the header and append the rest of the file content
            tail -n +2 "$file" >> "$output_file"
        fi
    else
        echo "File $file not found!"
    fi
done