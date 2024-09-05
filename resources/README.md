# Project resources

This **resources** folder contains essential data for the project, organized into two subfolders: **ref** (for reference genome) and  and **rep_regions**  (for repeated regions file).

## Reference Genome

The reference genome subfolder holds the reference genome files necessary for genomic analysis.

See **ref/README.md** for more information about how files were obtained.

## Repeated Regions

The repeated regions subfolder contains files related to repeated genomic regions. The resulting file (**rep_regions_Scere.bed**) is used at the end of the pipeline to remove identified repeated regions in the *S. cerevisiae* genome from the VCF file. 

It is possible for you tu use another file as long as it is in BED format and have the same name. 

### Obtaining Repeated Regions Files

Two different repeated were used (combined into a unique one) present in the **rep_regions/init_files/** folder: 

- From this paper: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4059241/ (supp data, 100nt folder), the chromosome names were change to match with the reference chromosome names  
- From using RepeatMasker tool on the reference genome (**rep_regions_RM.sh** for the script used and **output_RM** folder for the results)
bed
From the 2 .bed files in **init_file** folder, the following commands were used: 
```
cat repeated_regions_RM.bed repeated_regions_Jubin.bed > combined.bed
sort -k1,1 -k2,2n combined.bed > combined_sorted.bed
bedtools merge -i combined_sorted.bed > ../rep_regions_Scere.bed
rm combined.bed combined_sorted.bed
```
## Note
The commands assume that you have activated the associated conda environment (see main README.md).