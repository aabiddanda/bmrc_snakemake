## BMRC Snakemake

Getting setup with using snakemake on the BMRC cluster at Oxford.

### Setting up Python Environments

Python is a little annoying to work with on BMRC because of the `skylake` and `ivybridge` processor differences. There is a nice way around this if you like to have consistent environments between the two. The directions below are just a more copy and pastable version of what you might want from this website: https://www.medsci.ox.ac.uk/divisional-services/support-services-1/bmrc/python-on-the-bmrc-cluster/#conda--anaconda-and-miniconda

1. Setup on rescomp1 & 2

```
module load Python/3.7.4-GCCcore-8.3.0
mkdir /well/palamara/users/<name>/python/
cd /well/palamara/users/<name>/python/
python -m venv skylake
source skylake/bin/activate

# Note now that you should be in the skylake environment now
pip3 install numpy scipy pandas matplotlib jupyterlab snakemake msprime tszip stdpopsim
pip3 freeze > requirements.txt
deactivate 
```

2. Setup on rescomp3

```
module load Python/3.7.4-GCCcore-8.3.0
cd /well/palamara/users/<name>/python/
python -m venv ivybridge 
source ivybridge/bin/activate

# Note now that you should be in the ivybridge environment now
pip3 install -r requirements
deactivate 
```

The rationale for using these python environments over something like `conda` is that they are much more lightweight in terms of their memory requirements and uptime to be activated.  However, `conda` is much more comprehensive and can support things like `R`, `julia`, and various other packages. If you are considering using a conda environment, it is probably better to use 


### Choosing the right Python environment in `.bashrc`

You can put in the following lines in your `bashrc` to always get the right version of python right on startup:

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

With these specific steps in place, you will be able to use `snakemake`  on the cluster regardless of what processor architecture the job is being sent to. If at any point we want to use a more up to date version of `python` it is likely that we will want to rebuild our environments.

## Running Snakemake

`snakemake -s snakefiles/test.smk all_data -j 4 --use-envmodules --max-status-checks-per-second 0.01 --profile profile/`

or:

`./run_snakemake.sh -s snakefiles/test.smk all_data -j2` 

The `run_snakemake` command is effectively a short-hand for the above (with a default of 8 active jobs at a time)


### Bonus: Simulating Human Genetic Data

```
./run_snakemake -s snakefiles/sim.smk run_sim_chr22 -j2
```

This approach should simulate a quarter of chromosome22 and output two sets of bed/bim/fam files useable by `plink` and other software. Eventually - this is the kind of input that we will want for GWAS and other analyses of complex traits so it is useful to understand how to simulate similar data

## Contact 

For any questions regarding this pipeline, email: aabiddanda@gmail.com or alert via slack.
