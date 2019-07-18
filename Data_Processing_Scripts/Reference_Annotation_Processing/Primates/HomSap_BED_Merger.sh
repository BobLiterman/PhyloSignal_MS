#!/bin/bash
#SBATCH --job-name="HomSap_BED_Merger"
#SBATCH --time=96:00:00  # walltime limit (HH:MM:SS)
#SBATCH --nodes=1   # number of nodes
#SBATCH --ntasks-per-node=1   # processor core(s) per node 
#SBATCH --mail-user="literman@uri.edu"
#SBATCH --mail-type=END,FAIL
#SBATCH --output="out_HomSap_BED_Merger"
#SBATCH --error="out_HomSap_BED_Merger"
# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE
cd $SLURM_SUBMIT_DIR

module load Python/3.6.1-foss-2017a
module load BEDTools/2.26.0-foss-2016b

python /data3/schwartzlab/bob/Mammals_50X/refGenomes/scripts/BED_Merger.py HomSap_Unmerged_gene.bed HomSap_Merged_gene.bed hsapiens_gene_ensembl ENS
python /data3/schwartzlab/bob/Mammals_50X/refGenomes/scripts/BED_Merger.py HomSap_Unmerged_CDS.bed HomSap_Merged_CDS.bed hsapiens_gene_ensembl ENS
python /data3/schwartzlab/bob/Mammals_50X/refGenomes/scripts/BED_Merger.py HomSap_Unmerged_five_prime_UTR.bed HomSap_Merged_five_prime_UTR.bed hsapiens_gene_ensembl ENS
python /data3/schwartzlab/bob/Mammals_50X/refGenomes/scripts/BED_Merger.py HomSap_Unmerged_lnc_RNA.bed HomSap_Merged_lnc_RNA.bed hsapiens_gene_ensembl ENS
python /data3/schwartzlab/bob/Mammals_50X/refGenomes/scripts/BED_Merger.py HomSap_Unmerged_pseudogene.bed HomSap_Merged_pseudogene.bed hsapiens_gene_ensembl ENS
python /data3/schwartzlab/bob/Mammals_50X/refGenomes/scripts/BED_Merger.py HomSap_Unmerged_three_prime_UTR.bed HomSap_Merged_three_prime_UTR.bed hsapiens_gene_ensembl ENS

cat HomSap_Unmerged_miRNA.bed HomSap_Unmerged_ncRNA.bed HomSap_Unmerged_rRNA.bed HomSap_Unmerged_scRNA.bed HomSap_Unmerged_snoRNA.bed HomSap_Unmerged_snRNA.bed HomSap_Unmerged_tRNA.bed HomSap_Unmerged_vaultRNA_primary_transcript.bed  > HomSap_Unmerged_smRNA.bed
python /data3/schwartzlab/bob/Mammals_50X/refGenomes/scripts/BED_Merger.py HomSap_Unmerged_smRNA.bed HomSap_Merged_smRNA.bed hsapiens_gene_ensembl ENS
