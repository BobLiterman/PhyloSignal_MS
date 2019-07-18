sed -i 's/ENSG/gene_ENSG/g' HomSap_Generated_ncGenes.bed
grep -F -x -v -f HomSap_Generated_ncGenes.bed HomSap_Merged_gene.bed > HomSap_Generated_codingGenes.bed
sed -i 's/gene_/cGene_/g' HomSap_Generated_codingGenes.bed
sed -i 's/gene_/cGene_/g' HomSap_Generated_codingGenes.bed
