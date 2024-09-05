Snakemake variant calling pipeline for HPC
======================

## Description

This project is an analysis pipeline using [Snakemake](https://snakemake.readthedocs.io/en/stable/) for variant calling (initially for yeasts).
This pipeline  specificity is to **merge same strains coming from the same paper into one individual**. Therefore, it may not apply to some species (such as humans). 

The pipeline was developped for [SLURM](https://slurm.schedmd.com/documentation.html) based HPC cluster but can be run on any cluster infrastructure (or locally) if the parameters are changed accordingly.

The main steps of the pipeline are:
- downloading the fastq files from [ENA](https://www.ebi.ac.uk/ena/browser/home)
- alignment of reads on reference genome with [bwa](http://bio-bwa.sourceforge.net/)
- merging the same strains from a given paper with [samtools merge](https://www.htslib.org/doc/samtools-merge.html)
- marking of duplicates with [gatk MarkDuplicatesSpark](https://gatk.broadinstitute.org/hc/en-us/articles/360037224932-MarkDuplicatesSpark)
- variant calling with [gatk HaplotypeCaller](https://gatk.broadinstitute.org/hc/en-us/articles/360037225632-HaplotypeCaller)
- merging per strain gVCF to population gVCF with [gatk CombineGVCFs](https://gatk.broadinstitute.org/hc/en-us/articles/360037053272-CombineGVCFs)
- converting gVCF to VCF with [gatk GenotypeGVCFs](https://gatk.broadinstitute.org/hc/en-us/articles/360037057852-GenotypeGVCFs)
- removing repeated regions with [gatk VariantFiltration](https://gatk.broadinstitute.org/hc/en-us/articles/360037434691-VariantFiltration) and [vcftools](https://vcftools.github.io/index.html).

The pipeline is separated in two pipelines: the first it for downloading the fastq and do the process to get the individual gVCFs, the second is to merge the individual gVCFs to obtain a filtered VCF. Both can (and have to) be run independantly. 

The pipelines work with a list of **ENA IDs** as input, for which you can get read files (*e.g.* https://www.ebi.ac.uk/ena/browser/view/PRJEB13017). Both part of the pipeline take a list of ENA ID, that can be different, for instance if you want to get the gVCFs from a given ID but you already have all other gVCFs you want to merge them with. More details below. 

Here is a representation of the pipeline:    
  
![Logo](/misc/plot_readme/DAG_pipeline.png)

It is possible (described below) to run the second pipeline for individual chromosome of every individual. After splitting the gVCFs from the first pipeline into per-chromosome gVCF, the **merge_gvcf**, **gvcf_to_vcf, **filter_vcf** and "remove_rep_regions** will be run in parallel for each chromosome (technical details below). You'll end up with as many VCF as you have chrosomomes in your species. It'll be up to you to merge these VCF into a single one if needed.  
  
## System requirements

The only requirement is to be on a SLURM HPC cluster (recommended, but local running is possible, commands are also given for that case) and have a working install of [conda](https://www.anaconda.com/download/#linux) and [git](https://git-scm.com/downloads).
All tools necessary to run the pipeline are described in a conda environment file.  

The species specific resources files have to be downloaded manually if not *S. cerevisiae*. 

## Usage 
### Initialization
These commands have to be run only once to setup the pipeline.

#### Cloning the git repository
```
git clone "https://github.com/Louis-XIV-bis/varcall_snakemake"
cd variant-calling-pipeline
```

#### Create the appropriate environment using the conda export file provided
```
conda env create -f workflow/envs/environment.yaml -n your_env_name
```

#### If SLURM : create your profile 

In order to run the pipeline on SLURM cluster, you need to create a "profile" file contains information about the resources and other snakemake commands. The profile should be in the folllowing folder: $HOME/.config/snakemake/name_of_profile. You can name the profile the way you want but will need to use that name to run the pipeline. More information [here](https://snakemake.readthedocs.io/en/stable/executing/cli.html#profiles).  

Now, if you need to run the pipeline on a SLURM based cluster (recommended) or on a local computer, follow the according section.

The file used already exist in the **/workflow/profile/** directory. 


```
mkdir $HOME/.config/snakemake/name_of_profile
cp workflow/profile/config_slurm.yaml $HOME/.config/snakemake/name_of_profile/config.yaml
```

You can change the profile file according to your preferences. 


### Running the pipeline

In order to run the pipeline, you need to give some ENA IDs in the **config/config.yaml** file:   
- If you want to get gVCFs from a given list of ID, add them to **ENA_ID_get_gvcf** in the config file. If you already have the gVCFs from the ENA ID, remove it from the config file otherwise it will be generated again.  
- If you want to merge the gVCFs from a given list of ENA ID (can be different from the first part, **as long as you have all the gVCFs for each ID**), add them to **ENA_ID_merge_gvcf** in the config file. 


Each time you add a new ENA ID to the config file, you'll to run the next two commands in order (python -> snakemake).

Before running any command, make sure to have your conda environment activated, you can use: 
```
conda activate your_env_name 
```

#### Generate intermediate files for the pipeline

For the first part of the pipeline, this command will download the metadata for each ENA ID in the **ENA_ID_get_gvcf** config.  
Note: the tables will be removed if you run again the pipeline (in order to avoid conflict) but you can find them in the **results/tables_get_gvcf** folder as long as you didn't run it again.

```
python generate_tables.py get_gvcf
```

For the second part of the pipeline, this command will also download the metadata for each ENA ID in the **ENA_ID_merge_gvcf** config.  
Note: the tables will be removed if you run again the pipeline (in order to avoid conflict) but you can find them in the **results/tables_merge_gvcf** folder as long as you didn't run it again.


```
python generate_tables.py merge_gvcf
```

#### Run the pipeline

The pipeline is made in a way to prioritize the jobs strain by strain. Then, for new ENA ID, it will run multiple strains in parallel for this new ID. That way, it prevents from keep in storage too much intermediate files (BAM, SAM, etc). Only final gVCF for each strain is kept for the first part. For the second part, only VCF are kept (filtered, unfiltered, etc) and the input gVCFs. You will get the output in the **results/** folders.


Follow the correct section if you want to run the pipeline on a SLURM HPC cluster (recommended) or on a local computer.   

The process will run in the background using **nohup** and **&**. You can see the progress in the **nohup.out** generated file.

**IMPORTANT**: If you think you computational resources won't be sufficient for the computation of the VCF, we implemented a possibility to split your gVCF by chrososome and then run the second part of the pipeline per chromosome. In order to split your gVCF into chromosome, you need to use the scripts in the **mist/split_gvcf** folder. First: update the **split_single_gvcf.sh** file with your chromosome names and then run (for SLURM): 
```
./run_split_gvcf.sh ../../results/gvcf/
``` 

It will creates a **split_gvcf** folder in the **results** folder with all the chromosome gVCF for ceach individuals. 

##### SLURM HPC cluster 

To run the first part of the pipeline: 
```
nohup snakemake -s workflow/Snakefile_get_gvcf --profile name_of_profile &
```
To second the first part of the pipeline: 
```
nohup snakemake -s workflow/Snakefile_merge_gvcf --profile name_of_profile &
```

If you used the per-chromosome method change **Snakefile_merge_gvcf** to **Snakefile_merge_splitgvcf**

##### Local computer

To run the first part of the pipeline: 
```
nohup snakemake -s workflow/Snakefile_get_gvcf --resources mem_mb=64000 --cores 8 &
```

To second the first part of the pipeline (resources to changes according to what's possible for you and the requierments of your data): 
```
nohup snakemake -s workflow/Snakefile_merge_gvcf --resources mem_mb=64000 --cores 8 &
```

If you used the per-chromosome method change **Snakefile_merge_gvcf** to **Snakefile_merge_splitgvcf**


Note: you can change the values for the RAM ad the number of core. You can also create a profile to specify more resources but you'd need to change the script for each rule.

