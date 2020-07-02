#!/bin/bash

# This is a generic running script. It can run in two configurations:
# Single job mode: pass the python arguments to this script
# Batch job mode: pass a file with first the job tag and second the commands per line

#SBATCH --cpus-per-task=4
#SBATCH --gres=gpu:1

set -e # fail fully on first line failure

# Customize this line to point to conda installation
path_to_conda="miniconda3"

echo "Running on $(hostname)"

if [ -z "$SLURM_ARRAY_TASK_ID" ]
then
    # Not in Slurm Job Array - running in single mode

    # Just read in what was passed over cmdline
    JOB_CMD="${@}"

    # We can't know job id, so we can't clean up failed jobs
else
    # In array
    SLURM_JOB_ID="${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}"
    
    # Get the line corresponding to the task id
    JOB_CMD=$(sed "${SLURM_ARRAY_TASK_ID}q;d" "$1")
      
    # 
    if [[ $JOB_CMD =~ "--output_folder\s+(\S+)" ]]
    then
        JOB_OUTPUT=${BASH_REMATCH[1]}
    else
        echo "Error: did not find a --output_folder argument"
        exit 1
    fi
      
    # Check if results exists, if so remove slurm log and skip
    if [ -f  "$JOB_OUTPUT/results.json" ]
    then
          echo "Results already done - exiting"
          rm "slurm-${SLURM_JOB_ID}.out"
          exit 0
    fi

    # Check if the output folder exists at all. We should remove the folder in that case.
    if [ -d  "$JOB_OUTPUT" ]
    then
          echo "Folder exists, but was unfinished. Deleting logs..."
          rm -r "$JOB_OUTPUT"
    fi
fi

# Use this line if you need to create the environment first on a machine
# ./run_locked.sh ${path_to_conda}/bin/conda-env update -f environment.yml

# Activate the environment
source ${path_to_conda}/bin/activate example-environment

# Train the model
srun python $JOB_CMD

# Move the log file to the job folder
mv "slurm-${SLURM_JOB_ID}.out" ${JOB_OUTPUT}/
