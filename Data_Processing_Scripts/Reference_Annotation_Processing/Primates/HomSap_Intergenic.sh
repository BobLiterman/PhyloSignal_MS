cat HomSap_Generated_Intronic.bed HomSap_Merged_five_prime_UTR.bed HomSap_Merged_lnc_RNA.bed HomSap_Merged_smRNA.bed HomSap_Merged_CDS.bed HomSap_Merged_gene.bed HomSap_Merged_pseudogene.bed HomSap_Merged_three_prime_UTR.bed | bedtools sort -i - | bedtools merge -i - > HomSap_AllAnnotations.bed

python Intergenic_BEDTools.py HomSap_Chromosome.bed HomSap_AllAnnotations.bed HomSap_Generated_Intergenic.bed
