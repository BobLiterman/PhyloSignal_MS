cat MusMus_Generated_Intronic.bed MusMus_Merged_CDS.bed MusMus_Merged_gene.bed MusMus_Merged_pseudogene.bed MusMus_Merged_three_prime_UTR.bed MusMus_Generated_codingGenes.bed MusMus_Generated_ncGenes.bed MusMus_Merged_five_prime_UTR.bed MusMus_Merged_lnc_RNA.bed MusMus_Merged_smRNA.bed | bedtools sort -i - | bedtools merge -i - > MusMus_AllAnnotations.bed

python Intergenic_BEDTools.py MusMus_Chromosome.bed MusMus_AllAnnotations.bed MusMus_Generated_Intergenic.bed
