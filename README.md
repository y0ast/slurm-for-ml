# Slurm for Machine Learners

Many labs have converged on using [Slurm](https://slurm.schedmd.com/documentation.html) for managing their shared compute resources.
It is fairly easy to get going with Slurm, but it quickly gets unintuitive when wanting to run a hyper-parameter search.
In this repo, I provide some scripts to make starting many jobs painless and without filling up the entire cluster.

## Starting a single job

This is easy, but it's here for completeness:

```
sbatch generic.sh --dataset CIFAR10 --learning-rate 1e-4
```

You simply pass the parameters you want to pass to `train_script.py` to `generic.sh` and it'll start the job for you with the appropriate resources and environment set up.

## Starting many jobs

This is more tricky. Generally you have an idea for what ranges to run, but later perhaps want to add more (for example 5 runs per configuration, instead of 3).
Also some jobs might fail for all sorts of reasons.
Lastly, you don't want to use up all available GPUs as your lab mates will quickly get frustrated with being in the queue.
We will use a two step process

### Step 1:

```
./create_table1_jobs.sh
```

will create a job list, with all the jobs we want to run.
The format for the job list is `<job identifier> <command line flags>`.
The assumption is that the results will end up in a folder called `runs/<job identifier>/` and that successful jobs have a `results.json` in that folder.
If we later want to add jobs, we can simply update this script, generate new jobs and the job runner will check if a job was done already!
It'll be skipped if so and you won't need to manually check anything.

### Step 2:

```
./run_file.sh job_list.txt
```

This will start 8 jobs in parallel (using [job arrays](https://slurm.schedmd.com/job_array.html)).
You can easily change the number by editing the top of the `run_file.sh`.
It'll check (in `generic.sh`) if a particular job is done already and if it finished correctly.
The job will be skipped if it was done, logs will be removed if it was crashed, and it will simply be started if nothing was found.

## Setup requirements summarised

1. `conda` - by default in the folder `miniconda3` along side these scripts. Change the paths in `generic.sh` to match your setup.
2. Within Python, save your final results to a file called `results.json` so the script can check if that happened. You can also edit this check for your particular setup (e.g. check for a final model saved).
3. Save your results in the `runs/<job identifier>` folder. A suggested job identifier is `table1/lr0.05_bs128`, so it will save all your results in a subfolder called `table1`.


Note: `run_locked.sh` is necessary because `conda` is not thread safe by itself, and calling update multiple times in different processes leads to incorrect behaviour.

Happy Slurming!
