#!/bin/bash

set -e

if [ -z "$1" ]
then
    echo "Error: no dataset given"
    exit 1
fi

dataset=$1

# Create a fresh file
> ${dataset}_jobs.txt

for learning_rate in 0.01 0.05 0.1
do
    for rep in `seq 1 5`
    do
        #Baseline
        ID=${dataset}/${rep}_${learning_rate}_baseline
        echo  "${ID} train_script.py --output_folder ${ID} --dataset ${dataset} --learning_rate ${learning_rate}" --baseline >> ${dataset}_jobs.txt

        # My method
        ID=${dataset}/${rep}_${learning_rate}_mymethod
        echo  "${ID} train_script.py --output_folder ${ID} --dataset ${dataset} --learning_rate ${learning_rate}" --mymethod >> ${dataset}_jobs.txt
    done
done
