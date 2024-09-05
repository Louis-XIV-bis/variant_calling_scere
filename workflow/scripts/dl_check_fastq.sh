#!/bin/bash

# Bash Script: download_with_md5_check.sh
#
# Description:
# This script downloads a file from a specified URL using wget and checks the integrity
# of the downloaded file by comparing its MD5 sum with an expected MD5 sum.
# If the MD5 sums match, the script prints a success message. If there is a mismatch,
# it removes the incomplete or corrupted file and restarts the download until a
# successful download is achieved.

# Usage:
# ./download_with_md5_check.sh <output_file> <url> <expected_md5>

# Parameters:
#   <output_file>: The path to the file where the downloaded content will be saved.
#   <url>:         The URL from which to download the file.
#   <expected_md5>: The expected MD5 sum of the downloaded file for integrity check.

# Assign command-line arguments to variables
output_file=$1
url=$2
expected_md5=$3

# Infinite loop to repeatedly attempt the download until successful
while true; do

    # Download the file using wget
    wget -O "$output_file" "$url"

    # Calculate the MD5 sum of the downloaded file
    actual_md5=$(md5sum "$output_file" | awk '{print $1}')

    # Compare the actual and expected MD5 sums
    if [ "$actual_md5" == "$expected_md5" ]; then
        echo "Download successful. MD5 matches."
        break  # Exit the loop if MD5 sums match
    else
        echo "MD5 mismatch. Restarting download..."
        rm -f "$output_file"  # Remove the incomplete/corrupted file
    fi
done
