#!/bin/bash
#SBATCH --job-name="MusMus_Intron"
#SBATCH --time=48:00:00  # walltime limit (HH:MM:SS)
#SBATCH --nodes=1   # number of nodes
#SBATCH --ntasks-per-node=1   # processor core(s) per node 
#SBATCH --mail-user="literman@uri.edu"
#SBATCH --mail-type=END,FAIL
#SBATCH --output="out_MusMus_Intron"
#SBATCH --error="out_MusMus_Intron"
# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE
cd $SLURM_SUBMIT_DIR

module load Python/3.6.1-foss-2017a
module load BEDTools/2.26.0-foss-2016b

python Intronic_BEDTools.py MusMus_NonIntron.bed MusMus_Genic.bed MusMus_Generated_Intronic.bed MusMus_Generated_ncGenes.bed
