#!/bin/bash

set -e

if [ -z "$1" ]
then
    echo "Error: no dataset given"
    exit 1
fi

dataset=$1

job_file=${dataset}_table1_jobs.txt
sub_dir=${dataset}_table1

for learning_rate in 0.01 0.05 0.1
do
    for rep in `seq 1 5`
    do
        #Baseline
        ID=${sub_dir}/${rep}_${learning_rate}_baseline
        echo  "${ID} --subdir ${ID} --dataset ${dataset} --learning_rate ${learning_rate}" --baseline >> ${job_file}

        # My method
        ID=${sub_dir}/${rep}_${learning_rate}_mymethod
        echo  "${ID} --subdir ${ID} --dataset ${dataset} --learning_rate ${learning_rate}" --mymethod >> ${job_file}
    done
done
