#!/bin/bash

# Expects to be in the same folder as generic.sh

# Edit this if you want more or fewer jobs in parallel
jobs_in_parallel=8

if [ ! -f "$1" ]
then
    echo "Error: file passed does not exist"
    exit 1
fi

# This convoluted way of counting also works if a final EOL character is missing
n_lines=$(grep -c '^' "$1")

# Use file name for job name
job_name=$(basename "$1" .txt)

sbatch --array=1-${n_lines}%${jobs_in_parallel} --job-name ${job_name} $(dirname "$0")/generic.sh "$1"
