import argparse
import json
import pathlib

import torch

print("Hello from inside Slurm")

parser = argparse.ArgumentParser()
parser.add_argument(
    "--output_folder", type=str, required=True, help="Set the output folder"
)
parser.add_argument(
    "--learning_rate", type=float, default=0.05, help="Learning rate (default: 0.05)"
)
parser.add_argument(
    "--dataset", required=True, choices=["MNIST", "CIFAR10"], help="Pick a dataset"
)
parser.add_argument(
    "--method", required=True, choices=["baseline", "mymethod"], help="Pick a method"
)
args = parser.parse_args()

print(args)

output_folder = pathlib.Path(args.output_folder)
output_folder.mkdir(parents=True)

accuracy = torch.rand(1).item()

results = {"accuracy": accuracy}
results_json = json.dumps(results, indent=4, sort_keys=True)
(output_folder / "results.json").write_text(results_json)
