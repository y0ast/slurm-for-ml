# Slurm for Machine Learners

Many labs have converged on using [Slurm](https://slurm.schedmd.com/documentation.html) for managing their shared compute resources.
It is fairly easy to get going with Slurm, but it quickly gets unintuitive when wanting to run a hyper-parameter search.
In this repo, I provide some scripts to make starting many jobs painless and easy to control.

## Starting a single job

This is easy, but it's here for completeness:

```
sbatch generic.sh train_script.py --dataset CIFAR10 --learning-rate 1e-4
```

You simply pass the arguments you normally pass to `python` to [generic.sh](generic.sh) and it'll start the job for you on Slurm with a gpu and a `conda` environment set up.

## Starting many jobs

For this use case, Slurm has introduced [Job Arrays](https://slurm.schedmd.com/job_array.html).
Slurm assigns separate jobs a simple job array id, which is an integer that starts counting from 1.
This does not map well onto the usual machine learning jobs that requires running over a grid of hyperparameters.
For this use case, I present an easy to use workflow.
We assume you have an idea of what ranges (e.g. learning rates 0.01 and 0.05) to run, and later perhaps want to add more (for example 5 repetitions per configuration).
Also we have to live with the fact that some jobs might fail for all sorts of reasons (GPU fails, somebody accidentally unplugged the server, etc).
Lastly, you don't want to use up all available GPUs as your lab mates will quickly get frustrated with being in the queue.

The core idea of this approach is to use the Slurm job array id to index **lines** in a file!
No complicated grid indexing just a long list of jobs, and use the Slurm scheduler to chew through them.

### Step 1:

```
./create_jobs.sh
```

will create a job list, with all the jobs we want to run.
The format for the job list is `<job identifier> <command line flags>`.
The assumption is that the results will end up in a folder called `<job identifier>/` (might be a nested folder!) and that successful jobs have a `results.json` in that folder.
If we later want to add jobs, we can simply update this script, generate new jobs and the job runner will check if a job was done already!
It'll be skipped if so and you won't need to do any manual checking.

### Step 2:

```
./run_file.sh job_list.txt
```

This will start 8 jobs in parallel using Slurm job arrays.
You can easily change the number of jobs run in parallel by editing the top of the `run_file.sh`.
It'll check (in `generic.sh`) if a particular job is done already and if it finished correctly, it'll be skipped if that's the case.
Otherwise the job will be started and when it's done Slurm will move to the next line in the job list.

## Setup requirements summarised

1. `conda` - by default in the folder `miniconda3` along side these scripts. Change the paths in [generic.sh](generic.sh) to match your setup.
2. Within Python, save your final results to a file called `results.json` so the script can check if the jobs was successful. You can also edit this check for your particular setup (e.g. check for a final model saved).
3. Save your results in the `<job identifier>` folder. A suggested job identifier is `<dataset>/lr0.05_bs128`, so it will save all your results in a subfolder called named after your dataset.

Note: [run\_locked.sh](run_locked.sh) is necessary because `conda` is not thread safe by itself, and calling update multiple times in different processes leads to incorrect behaviour.
This is only necessary if you have a shared `conda` installation, if instead you use a single environment and mount the same folder on each machine in the cluster then you can simply create the environment once.

I have attempted to comment [generic.sh](generic.sh) as much as possible, so it's easy to see what to change for your Slurm setup!

Happy Slurming!

Let me know if you have any issues with the scripts, or if you see room for improvement. I am happy to accept PRs.

### Useful Commands

Count all GPUs available in partition `normal`:
```
sinfo -N --partition normal -o %G | awk -F ':' '{sum += $3} END {print sum}'
```

Count all GPUs that are part of running jobs in all partitions:
```
squeue -t R --format='%b' --all  | awk -F ':' '{sum += $NF} END {print sum}'
```

Depending on your Slurm setup you will want to tweak the partition (perhaps add a reservation) and maybe not use `--all` in `squeue`.


### Other resources

Check out my other help scripts:
1. [Train a ResNet to 94% accuracy on CIFAR-10 with only 150 lines of PyTorch](https://gist.github.com/y0ast/d91d09565462125a1eb75acc65da1469)
2. [FastMNIST - a drop in replacement for PyTorch' MNIST that avoids unnecessary processing - leading to 2-3x speed up on a **GPU**](https://gist.github.com/y0ast/f69966e308e549f013a92dc66debeeb4)
