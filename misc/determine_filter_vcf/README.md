# How we got the results for the filtering

First, run the **run_get_data_scores.sh** to retrieve the scores from the unfiltered vcf. Be careful, it's specific for SLURM jobs (sbatch, memory, etc).  

To run the script, you have two options **merged** (if you have one vcf) or **split** (if you have one vcf per chromosome).  

```
./run_get_data_scores

```
 
The final tsv (**table_scores_merged.tsv**) will contain all the score for each sites.  

For the plot, run the **plot/score_global.R** script. It will generate the plot with distribution for each scores with our defined threshold and a Venn diagram.  

You can see the distribution of the segregating sites score for our vcf, we added our defined threshold and the proportion of sites that pass the filters.  

We mostly used the same threshold as proposed by GATK (something more strict) and ended up with filtrering around 10% of the sites. 
 