#!/bin/bash
#SBATCH --job-name="MusMus_Intergenic"
#SBATCH --time=24:00:00  # walltime limit (HH:MM:SS)
#SBATCH --nodes=1   # number of nodes
#SBATCH --ntasks-per-node=20   # processor core(s) per node 
#SBATCH --mail-user="literman@uri.edu"
#SBATCH --mail-type=END,FAIL
#SBATCH --output="out_MusMus_Intergenic"
#SBATCH --error="out_MusMus_Intergenic"
# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE
cd $SLURM_SUBMIT_DIR

module load BEDTools/2.26.0-foss-2016b
module load Python/3.6.1-foss-2017a

cat MusMus_Generated_Intronic.bed MusMus_Merged_CDS.bed MusMus_Merged_gene.bed MusMus_Merged_pseudogene.bed MusMus_Merged_three_prime_UTR.bed MusMus_Generated_codingGenes.bed MusMus_Generated_ncGenes.bed MusMus_Merged_five_prime_UTR.bed MusMus_Merged_lnc_RNA.bed MusMus_Merged_smRNA.bed | bedtools sort -i - | bedtools merge -i - > MusMus_AllAnnotations.bed

python Intergenic_BEDTools.py MusMus_Chromosome.bed MusMus_AllAnnotations.bed MusMus_Generated_Intergenic.bed
