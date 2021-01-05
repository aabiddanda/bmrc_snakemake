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

pip3 install -r requirements
deactivate 
```

The rationale for using these python environments over something like `conda` is that they are much more lightweight in terms of their memory requirements and uptime to be activated.  However, `conda` is much more comprehensive and can support things like `R`, `julia`, and various other packages. If you are considering using software that has some more hardcore dependencies then conda is probably the way to go.

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

source /well/palamara/users/<name>/python/${CPU_ARCHITECTURE}/bin/activate
```

With these specific steps in place, you will be able to use `snakemake`  on the cluster regardless of what processor architecture the job is being sent to. If at any point we want to use a more up to date version of `python` it is likely that we will want to rebuild our environments.

## Running Snakemake

`snakemake -s snakefiles/test.smk all_data -j 4 --max-status-checks-per-second 0.01 --profile profile/`

or:

`./run_snakemake.sh -s snakefiles/test.smk all_data -j2` 

The `run_snakemake` command is effectively a short-hand for the above (with a default of 3 active jobs at a time)

### Bonus: Simulating Human Genetic Data

```
./run_snakemake -s snakefiles/sim.smk run_sim_chr22 -j4
```

This approach should simulate a quarter of chromosome 22 and output sets of bed/bim/fam files useable by `plink` and other software. Eventually this is the kind of input that we will want for performing GWAS and other analyses of complex traits so it is useful to understand how to simulate data in this way.

## Notes

### 5/1/2020

* In `cluster.yaml` you will notice that we only submit to jobs on the `short.qc@@short.hge` queue because these are the ones that have the `skylake` processors. This is primarily helpful because we freuently are running snakemake from `rescomp2` or `rescomp1` nodes, which have this processor. The offending libraries for this really are the `msprime` and `tskit` libraries that do not seem to play nicely with the `ivybridge` architecture.
* I have added benchmarking directives to the simulation rules as well so that  

## Contact 

For any questions regarding this pipeline, email: aabiddanda@gmail.com or alert via the PalamaraLab Slack.
