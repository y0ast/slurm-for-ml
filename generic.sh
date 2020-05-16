#!/bin/bash

# This is a generic running script. It can run in two configurations:
# Single job mode: pass the python arguments to this script
# Batch job mode: pass a file with first the job tag and second the commands per line

#SBATCH --cpus-per-task=4
#SBATCH --gres=gpu:1

set -e # fail fully on first line failure

echo "Running on $(hostname)"

if [ -z "$SLURM_ARRAY_TASK_ID" ]
then
      # Not in array
      SLURM_JOB="$SLURM_JOB_ID"
      # Just read in what was passed over cmdline
      JOB_CMD="${@}"

      # We can't know job id, so we can't clean up failed jobs
else
      # In array
      SLURM_JOB="${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}"

      # Get the line corresponding to the task id
      JOB=$(sed "${SLURM_ARRAY_TASK_ID}q;d" "$1")

      # Split up the line into the tag, and the cmd
      JOB_ID=$(cut -d ' ' -f 1 <<< "$JOB")
      JOB_CMD=$(cut -d ' ' -f 2- <<< "$JOB")

      # Check if results exists, if so remove log and return
      if [ -f  runs/"$JOB_ID"/*/results.json ]
      then
          echo "Results already done - exiting"
          rm "slurm-$SLURM_JOB.out"
          exit 0
      fi

      # This means job failed and we should remove the folder
      if [ -d  "runs/$JOB_ID" ]
      then
          echo "Folder exists, but was unfinished. Deleting logs..."
          rm -r "runs/$JOB_ID"
      fi
fi

# Set up the environment
./run_locked.sh miniconda3/bin/conda-env update -f minimal_environment.yml
source miniconda3/bin/activate minimal-environment

# Train the model
srun python train_script.py $JOB_CMD

# Move the log file to the job folder
LOG_DIR=$(find "runs/$JOB_ID" -name "slurm_job_$SLURM_JOB" | xargs dirname)
mv slurm-"$SLURM_JOB".out $LOG_DIR
