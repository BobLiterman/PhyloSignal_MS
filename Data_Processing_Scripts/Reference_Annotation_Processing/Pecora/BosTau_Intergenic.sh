#!/bin/bash
#SBATCH --job-name="BosTau_Intergenic"
#SBATCH --time=24:00:00  # walltime limit (HH:MM:SS)
#SBATCH --nodes=1   # number of nodes
#SBATCH --ntasks-per-node=20   # processor core(s) per node 
#SBATCH --mail-user="literman@uri.edu"
#SBATCH --mail-type=END,FAIL
#SBATCH --output="out_BosTau_Intergenic"
#SBATCH --error="out_BosTau_Intergenic"
# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE
cd $SLURM_SUBMIT_DIR

module load BEDTools/2.26.0-foss-2016b
module load Python/3.6.1-foss-2017a

cat BosTau_Generated_Intronic.bed BosTau_Merged_five_prime_UTR.bed BosTau_Merged_pseudogene.bed BosTau_Merged_three_prime_UTR.bed BosTau_Merged_CDS.bed BosTau_Merged_gene.bed BosTau_Merged_smRNA.bed | bedtools sort -i - | bedtools merge -i - > BosTau_AllAnnotations.bed

python Intergenic_BEDTools.py BosTau_Chromosome.bed BosTau_AllAnnotations.bed BosTau_Intergenic.bed
