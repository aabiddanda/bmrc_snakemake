#!python3

from snakemake.utils import min_version
min_version("5.26")

onsuccess: print("finished successfully") # insert more useful code here, e.g. send email to yourself
onerror: print("finished with errors") # insert more useful code here, e.g. send email to yourself

import numpy as np
import pandas as pd
import stdpopsim
import tszip
import os
import subprocess

Ns = [1000,5000]

rule sim_chrom_hom_sap:
  """ Simulate a single chromosome using the stdpopsim library - output to bcf format."""
    output:
      vcf = 'data/raw_data/chr{chrom,\d+}_vcf/n_{n}_tot_sim_seed{seed,\d+}.vcf',
      ts = 'data/raw_data/chr{chrom,\d+}_vcf/n_{n}_tot_sim_seed{seed,\d+}.tsz'
    benchmark: "benchmarks/test_chrom_hap_sim/samp_chrom_{chrom}_n{n}.seed{seed}.tsv"
    run:
      # pre-load bcftools for downstream stuff
      shell("set +u; module load BCFtools/1.10.2-GCC-8.3.0; sleep 2; set -u;")
      # Simulating half of human chromosome 22
      species = stdpopsim.get_species("HomSap")
      contig = species.get_contig("chr%d" % int(wildcards.chrom), length_multiplier=0.25)
      # NOTE: not a very accurate demography here ...
      model = stdpopsim.PiecewiseConstantSize(species.population_size)
      samples = model.get_samples(2*int(wildcards.n))
      engine = stdpopsim.get_engine("msprime")
      ts = engine.simulate(model, contig, samples, seed=np.int(wildcards.seed))
      # save the tszipped version of the tree
      tszip.compress(ts, str(output.ts))
      with open(str(output.vcf), "w") as bcf_file:
        ts.write_vcf(bcf_file, ploidy=2, contig_id='%d' % int(wildcards.chrom), position_transform='legacy')
      
rule conv_bcf2plink:
    input:
        vcf = rules.sim_chrom_hom_sap.output.vcf
    output:
        bed = 'data/raw_data/chr{chrom}_vcf/n_{n}_tot_sim_seed{seed,\d+}.bed',
        bim = 'data/raw_data/chr{chrom}_vcf/n_{n}_tot_sim_seed{seed,\d+}.bim',
        fam = 'data/raw_data/chr{chrom}_vcf/n_{n}_tot_sim_seed{seed,\d+}.fam'
    shell:
        """
        module purge
        module load PLINK BCFtools/1.10.2-GCC-8.3.0; sleep 2 
        plink2 --vcf {input.vcf} --double-id --set-missing-var-ids @:#:\$1:\$2 --make-bed --out data/raw_data/chr22_vcf/n_{wildcards.n}_tot_sim_seed{wildcards.seed}
        rm {input.vcf}
        """
        
rule run_sim_chr22:
    input:
        expand('data/raw_data/chr22_vcf/n_{n}_tot_sim_seed{seed}.bed', n=Ns, seed=[24,42])
