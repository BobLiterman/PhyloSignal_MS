python /data3/schwartzlab/bob/Mammals_50X/refGenomes/scripts/BED_Merger.py HomSap_Unmerged_gene.bed HomSap_Merged_gene.bed hsapiens_gene_ensembl ENS
python /data3/schwartzlab/bob/Mammals_50X/refGenomes/scripts/BED_Merger.py HomSap_Unmerged_CDS.bed HomSap_Merged_CDS.bed hsapiens_gene_ensembl ENS
python /data3/schwartzlab/bob/Mammals_50X/refGenomes/scripts/BED_Merger.py HomSap_Unmerged_five_prime_UTR.bed HomSap_Merged_five_prime_UTR.bed hsapiens_gene_ensembl ENS
python /data3/schwartzlab/bob/Mammals_50X/refGenomes/scripts/BED_Merger.py HomSap_Unmerged_lnc_RNA.bed HomSap_Merged_lnc_RNA.bed hsapiens_gene_ensembl ENS
python /data3/schwartzlab/bob/Mammals_50X/refGenomes/scripts/BED_Merger.py HomSap_Unmerged_pseudogene.bed HomSap_Merged_pseudogene.bed hsapiens_gene_ensembl ENS
python /data3/schwartzlab/bob/Mammals_50X/refGenomes/scripts/BED_Merger.py HomSap_Unmerged_three_prime_UTR.bed HomSap_Merged_three_prime_UTR.bed hsapiens_gene_ensembl ENS

cat HomSap_Unmerged_miRNA.bed HomSap_Unmerged_ncRNA.bed HomSap_Unmerged_rRNA.bed HomSap_Unmerged_scRNA.bed HomSap_Unmerged_snoRNA.bed HomSap_Unmerged_snRNA.bed HomSap_Unmerged_tRNA.bed HomSap_Unmerged_vaultRNA_primary_transcript.bed  > HomSap_Unmerged_smRNA.bed
python /data3/schwartzlab/bob/Mammals_50X/refGenomes/scripts/BED_Merger.py HomSap_Unmerged_smRNA.bed HomSap_Merged_smRNA.bed hsapiens_gene_ensembl ENS