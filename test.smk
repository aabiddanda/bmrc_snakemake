#!python3

"""
A simple workflow to submit jobs to the cluster
inputs: Snakefile.smk (dummy input)
output: hostname.txt
"""

from snakemake.utils import min_version
min_version("5.26")

onsuccess: print("finished successfully") # insert more useful code here, e.g. send email to yourself
onerror: print("finished with errors") # insert more useful code here, e.g. send email to yourself

rule get_hostname:
    output: "data/hostname_{n,\d+}.txt"
    shell: "hostname > {output}"

rule all_hosts:
  input:
    expand("data/hostname_{n}.txt", n=range(8))

rule get_rand_numbers:
  """Testing out the application of rules in python."""
  output: "data/test_seed/seed{seed,\d+}.npz"
  benchmark: "benchmarks/test_seed/{seed}.tsv"
  run:
    import numpy as np
    seed = np.int(wildcards.seed)
    np.random.seed(seed)
    # Simulate a bunch of numbers here... 
    x = np.random.randint(low=0, high=1000000, size=1000)
    np.savez_compressed(str(output), a=x)

rule all_rand_numbers:
  input:
    expand("data/test_seed/seed{seed}.npz", seed=[24,42,144,360])


rule all_data:
  input:
    rules.all_rand_numbers.input,
    rules.all_hosts.input

rule clean:
  shell:
    """
    rm -rf data/
    rm -rf benchmarks/
    rm log/*.o*
    """


