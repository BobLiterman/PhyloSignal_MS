sed -i 's/ENSMUSG/gene_ENSMUSG/g' MusMus_Generated_ncGenes.bed
grep -F -x -v -f MusMus_Generated_ncGenes.bed MusMus_Merged_gene.bed > MusMus_Generated_codingGenes.bed
sed -i 's/gene_/cGene_/g' MusMus_Generated_codingGenes.bed
sed -i 's/gene_/ncGene_/g' MusMus_Generated_ncGenes.bed
