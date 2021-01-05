#!/bin/bash
# properties = {properties}

# exit on first error
set -o errexit
# Note: you have to source the environment to work 
set +u;
module load Python/3.7.4-GCCcore-8.3.0
module load GSL/2.6-GCC-8.3.0

CPU_ARCHITECTURE=$(/apps/misc/utils/bin/get-cpu-software-architecture.py)
echo "Setting up the environment for ${{CPU_ARCHITECTURE}} on $(hostname)"
source /well/palamara/users/agc404/python/${{CPU_ARCHITECTURE}}/bin/activate

sleep 1
set -u;

{exec_job}
