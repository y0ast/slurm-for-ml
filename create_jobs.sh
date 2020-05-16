#!/bin/bash

set -e

if [ -z "$1" ]
then
    echo "Error: no dataset given"
    exit 1
fi

dataset=$1

job_file=${dataset}_jobs.txt
result_dir=${dataset}

for learning_rate in 0.01 0.05 0.1
do
    for rep in `seq 1 5`
    do
        #Baseline
        ID=${result_dir}/${rep}_${learning_rate}_baseline
        echo  "${ID} --output_folder ${ID} --dataset ${dataset} --learning_rate ${learning_rate}" --baseline >> ${job_file}

        # My method
        ID=${result_dir}/${rep}_${learning_rate}_mymethod
        echo  "${ID} --output_folder ${ID} --dataset ${dataset} --learning_rate ${learning_rate}" --mymethod >> ${job_file}
    done
done
