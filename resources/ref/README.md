# Genome Reference Setup Script
This script is designed to automate the setup process for a yeast genome reference (**R64-4-1_20230830R64-4-1_20230830**). It downloads the reference genome, extracts the necessary files, and prepares them for use in genomic analysis tools such as GATK, samtools, picard, and bwa.

## Usage
Set up the paths: modify the **ref_dir** variable in the script to point to the directory where you want to store the reference files: **ref_dir='/path/to/your/directory/resources'** (must be the **resources** directory for further usage in the pipeline).

If you want to change the reference genome, upate the **ref_name** variable and the **url** if needed.

Run the script in the preprocess directory: 
```
./setup_reference.sh
```

This will download the reference genome, extract the necessary files, convert the file format to .fasta, and create indexes and dictionaries for faster usage with genomic analysis tools.

## Notes
The script assumes that you have activated the associated conda environment (see main README.md). 

The reference genome is downloaded from SGD (Saccharomyces Genome Database).

The final reference files include a .fasta file (S288C_reference_sequence_R64-4-1_20230830.fasta), a .dict file (S288C_reference_sequence_R64-4-1_20230830.dict), and indexed files for use with bwa.
