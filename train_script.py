import sys
import torch

print("Hello from inside Slurm")
print(f"Command line flags passed: {sys.argv[1:]}")

# Store results in run/<args.subdir>
