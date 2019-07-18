#!/bin/bash
#SBATCH --job-name="BosTau_BED_Merger"
#SBATCH --time=96:00:00  # walltime limit (HH:MM:SS)
#SBATCH --nodes=1   # number of nodes
#SBATCH --ntasks-per-node=1   # processor core(s) per node 
#SBATCH --mail-user="literman@uri.edu"
#SBATCH --mail-type=END,FAIL
#SBATCH --output="out_BosTau_BED_Merger"
#SBATCH --error="out_BosTau_BED_Merger"
# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE
cd $SLURM_SUBMIT_DIR

module load Python/3.6.1-foss-2017a
module load BEDTools/2.26.0-foss-2016b

python /data3/schwartzlab/bob/Mammals_50X/refGenomes/scripts/BED_Merger.py BosTau_Unmerged_CDS.bed BosTau_Merged_CDS.bed btaurus_gene_ensembl ENSBTA
python /data3/schwartzlab/bob/Mammals_50X/refGenomes/scripts/BED_Merger.py BosTau_Unmerged_five_prime_UTR.bed BosTau_Merged_five_prime_UTR.bed btaurus_gene_ensembl ENSBTA
python /data3/schwartzlab/bob/Mammals_50X/refGenomes/scripts/BED_Merger.py BosTau_Unmerged_gene.bed BosTau_Merged_gene.bed btaurus_gene_ensembl ENSBTA
python /data3/schwartzlab/bob/Mammals_50X/refGenomes/scripts/BED_Merger.py BosTau_Unmerged_pseudogene.bed BosTau_Merged_pseudogene.bed btaurus_gene_ensembl ENSBTA
python /data3/schwartzlab/bob/Mammals_50X/refGenomes/scripts/BED_Merger.py BosTau_Unmerged_three_prime_UTR.bed BosTau_Merged_three_prime_UTR.bed btaurus_gene_ensembl ENSBTA

cat BosTau_Unmerged_miRNA.bed BosTau_Unmerged_ncRNA.bed BosTau_Unmerged_rRNA.bed BosTau_Unmerged_snoRNA.bed BosTau_Unmerged_snRNA.bed BosTau_Unmerged_tRNA.bed > BosTau_Unmerged_smRNA.bed
python /data3/schwartzlab/bob/Mammals_50X/refGenomes/scripts/BED_Merger.py BosTau_Unmerged_smRNA.bed BosTau_Merged_smRNA.bed btaurus_gene_ensembl ENSBTA
