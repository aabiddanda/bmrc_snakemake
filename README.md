## BMRC Snakemake

Getting setup with using snakemake on the BMRC cluster at Oxford.

### Setting up Python Environments

Python is a little annoying to work with on BMRC because of the skylake and ivybridge processor differences. There is a nice way around this if you like to have consistent environments between the two. The directions below are just a more copy and pastable version of what you might want from this website: https://www.medsci.ox.ac.uk/divisional-services/support-services-1/bmrc/python-on-the-bmrc-cluster/#conda--anaconda-and-miniconda

1. Setup on rescomp1 & 2

```
module load Python/3.7.4-GCCcore-8.3.0
mkdir /well/palamara/users/<name>/python/
cd /well/palamara/users/<name>/python/
python -m venv skylake
source skylake/bin/activate

# Note now that you should be in the skylake environment now
pip3 install numpy scipy pandas matplotlib jupyterlab snakemake
pip3 freeze > requirements.txt
deactivate 
```

2. Setup on rescomp3

```
module load Python/3.7.4-GCCcore-8.3.0
cd /well/palamara/users/<name>/python/
python -m venv ivybridge 
source ivybridge/bin/activate

# Note now that you should be in the skylake environment now
pip3 install -r requirements
deactivate 
```

### Choosing the right Python environment in `.bashrc`

You can put in the following lines in your `bashrc` to always get the right version of python:

```
module load Python/3.7.4-GCCcore-8.3.0
module load GSL/2.6-GCC-8.3.0

# Discover the default CPU architecture
CPU_ARCHITECTURE=$(/apps/misc/utils/bin/get-cpu-software-architecture.py)

if [[ ! $? == 0 ]]; then
    echo "Fatal error: Please send the following information to the BMRC team: Could not determine CPU software architecture on $(hostname)"
    exit 1
fi

# Setting up my default python environment
source /well/palamara/users/<name>/python/${CPU_ARCHITECTURE}/bin/activate
```

With these specific steps in place, you will be able to use `snakemake`  on the cluster regardless of what processor architecture the job is being sent to.


## Running Snakemake

`snakemake -s test.smk all_rand_numbers all_hosts -j 4 --use-envmodules --max-status-checks-per-second 0.01 --profile profile/`

or:

`./run_snakemake.sh -s test.smk all_rand_numbers all_hosts` 

The `run_snakemake` command is effectively a short-hand for the above (with a default of 8 active jobs at a time)

Any question email: aabiddanda@gmail.com
