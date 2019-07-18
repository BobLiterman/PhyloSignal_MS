#!/bin/bash
#SBATCH --job-name="MusMus_BED_Merger"
#SBATCH --time=96:00:00  # walltime limit (HH:MM:SS)
#SBATCH --nodes=1   # number of nodes
#SBATCH --ntasks-per-node=1   # processor core(s) per node 
#SBATCH --mail-user="literman@uri.edu"
#SBATCH --mail-type=END,FAIL
#SBATCH --output="out_MusMus_BED_Merger"
#SBATCH --error="out_MusMus_BED_Merger"
# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE
cd $SLURM_SUBMIT_DIR

module load Python/3.6.1-foss-2017a
module load BEDTools/2.26.0-foss-2016b

python /data3/schwartzlab/bob/Mammals_50X/refGenomes/scripts/BED_Merger.py MusMus_Unmerged_CDS.bed MusMus_Merged_CDS.bed mmusculus_gene_ensembl ENSMUS
python /data3/schwartzlab/bob/Mammals_50X/refGenomes/scripts/BED_Merger.py MusMus_Unmerged_five_prime_UTR.bed MusMus_Merged_five_prime_UTR.bed mmusculus_gene_ensembl ENSMUS
python /data3/schwartzlab/bob/Mammals_50X/refGenomes/scripts/BED_Merger.py MusMus_Unmerged_gene.bed MusMus_Merged_gene.bed mmusculus_gene_ensembl ENSMUS
python /data3/schwartzlab/bob/Mammals_50X/refGenomes/scripts/BED_Merger.py MusMus_Unmerged_lnc_RNA.bed MusMus_Merged_lnc_RNA.bed mmusculus_gene_ensembl ENSMUS
python /data3/schwartzlab/bob/Mammals_50X/refGenomes/scripts/BED_Merger.py MusMus_Unmerged_pseudogene.bed MusMus_Merged_pseudogene.bed mmusculus_gene_ensembl ENSMUS
python /data3/schwartzlab/bob/Mammals_50X/refGenomes/scripts/BED_Merger.py MusMus_Unmerged_three_prime_UTR.bed MusMus_Merged_three_prime_UTR.bed mmusculus_gene_ensembl ENSMUS

cat MusMus_Unmerged_miRNA.bed MusMus_Unmerged_ncRNA.bed MusMus_Unmerged_rRNA.bed MusMus_Unmerged_scRNA.bed MusMus_Unmerged_snoRNA.bed MusMus_Unmerged_snRNA.bed MusMus_Unmerged_tRNA.bed > MusMus_Unmerged_smRNA.bed
python /data3/schwartzlab/bob/Mammals_50X/refGenomes/scripts/BED_Merger.py MusMus_Unmerged_smRNA.bed MusMus_Merged_smRNA.bed mmusculus_gene_ensembl ENSMUS
