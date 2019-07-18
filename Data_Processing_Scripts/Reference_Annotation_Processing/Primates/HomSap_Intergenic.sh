#!/bin/bash
#SBATCH --job-name="HomSap_Intergenic"
#SBATCH --time=24:00:00  # walltime limit (HH:MM:SS)
#SBATCH --nodes=1   # number of nodes
#SBATCH --ntasks-per-node=20   # processor core(s) per node 
#SBATCH --mail-user="literman@uri.edu"
#SBATCH --mail-type=END,FAIL
#SBATCH --output="out_HomSap_Intergenic"
#SBATCH --error="out_HomSap_Intergenic"
# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE
cd $SLURM_SUBMIT_DIR

module load BEDTools/2.26.0-foss-2016b
module load Python/3.6.1-foss-2017a

cat HomSap_Generated_Intronic.bed HomSap_Merged_five_prime_UTR.bed HomSap_Merged_lnc_RNA.bed HomSap_Merged_smRNA.bed HomSap_Merged_CDS.bed HomSap_Merged_gene.bed HomSap_Merged_pseudogene.bed HomSap_Merged_three_prime_UTR.bed | bedtools sort -i - | bedtools merge -i - > HomSap_AllAnnotations.bed

python Intergenic_BEDTools.py HomSap_Chromosome.bed HomSap_AllAnnotations.bed HomSap_Generated_Intergenic.bed
