# Author: Louis OLLIVIER (louis.xiv.bis@gmail.com)
# Date : February 2023 

import numpy as np
import yaml, json
import sys, os

sys.path.append("workflow/scripts/")
from functions import *

def main(method):
    
    # Read the config file
    with open("config/config.yaml", "r") as f:
        config = yaml.safe_load(f)
    
    # Define the list of ID and the result path according to the method passed in 
    # command-line (get or merge_gvcf)
    valid_options = ["get_gvcf", "merge_gvcf"]
    
    # Check if the argument is valid
    if method in valid_options:
        if method == "get_gvcf":
            ENA = config["ENA_ID_get_gvcf"]  # list of ENA IDs
            results_dir = "./results/tables_get_gvcf/"

        elif method == "merge_gvcf":
            ENA = config["ENA_ID_merge_gvcf"]  # list of ENA IDs
            results_dir = "./results/tables_merge_gvcf/"
    else: 
        raise ValueError("Invalid argument. Please provide 'get_gvcf' or 'merge_gvcf'.")

    tax_id = config["tax_id"]  # taxon id is specific for each species

    ############# Downloading, merging and filtering the information files #############
    # Download all the tsv files from the ENA IDs. They contain all the information
    # requiered for the rest of the pipeline (sample ID, ftp link to dl fastq, etc).
    # After that, it's merged into one unique file and filtered / processed (e.g. keep
    # only S.cere sequences). Then, a csv table is created for each ENA_strain ID from the table.

    # Check if the output directory exists, if not, create it otherwise 
    # remove the existing file to avoid conflict    
    if not os.path.exists(results_dir):
        os.makedirs(results_dir)
    else: 
        for file in os.listdir(results_dir):
            file_path = os.path.join(results_dir, file)
            if os.path.isfile(file_path):
                os.remove(file_path)
                
    # Download, merge and process the tables into one unique table 
    dl_tsv_ENA(ENA, results_dir)
    merge_tsv_files(results_dir, "merged_table.tsv.ok")
    process_table(results_dir, "merged_table.tsv.ok", "merged_filtered_table.csv", tax_id)

    # Split the table to reate the files for each ENA_strain and the associated list to use for the pipeline
    ENA_strain_list = split_and_save_csv(results_dir, "merged_filtered_table.csv", )

    # Save the ENA_strain list to a file (will be the names of the resulting files)
    ENA_strain_path = results_dir + "ENA_strain_list.json"
    with open(ENA_strain_path, 'w') as file:
        ENA_strain_list = ENA_strain_list.tolist()
        json.dump(ENA_strain_list, file)

if __name__ == "__main__":
    # Check if an argument is provided
    if len(sys.argv) < 2:
        print("Usage: python script.py get_gvcf/merge_gvcf")
    else:
        main(sys.argv[1])