#!/bin/bash

set -e

if [ -z "$1" ]
then
    echo "Error: no dataset given"
    exit 1
fi

dataset=$1
script="train_script.py"

# Create a fresh file
> ${dataset}_jobs.txt

for rep in `seq 1 5`
do
    for learning_rate in 0.01 0.05 0.1
    do
        #Baseline
        output_folder=${dataset}/${rep}_${learning_rate}_baseline
        echo  "${script} --output_folder ${output_folder} --dataset ${dataset} --learning_rate ${learning_rate} --method baseline" >> ${dataset}_jobs.txt

        # My method
        output_folder=${dataset}/${rep}_${learning_rate}_mymethod
        echo  "${script} --output_folder ${output_folder} --dataset ${dataset} --learning_rate ${learning_rate} --method mymethod" >> ${dataset}_jobs.txt
    done
done
