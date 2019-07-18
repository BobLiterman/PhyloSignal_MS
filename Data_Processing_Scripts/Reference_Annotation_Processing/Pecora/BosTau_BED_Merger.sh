python /data3/schwartzlab/bob/Mammals_50X/refGenomes/scripts/BED_Merger.py BosTau_Unmerged_CDS.bed BosTau_Merged_CDS.bed btaurus_gene_ensembl ENSBTA
python /data3/schwartzlab/bob/Mammals_50X/refGenomes/scripts/BED_Merger.py BosTau_Unmerged_five_prime_UTR.bed BosTau_Merged_five_prime_UTR.bed btaurus_gene_ensembl ENSBTA
python /data3/schwartzlab/bob/Mammals_50X/refGenomes/scripts/BED_Merger.py BosTau_Unmerged_gene.bed BosTau_Merged_gene.bed btaurus_gene_ensembl ENSBTA
python /data3/schwartzlab/bob/Mammals_50X/refGenomes/scripts/BED_Merger.py BosTau_Unmerged_pseudogene.bed BosTau_Merged_pseudogene.bed btaurus_gene_ensembl ENSBTA
python /data3/schwartzlab/bob/Mammals_50X/refGenomes/scripts/BED_Merger.py BosTau_Unmerged_three_prime_UTR.bed BosTau_Merged_three_prime_UTR.bed btaurus_gene_ensembl ENSBTA

cat BosTau_Unmerged_miRNA.bed BosTau_Unmerged_ncRNA.bed BosTau_Unmerged_rRNA.bed BosTau_Unmerged_snoRNA.bed BosTau_Unmerged_snRNA.bed BosTau_Unmerged_tRNA.bed > BosTau_Unmerged_smRNA.bed
python /data3/schwartzlab/bob/Mammals_50X/refGenomes/scripts/BED_Merger.py BosTau_Unmerged_smRNA.bed BosTau_Merged_smRNA.bed btaurus_gene_ensembl ENSBTA
