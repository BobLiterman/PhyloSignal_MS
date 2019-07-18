cat BosTau_Generated_Intronic.bed BosTau_Merged_five_prime_UTR.bed BosTau_Merged_pseudogene.bed BosTau_Merged_three_prime_UTR.bed BosTau_Merged_CDS.bed BosTau_Merged_gene.bed BosTau_Merged_smRNA.bed | bedtools sort -i - | bedtools merge -i - > BosTau_AllAnnotations.bed

python Intergenic_BEDTools.py BosTau_Chromosome.bed BosTau_AllAnnotations.bed BosTau_Intergenic.bed
