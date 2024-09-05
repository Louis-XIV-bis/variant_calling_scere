import os 
import requests
from typing import List
import pandas as pd

def dl_tsv_ENA(list_ENA: List[str], results_dir: str) -> None:
    """
    Downloads TSV data from the European Nucleotide Archive (ENA) for a list of ENA IDs.

    Parameters:
        - list_ENA (List[str]): A list of ENA IDs for which TSV data needs to be downloaded.
        - results_dir (str): Path where the downloaded TSV files will be saved.

    Raises:
        - Exception: If there is an error saving the TSV file.
    
    Returns:
        - None
    """

    # Check if the output directory exists, if not, create it
    if not os.path.exists(results_dir):
        os.makedirs(results_dir)

    for ENA_id in list_ENA:

        url = f'https://www.ebi.ac.uk/ena/portal/api/filereport?accession={ENA_id}&result=read_run&fields=study_accession,run_accession,tax_id,scientific_name,instrument_platform,study_title,fastq_md5,fastq_ftp,sample_alias,sample_title&format=tsv&download=true&limit=0'
        response = requests.get(url)
        
        # Check if the request was successful (status code 200)
        if response.status_code == 200:
            output = results_dir + ENA_id + '.tsv'
            
            try:
                with open(output, 'wb') as file:
                    file.write(response.content)
            except Exception as e:
                print(f'Error saving TSV for ENA ID {ENA_id}: {e}')
        else:
            print(f'Failed to download TSV for ENA ID {ENA_id}. Status code: {response.status_code}')
            

def merge_tsv_files(results_dir: str, output_file: str) -> None:
    """
    Merge multiple TSV files from the specified directory into a single TSV file
    and saves it in the given directory. 

    Parameters:
        - results_dir (str): Path to the directory containing TSV files.
        - output_file (str): Name of the output merged TSV file.
    
    Raises:
        - FileNotFoundError: If the specified input directory does not exist.

    Returns:
        - None
    """
    
    # Check if the input directory exists
    try:
        tsv_files = [file for file in os.listdir(results_dir) if file.endswith('.tsv')]
    except FileNotFoundError:
        print(f'The specified directory {results_dir} does not exist.')
        return
    
    if not tsv_files:
        print('No TSV files found in the specified directory.')
        return
    
    # Initialize an empty DataFrame to store merged data
    merged_data = pd.DataFrame()

    # Iterate through each TSV file, read it, and concatenate to the merged DataFrame
    for file in tsv_files:
        file_path = os.path.join(results_dir, file)
        df = pd.read_csv(file_path, sep='\t', encoding='utf-8')
        merged_data = pd.concat([merged_data, df], ignore_index=True)
        os.remove(file_path)
        
    # Check for duplicate column names
    duplicates = merged_data.columns[merged_data.columns.duplicated()]
    if duplicates.any():
        print(f"Warning: Duplicate column names found: {', '.join(duplicates)}.")

    output_path = results_dir + output_file
    merged_data.to_csv(output_path, sep='\t', mode='w', index=False)
    
def process_table(results_dir, input_file: str, output_file: str, tax_id: int) -> pd.DataFrame:
    """
    Process a table, filter rows based on specified conditions, and save the result to a new CSV file.

    Parameters:
        - results_dir (str): Path to the directory containing TSV files.
        - input_file (str): Name of the input table file.
        - output_file (str): Name to save the processed table as a CSV file.
        - tax_id (int): Taxonomy ID to filter rows based on the 'tax_id' column.

    Raises:
        - FileNotFoundError: If the specified input file is not found.

    Returns:
        - df (pd.Dataframe): Resulting dataframe to use.
        
    """
    input_path = results_dir + input_file
    output_path = results_dir + output_file

    try:
        df = pd.read_csv(input_path, sep='\t', encoding='utf-8')
    except FileNotFoundError:
        print(f'Input file {input_file} not found.')
        return
    
    # Remove rows with empty 'fastq_ftp' column (== no link to download fastq)
    # or if 'sample_alias' AND 'sample_title' are empty
    df.dropna(subset=['fastq_ftp'], inplace=True)
    df.dropna(subset=['sample_alias', 'sample_title'], how='all', inplace=True)

    # Remove rows with "tax_id" column not equal to S.cere tax id
    df = df[df['tax_id'] == tax_id]
    
    # Remove the commas and space that will cause issues when saving to csv
    df.replace(to_replace=',', value='-', regex=True, inplace=True)
    df.replace(to_replace=' ', value='_', regex=True, inplace=True)
    df.replace(to_replace=':', value='_', regex=True, inplace=True)

    # Add a new column to tell if the reads are paired or single ends by counting
    # the number of fastq ftp links. Sometimes there are 3 files (single + paired),
    # it needs some processing and we use only the paired end in this case. 
    df['num_items'] = df['fastq_ftp'].apply(lambda x: len(str(x).split(';')))
    df['end'] = df['num_items'].apply(lambda x: 'PAIRED' if x == 2 else 'SINGLE' if x == 1 else None)
    df.drop('num_items', axis=1, inplace=True)

    # Processing troublesome ID for which we do not have paired not single ends but both
    for index, row in df.iterrows():
        if pd.isnull(row['end']):

            # Create a new column with removed fastq ftp for single end and matching md5
            ftp_values = row['fastq_ftp'].split(';')
            md5_values = row['fastq_md5'].split(';')
            
            new_ftp_values = []
            new_md5_values = []
            
            for i, ftp_value in enumerate(ftp_values):
                # Check if the value ends with '_1.fastq.gz' or '_2.fastq.gz' : keep it
                if ftp_value.endswith(('_1.fastq.gz', '_2.fastq.gz')):
                    new_ftp_values.append(ftp_value)
                    new_md5_values.append(md5_values[i])
                else:   
                    continue

            # Update the row with modified values
            df.at[index, 'fastq_ftp'] = ';'.join(new_ftp_values)
            df.at[index, 'fastq_md5'] = ';'.join(new_md5_values)

            # Update 'end' column to 'PAIRED' if it's currently 'None'
            if pd.isnull(row['end']):
                df.at[index, 'end'] = 'PAIRED'

    # Add 'ENA_strain_id' column by sample_alias first and sample_title else 
    # (at least one of them because empty rows for both were removed)
    if 'sample_alias' in df.columns:
        df['ENA_strain_id'] = df['study_accession'] + '_' + df['sample_alias'].str.replace('_', '-')
    else:
        df['ENA_strain_id'] = df['study_accession'] + '_' + df['sample_title'].str.replace('_', '-')

    df.insert(0, 'ENA_strain_id', df.pop('ENA_strain_id'))

    # Save to csv (instead of tsv)
    df.to_csv(output_path, sep=',', mode='w', index=False)
    os.remove(input_path)
    
    return df

def split_and_save_csv(results_dir: str, input_file: str) -> List[str]:
    """
    Reads a CSV file, splits it based on unique values in the 'ENA_strain_id' column,
    and saves each split DataFrame as a separate CSV file in the specified output directory.

    Parameters:
        - results_dir (str): The directory where the split CSV files will be saved.
        - input_file (str): Name of the input CSV file.

    Raises:
        - FileNotFoundError: If the specified input file is not found.
        
    Returns:
        - ENA_strain_list (List[str]): A list of unique values in the 'ENA_strain_id' column.
                                     Returns an empty list if the input file is not found.
    """
    
    input_path = results_dir + input_file

    try:
        df = pd.read_csv(input_path, encoding='utf-8')
    except FileNotFoundError:
        print(f"Input file '{input_path}' not found.")
        return
    
    # Create the output folder if it doesn't exist
    os.makedirs(results_dir, exist_ok=True)

    # Get unique values in the 'ENA' column
    ENA_strain_list = df['ENA_strain_id'].unique()

    # Split the DataFrame based on the 'ENA' column
    split_dfs = {value: group for value, group in df.groupby('ENA_strain_id')}

    # Save each split DataFrame to a CSV file
    for value, split_df in split_dfs.items():
        csv_filename = os.path.join(results_dir, f'{value}.csv')
        split_df.to_csv(csv_filename, mode='w', index=False)

    # Return the list of unique values
    return ENA_strain_list