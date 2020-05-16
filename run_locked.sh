#!/bin/bash
# Acquires a mutex and then runs the given program.
# There is a single mutex per user per machine, so only a single instance of
# run_locked.sh can be running at any one time.
# Use this to ensure only one "conda update" happens at once.

# Credits to Oscar Key <https://github.com/oscarkey> for this lock script.

if ! [ -x "$(command -v lockfile)" ]; then
  echo "Error: lockfile not available, must install procmail." >&2
  exit 1
fi

if [ $# -eq 0 ]
  then
    echo "Usage run_locked.sh [command] [arguments]"
    exit
fi

# We have a single lock per user.
lockfile_name=/tmp/run_locked_$USER
echo "Waiting for lock $lockfile_name at `date`"
echo "(will force acquire the lock in 3 minutes)"
# Set the lock timeout to 180 seconds (3 minutes)
lockfile -l 180 $lockfile_name
echo "Lock acquired at `date`"

$1 "${@:2}"

rm -f $lockfile_name
echo "Lock released at `date`"
