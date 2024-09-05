#!/bin/bash

# Setup paths
ref_dir='/home/lollivier/Documents/pipeline/resources/ref' # your path
cd $ref_dir

ref_name='R64-4-1_20230830'

ref_g="S288C_reference_genome_${ref_name}" 
ref_s="S288C_reference_sequence_${ref_name}"

# Download the reference genome (extract the .fsa file from the two archives)
wget http://sgd-archive.yeastgenome.org/sequence/S288C_reference/genome_releases/$ref_g.tgz
tar -xzf $ref_g.tgz -C .
rm $ref_g.tgz

cp $ref_g/$ref_s.fsa.gz .
rm -r $ref_g

gunzip $ref_s.fsa.gz

# Convert .fsa to .fasta (GATK needs this extension specifically)
mv $ref_s.fsa $ref_s.fasta

# Index & create a dict of the reference genome for faster usage later
samtools faidx $ref_s.fasta 
picard CreateSequenceDictionary -R $ref_s.fasta -O $ref_s.dict
bwa index -a bwtsw $ref_s.fasta
