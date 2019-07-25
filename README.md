# Code Walkthrough for Literman and Schwartz (2019)  

## Please Note:  
This repo is meant as a specific walkthrough for the analyses performed in Literman and Schwartz (2019).  

### 1) Acquiring study data  
In this manuscript, we investigated how phylogenetic signal was distributed across the genomes of three focal mammal clades. The species and their shortened analysis IDs are listed below, with the reference species for each dataset indicated in **bold**. SRR numbers for all species can be found in [**Data_and_Tables/Read_Data/SRR_Table.csv**](Data_and_Tables/Read_Data/SRR_Table.csv). All reads are Illumina paired-end reads from WGS-type sequencing.  

- Catarrhine primates  (*Primates*)  
  - Colobus angolensis (ColAng)  
  - Gorilla gorilla	(GorGor)  
  - **Homo sapiens	(HomSap)**  
  - Hylobates moloch	(HylMol)  
  - Macaca mulatta	(MacMul)  
  - Macaca nemestrina	(MacNem)  
  - Pan paniscus	(PanPan)  
  - Pan troglodytes	(PanTro)  
  - Papio anubis	(PapAnu)  
  - Papio cynocephalus (PapCyn)  
  - Outgroup:  
    - Aotus nancymaae (AotNan)  
    - Callithrix jacchus (CalJac)  


- Murid rodents  (*Rodents*)  
  - Apodemus sylvaticus	(ApoSyl)  
  - Apodemus uralensis	(ApoUra)  
  - Mastomys coucha	(MasCou)  
  - Meriones unguiculatus	(MerUng)  
  - Mus caroli	(MusCar)  
  - **Mus musculus	(MusMus)**  
  - Mus spretus	(MusSpr)  
  - Psammomys obesus	(PsaObe)  
  - Rattus nitidus	(RatNit)  
  - Rattus norvegicus	(RatNor)  
  - Outgroup:  
    - Ellobius lutescens (EllLut)
    - Peromyscus leucopus (PerLeu)  


- *Pecora*  
  - Bison bison	(BisBis)  
  - **Bos taurus	(BosTau)**  
  - Bubalis bubalis	(BubBub)  
  - Capra aegagrus	(CapAeg)  
  - Capra hircus	(CapHir)  
  - Elaphurus davidianus	(ElaDav)  
  - Giraffa tippelskirchi	(GirTip)  
  - Odocoileus virginianus	(OdoVir)  
  - Okapia johnstoni	(OkaJoh)  
  - Ovis aries	(OviAri)  
  - Outgroup:  
    - Balaena mysticetus (BalMys)  
    - Hippopotamus amphibius (HipAmp)  

There was also an analysis will all 36 species combined (*Combined*).  

All reference topologies can be found in [**Data_and_Tables/Reference_Topologies**](Data_and_Tables/Reference_Topologies)

![alt text](Sample_Images/Reference_Tree.png)

### 2) Read QC  

Read quality was assessed before and after trimming using FastQC v.0.11.5.  

HTML output from FastQC can be found in [**Data_and_Tables/Read_Data/FastQC**](Data_and_Tables/Read_Data/FastQC)  

### 3) Read trimming  

All reads were trimmed using BBDuk v.37.41 using the following command:  
```
bbduk.sh maxns=0 ref=adapters.fa qtrim=w trimq=15 minlength=35 maq=25 in=<RAW_LEFT> in2=<RAW_RIGHT> out=<TRIM_LEFT> out2=<TRIM_RIGHT> k=23 mink=11 hdist=1 hdist2=0 ktrim=r
```
Read trimming scripts can be found in [**Data_Processing_Scripts/Trim_Scripts**](Data_Processing_Scripts/Trim_Scripts)  


Read trimming output can be found in [**Data_and_Tables/Read_Data/Read_Trim_Output**](Data_and_Tables/Read_Data/Read_Trim_Output)  

### 4) Read subsetting  

The SISRS pipeline identifies orthologous loci through a 'composite genome' assembly step. The first step for this assembly is to subset the reads of each species so that ideally:  

1) Each species is represented in the assembly by the same total number of bases.  
2) Within each species, bases are sampled evenly across read sets.    
3) The pooled base count across species is ~10X genomic coverage.  
  - For this study, we used 3.5Gb as a rough genome size estimate for all groups.  

For the three focal datasets (Primtes, Rodents, and Pecora):  
- 10X = 35Gb / 12 species ~ 2,916,666,667 bases per species  

For the combined analysis: 10X = 35Gb / 36 species ~ 972,222,222 bases per species

Reads for each dataset (Primates, Rodents, Pecora, Combined) were subset using the script [**Data_Processing_Scripts/Base_SISRS_Scripts/sisrs_read_subsetter.py**](Data_Processing_Scripts/Base_SISRS_Scripts/sisrs_read_subsetter.py)  
```
python sisrs_read_subsetter.py 3500000000
```

Subset schemes used in this study can be found in [**Data_and_Tables/Subset_Schemes**](Data_and_Tables/Subset_Schemes)  
Output from subsetting can be found in [**Data_and_Tables/Subset_Schemes/Subset_Output**](Data_and_Tables/Subset_Schemes/Subset_Output)  

### 5) Composite genome assembly  

This manuscript uses Ray (https://github.com/sebhtml/ray) to assemble composite genomes. Ray commands were generated automatically by [**Data_Processing_Scripts/Base_SISRS_Scripts/sisrs_ray_composite.py**](Data_Processing_Scripts/Base_SISRS_Scripts/sisrs_ray_composite.py)  

```
#To run on 8 nodes with 20 processors per node  
python sisrs_ray_composite.py 8 20  

#Outut:
$ mpirun -n 160 Ray -k 31 {-s <READ_FILE>} -o <OUTPUT_DIR>
# Where each subset read file is indicated with a -s flag (e.g. not using paired-end information)
```

Ray assembly scripts can be found in [**Data_Processing_Scripts/Base_SISRS_Scripts/Ray_Scripts**](Data_Processing_Scripts/Base_SISRS_Scripts/Ray_Scripts)  

**Composite Genome Statistics**  

**Dataset**|**Contigs Assembled**|**N50 (bp)**|**Longest Contig (bp)**|**Composite Bases**
:-----:|:-----:|:-----:|:-----:|:-----:
Pecora|3,375,179 |148 |18,508 |524,476,971
Primates|3,356,297 |152 |7,038 |532,512,652
Rodents|6,407,239 |152 |6,445 |1,022,381,442
Combined|2,113,479 |146 |8,196 |320,262,920

### 6) Running taxon-specific (independent) SISRS steps  

The next step of SISRS involves converting this single composite genome to multiple, taxon-specific ortholog sequences. This involves a few key steps:  

1) Map reads from each taxon onto composite genome  
2) Replace the composite base with the most common taxon-specific base  
3) Re-map the reads onto the new corrected genome, but for any site with less than 3 reads of coverage or more than 1 possible base, replace with 'N'  

The script [**Data_Processing_Scripts/Base_SISRS_Scripts/sisrs_setup_run.py**](Data_Processing_Scripts/Base_SISRS_Scripts/sisrs_setup_run.py) will do the following:  
- Rename Ray contigs to include 'SISRS_' prefix, build a Bowtie2 index, and move to analysis folder  
- Generate scripts to perform Steps 1-3 above  

```
#For 20 processors, minimum read coverage of 3 reads, and 100% intraspecies homozygosity at each called site:
python sisrs_setup_run.py 20 3 1
```
Running this script will prepare the composite genome, then generate a separate SISRS script for each taxon (TAXA), the skeleton of which is below:  
```
#!/bin/sh
bowtie2 -p PROCESSORS -N 1 --local -x BOWTIE2-INDEX -U READS | samtools view -Su -@ PROCESSORS -F 4 - | samtools sort -@ PROCESSORS - -o SISRS_DIR/TAXA/TAXA_Temp.bam

samtools view -@ PROCESSORS -H SISRS_DIR/TAXA/TAXA_Temp.bam > SISRS_DIR/TAXA/TAXA_Header.sam

samtools view -@ PROCESSORS SISRS_DIR/TAXA/TAXA_Temp.bam | grep -v "XS:" | cat SISRS_DIR/TAXA/TAXA_Header.sam - | samtools view -@ PROCESSORS -b - > SISRS_DIR/TAXA/TAXA.bam

rm SISRS_DIR/TAXA/TAXA_Temp.bam
rm SISRS_DIR/TAXA/TAXA_Header.sam

samtools mpileup -f COMPOSITE_GENOME SISRS_DIR/TAXA/TAXA.bam > SISRS_DIR/TAXA/TAXA.pileups

python SCRIPT_DIR/specific_genome.py SISRS_DIR/TAXA COMPOSITE_GENOME

samtools faidx SISRS_DIR/TAXA/contigs.fa
bowtie2-build SISRS_DIR/TAXA/contigs.fa SISRS_DIR/TAXA/contigs -p PROCESSORS

bowtie2 -p PROCESSORS -N 1 --local -x SISRS_DIR/TAXA/contigs -U READS | samtools view -Su -@ PROCESSORS -F 4 - | samtools sort -@ PROCESSORS - -o SISRS_DIR/TAXA/TAXA_Temp.bam

samtools view -@ PROCESSORS -H SISRS_DIR/TAXA/TAXA_Temp.bam > SISRS_DIR/TAXA/TAXA_Header.sam
samtools view -@ PROCESSORS SISRS_DIR/TAXA/TAXA_Temp.bam | grep -v "XS:" | cat SISRS_DIR/TAXA/TAXA_Header.sam - | samtools view -@ PROCESSORS -b - > SISRS_DIR/TAXA/TAXA.bam

rm SISRS_DIR/TAXA/TAXA_Temp.bam
rm SISRS_DIR/TAXA/TAXA_Header.sam

samtools index SISRS_DIR/TAXA/TAXA.bam

samtools mpileup -f COMPOSITE_GENOME SISRS_DIR/TAXA/TAXA.bam > SISRS_DIR/TAXA/TAXA.pileups

python SCRIPT_DIR/get_pruned_dict.py SISRS_DIR/TAXA COMPOSITE_DIR MINREAD THRESHOLD
```

These scripts and their output can be found in [**Data_Processing_Scripts/Base_SISRS_Scripts/Taxon_SISRS_Scripts**](Data_Processing_Scripts/Base_SISRS_Scripts/Taxon_SISRS_Scripts)  

### 7) Output SISRS alignments

The final step of the SISRS pipeline takes the output from each species and creates a series of alignments:  
- All variable sites
- All variable sites without singletons (parsimony-informative sites)
- All biallelic parsimony-informative sites

Running the script [**Data_Processing_Scripts/Base_SISRS_Scripts/sisrs_output.py**](Data_Processing_Scripts/Base_SISRS_Scripts/sisrs_output.py) will generate these alignments both with and without gap positions, and with a number of species allowed to be missing (0 in this study). This script will also compile summary outputs.
```
#To output gapped and ungapped alignments with 0 taxa allowed missing
python sisrs_output.py 0
```
The output from these scripts can be found in [**Data_and_Tables/SISRS_Alignment_Output**](Data_and_Tables/SISRS_Alignment_Output)  

**Note:** This represents the terminal output of a traditional SISRS run.

**Raw SISRS Output**  

**Dataset**|**Composite Bases**|**Variable Sites**|**Singleton Sites**|**Parsimony-Informative Sites**|**Biallelic P.I. Sites**|**Biallelic P.I. Sites (No indels or missing taxa)**
:-----:|:-----:|:-----:|:-----:|:-----:|:-----:|:-----:
Pecora|524,476,971 |85,083,658 |47,698,420 |37,385,238 |33,500,141 |10,890,450
Primates|532,512,652 |65,427,169 |33,957,072 |31,470,097 |29,198,422 |11,862,054
Rodents|10,223,814,421 |155,467,941 |89,288,017 |66,179,924 |58,003,231 |3,761,214
Combined|320,262,920 |62,161,232 |31,270,976 |30,890,256 |26,725,108 |337,663

### 8) Filtering SISRS orthologs via reference genome mapping  

Because SISRS-derived orthologs are generated via *de novo* genome assembly, the assembled contigs lack any annotation or locus information. By having one species per focal dataset with a well-assembled and well-annotated reference genome, we were able to further filter the SISRS orthologs based on their ability to uniquely map to the reference genome.

We downloaded canonical chromosomes (e.g. no unlinked or alternative scaffolds) + MT scaffolds from the Ensembl Build 92 versions of the *Homo sapiens*, *Mus musculus*, and *Bos taurus* genomes and their associated annotation files.  

Bowtie2 and Samtools indexes were made for each genome...  
```
bowtie2-build Homo_sapiens.GRCh38.dna.chromosome.CANONICAL.fa HomSap_Ens92
samtools faidx Homo_sapiens.GRCh38.dna.chromosome.CANONICAL.fa

bowtie2-build Mus_musculus.GRCm38.dna.chromosome.CANONICAL.fa MusMus_Ens92
samtools faidx Mus_musculus.GRCm38.dna.chromosome.CANONICAL.fa

bowtie2-build Bos_taurus.UMD3.1.dna.chromosome.CANONICAL.fa BosTau_Ens92
samtools faidx Bos_taurus.UMD3.1.dna.chromosome.CANONICAL.fa
```

For each dataset (*Primates*, *Rodents*, *Pecora*, *Combined*), the reference species (*HomSap*, *MusMus*, *BosTau*, *HomSap*) orthologs were mapped against the reference genome using [**Data_Processing_Scripts/Post_SISRS_Scripts/post_sisrs_reference.py**](Data_Processing_Scripts/Post_SISRS_Scripts/post_sisrs_reference.py). This script:  

- Removes contigs that cannot be mapped to the reference (and therefore cannot be annotated)  
- Removes contigs that multiply map (obscuring their evolutionary origin)  
- Separates data into gapped and gapless subsets
- Removes sites that are contained in multiple contigs (contigs that map to overlapping positions in the reference)
- Provides a coordinate system for downstream annotation  

```
# 20 refers to 20 processors

# Primates
python post_sisrs_reference.py 20 HomSap

# Rodents
python post_sisrs_reference.py 20 MusMus

# Pecora
python post_sisrs_reference.py 20 BosTau

# Combined
python post_sisrs_reference.py 20 HomSap
```

The output from these scripts can be found in [**Data_Processing_Scripts/Post_SISRS_Scripts/Post_SISRS_Output_Logs**](Data_Processing_Scripts/Post_SISRS_Scripts/Post_SISRS_Output_Logs)  


### 9) Identifying phylogenetic signal from alignments of biallelic SISRS sites  

Each biallelic SISRS site splits the data into two sets of taxa. If the taxonomic splits agree with a split in the reference topology, that site is designated as '**concordant**', or providing historical phylogenetic signal.  

![alt text](Sample_Images/Good_Split.png)  

If the taxonomic split does not agree with a split in the reference topology, that site is designated as '**discordant**', or providing non-historical phylogenetic signal.  

![alt text](Sample_Images/Bad_Split.png)  

Site splits were tabulated using [**Data_Processing_Scripts/Post_SISRS_Scripts/post_sisrs_site_splits.py**](Data_Processing_Scripts/Post_SISRS_Scripts/post_sisrs_site_splits.py)  

Site split output can be found in [**Data_and_Tables/Site_Splits**](Data_and_Tables/Site_Splits)  

### 10) Site Annotation  

Once sites were mapped to the reference genome, BEDTools was used to transfer annotations from the reference genome to the SISRS orthologs. In this way, each site can be annotated as one of the following locus types:  
- Coding sequence (CDS). including all annotated transcript variants  
- Five-prime UTR  
- Three-prime UTR  
- Intronic (gene region minus CDS/UTR)
- Pseudogenes  
- Long-noncoding RNA (lncRNA; none annotated in Pecora)  
- Noncoding Genes (genes without annotated CDS; none annotated in Pecora)  
- Small RNAs (smRNA; miRNAs + ncRNAs + rRNAs + scRNAs + smRNAs + snoRNAs + snRNAs + tRNAs + vaultRNAs)  
- Intergenic/Unannotated  

In some cases an individual SISRS site may have multiple annotations types, such as pseudogenes within introns, or alternative five prime UTR regions overlapping CDS.

Sites were annotated using [**Data_Processing_Scripts/Post_SISRS_Scripts/post_sisrs_site_annotation.py**](Data_Processing_Scripts/Post_SISRS_Scripts/post_sisrs_site_annotation.py)  

```
# 20 refers to 20 processors

# Primates
python post_sisrs_site_annotation.py 20 HomSap

# Rodents
python post_sisrs_site_annotation.py 20 MusMus

# Pecora
python post_sisrs_site_annotation.py 20 BosTau

# Combined
python post_sisrs_site_annotation 20 HomSap
```

Site annotation output can be found in [**Data_and_Tables/Annotation_Counts**](Data_and_Tables/Annotation_Counts)  

Alignments of raw SISRS data (e.g. pre-reference mapping) and of each locus type can be found in [**Data_and_Tables/Alignments**](Data_and_Tables/Alignments)  

**Composite Genome Site Annotation**   

| Locus Type             | Pecora Count | Primate Count | Rodent Count | Combined Count | Pecora Percent | Primate Percent | Rodent Percent | Combined Percent | Pecora Z-Score | Primate Z-Score | Rodent Z-Score | Combined Z-Score |
|------------------------|--------------|---------------|--------------|----------------|----------------|-----------------|----------------|------------------|----------------|-----------------|----------------|------------------|
| CDS                    | 6,374,618    | 7,991,639     | 6,814,890    | 3,266,450      | 19.71%         | 22.41%          | 18.67%         | 9.16%            | 1.66           | 2.07            | 1.00           | **4.29**             |
| Five Prime UTR         | 274,524      | 1,509,745     | 1,193,444    | 405,721        | 17.60%         | 14.54%          | 16.09%         | 3.91%            | 1.00           | 0.23            | 0.12           | 0.00             |
| Intergenic/Unannotated | 234,312,422  | 174,285,472   | 171,476,950  | 39,291,066     | 12.44%         | 11.90%          | 11.26%         | 2.68%            | 0.62           | 1.00            | 2.22           | 1.00             |
| Intronic               | 105,992,896  | 185,434,227   | 158,008,365  | 46,913,468     | 14.41%         | 15.34%          | 16.37%         | 3.88%            | 0.00           | 0.00            | 0.00           | 0.02             |
| Long-noncoding RNAs    | NA           | 143,813,362   | 93,661,007   | 36,855,634     | NA             | 15.32%          | 16.38%         | 3.93%            | NA             | 0.00            | 0.01           | 0.02             |
| Noncoding Gene         | NA           | 671,317       | 1,582,200    | 168,895        | NA             | 15.75%          | 17.48%         | 3.96%            | NA             | 0.12            | 0.48           | 0.04             |
| Pseudogene             | 38,541       | 3,739,955     | 1,495,032    | 829,961        | 5.63%          | 6.49%           | 5.48%          | 1.44%            | **2.75**           | 2.58            | **4.72**           | 2.02             |
| Small RNAs             | 55,704       | 113,518       | 86,588       | 25,866         | 13.07%         | 11.34%          | 12.12%         | 2.58%            | 0.42           | 1.16            | 1.84           | 1.08             |
| Three Prime UTR        | 1,426,542    | 8,472,688     | 6,976,396    | 2,841,301      | 19.15%         | 19.27%          | 19.42%         | 6.46%            | 1.49           | 1.15            | 1.32           | 2.09             |

### 11) Maximum-likelihood tree estimation from SISRS data    

The raw, gapless biallelic site output from SISRS along with concatenated alignments from locus specific subsets were used to infer ML trees using RAxML.  

```
raxmlHPC-PTHREADS-SSE3 -s {alignment} -n {name} -m ASC_GTRGAMMA --asc-corr=lewis -T 20 -f a -p $RANDOM -N autoMRE -x $RANDOM
```

Trees inferred from raw SISRS data from each locus type can be found in [**Data_and_Tables/RAxML_Trees**](Data_and_Tables/RAxML_Trees)  

### 12a) Node Dating  

In order to look at changes in phylogenetic utility over evolutionary time, nodes in the reference topologies were dated using a subset of the SISRS ortholog data. Briefly, all SISRS orthologs were sorted based on the total number of SISRS sites contained within. The top 50,000 orthologs were aligned and concatenated. Using those alignments, we estimated branch lengths on the fixed reference topology. These alignments are generated using [**Data_Processing_Scripts/Post_SISRS_Scripts/post_sisrs_chronos.py**](Data_Processing_Scripts/Post_SISRS_Scripts/post_sisrs_chronos.py)  

```
#Primates
python post_sisrs_chronos.py 20 HomSap 50000

#Rodents
python post_sisrs_chronos.py 20 MusMus 50000

#Pecora
python post_sisrs_chronos.py 20 BosTau 50000

#Combined
python post_sisrs_chronos.py 20 HomSap 50000
```

The output from these scripts can be found in [**Data_and_Tables/Node_Date_Information/01_RAxML_Trees**](Data_and_Tables/Node_Date_Information/01_RAxML_Trees)  

**Note:** All downstream analyses performed using [**Data_Processing_Scripts/Post_SISRS_Scripts/PhyloSignal_Data_Processing.R**](Data_Processing_Scripts/Post_SISRS_Scripts/PhyloSignal_Data_Processing.R)  

---

### 12b) Node Dating (continued)

Using these branch length estimates, divergence times for each focal node in the reference topology were estimated 1000 times using the chronos function in R, from the ape package. The median value for each node age was computed and used for downstream analyses. For each focal group, the root node age was calibrated using minimum and maximum divergence times estimates from the TimeTree.org database (accessed 05.30.2019). For the Combined analysis, we calibrated the root node of the entire tree, as well as the root nodes for each focal group.  

The median dates for each node can be found in [**Data_and_Tables/Node_Date_Information/02_Date_Estimates**](Data_and_Tables/Node_Date_Information/02_Date_Estimates)  

The inferred dated trees for each dataset can be found in [**Data_and_Tables/Node_Date_Information/03_R_TimeTrees**](Data_and_Tables/Node_Date_Information/03_R_TimeTrees)  

### 13) Assessing biases among locus types using modified Z-score analysis

1. For each locus type in the reference genome, we calculated the percent of those sites identified in the composite genome.  
2. Using the median percentage for all locus types, we analyzed deviations around the median using the median average deviation (MAD; **Modified Z-Score analysis**)
3. We performed the same analysis comparing sites from the composite genome that were selected by SISRS  
4. We then contrasted the proportion of sites carrying phylogenetic signal across locus types

**Results of Z-Score analysis of composite genome assembly**  
**Note:** Bold numbers indicate significant results  

| Locus Type             | Pecora Count | Primate Count | Rodent Count | Combined Count | Pecora Percent | Primate Percent | Rodent Percent | Combined Percent | Pecora Z-Score | Primate Z-Score | Rodent Z-Score | Combined Z-Score |
|------------------------|--------------|---------------|--------------|----------------|----------------|-----------------|----------------|------------------|----------------|-----------------|----------------|------------------|
| CDS                    | 6,374,618    | 7,991,639     | 6,814,890    | 3,266,450      | 19.71%         | 22.41%          | 18.67%         | 9.16%            | 1.66           | 2.07            | 1.00           | **4.29 (+)**             |
| Five Prime UTR         | 274,524      | 1,509,745     | 1,193,444    | 405,721        | 17.60%         | 14.54%          | 16.09%         | 3.91%            | 1.00           | 0.23            | 0.12           | 0.00             |
| Intergenic/Unannotated | 234,312,422  | 174,285,472   | 171,476,950  | 39,291,066     | 12.44%         | 11.90%          | 11.26%         | 2.68%            | 0.62           | 1.00            | 2.22           | 1.00             |
| Intronic               | 105,992,896  | 185,434,227   | 158,008,365  | 46,913,468     | 14.41%         | 15.34%          | 16.37%         | 3.88%            | 0.00           | 0.00            | 0.00           | 0.02             |
| Long-noncoding RNAs    | NA           | 143,813,362   | 93,661,007   | 36,855,634     | NA             | 15.32%          | 16.38%         | 3.93%            | NA             | 0.00            | 0.01           | 0.02             |
| Noncoding Gene         | NA           | 671,317       | 1,582,200    | 168,895        | NA             | 15.75%          | 17.48%         | 3.96%            | NA             | 0.12            | 0.48           | 0.04             |
| Pseudogene             | 38,541       | 3,739,955     | 1,495,032    | 829,961        | 5.63%          | 6.49%           | 5.48%          | 1.44%            | **2.75 (-)**           | 2.58            | **4.72 (-)**           | 2.02             |
| Small RNAs             | 55,704       | 113,518       | 86,588       | 25,866         | 13.07%         | 11.34%          | 12.12%         | 2.58%            | 0.42           | 1.16            | 1.84           | 1.08             |
| Three Prime UTR        | 1,426,542    | 8,472,688     | 6,976,396    | 2,841,301      | 19.15%         | 19.27%          | 19.42%         | 6.46%            | 1.49           | 1.15            | 1.32           | 2.09             |


**Results of Z-Score analysis of SISRS site selection**  
**Note:** Bold numbers indicate significant results  

| Locus Type             | Pecora Count | Primate Count | Rodent Count | Combined Count | Pecora Percent | Primate Percent | Rodent Percent | Combined Percent | Pecora Z-Score | Primate Z-Score | Rodent Z-Score | Combined Z-Score |
|------------------------|--------------|---------------|--------------|----------------|----------------|-----------------|----------------|------------------|----------------|-----------------|----------------|------------------|
| CDS                    | 156,346      | 94,306        | 284,903      | 80,624         | 2.45%          | 1.18%           | 4.18%          | 2.47%            | 0.00           | 1.30            | **21.13 (+)**          | **8.16 (+)**             |
| Five Prime UTR         | 5,322        | 24,173        | 19,157       | 4,404          | 1.94%          | 1.60%           | 1.61%          | 1.09%            | 1.00           | 0.70            | **4.60 (+)**           | 2.57             |
| Intergenic/Unannotated | 6,625,459    | 4,471,169     | 1,258,262    | 80,436         | 2.83%          | 2.57%           | 0.73%          | 0.20%            | 0.73           | 0.68            | 1.00           | 1.00             |
| Intronic               | 3,253,771    | 5,481,429     | 1,289,450    | 96,267         | 3.07%          | 2.96%           | 0.82%          | 0.21%            | 1.20           | 1.24            | 0.47           | 1.00             |
| Long-noncoding RNAs    | NA           | 4,119,353     | 886,271      | 127,960        | NA             | 2.86%           | 0.95%          | 0.35%            | NA             | 1.11            | 0.36           | 0.42             |
| Noncoding Gene         | NA           | 18,708        | 14,074       | 763            | NA             | 2.79%           | 0.89%          | 0.45%            | NA             | 1.00            | 0.00           | 0.00             |
| Pseudogene             | 318          | 64,884        | 7,475        | 1,328          | 0.83%          | 1.73%           | 0.50%          | 0.16%            | **3.17 (-)**          | 0.51            | 2.50           | 1.18             |
| Small RNAs             | 508          | 1,171         | 690          | 139            | 0.91%          | 1.03%           | 0.80%          | 0.54%            | **3.00 (-)**           | 1.52            | 0.59           | 0.35             |
| Three Prime UTR        | 38,788       | 177,037       | 128,916      | 26,921         | 2.72%          | 2.09%           | 1.85%          | 0.95%            | 0.52           | 0.00            | **6.15 (+)**           | 2.01             |

**Results of Z-Score analysis of proportion of sites carrying phylogenetic signal**  
**Note:** Bold numbers indicate significant results  

| Locus Type             | Pecora Count | Primate Count | Rodent Count | Combined Count | Pecora Percent | Primate Percent | Rodent Percent | Combined Percent | Pecora Z-Score | Primate Z-Score | Rodent Z-Score | Combined Z-Score |
|------------------------|--------------|---------------|--------------|----------------|----------------|-----------------|----------------|------------------|----------------|-----------------|----------------|------------------|
| CDS                    | 124,625      | 83,208        | 198,573      | 45,606         | 79.71%         | 88.23%          | 69.70%         | 56.57%           | **2.98 (-)**           | **11.78 (-)**            | **16.66 (-)**           | **4.70 (-)**              |
| Five Prime UTR         | 4,557        | 21,866        | 15,169       | 2,843          | 85.63%         | 90.46%          | 79.18%         | 64.55%           | 1.00           | 1.69            | 0.46           | 1.82             |
| Intergenic/Unannotated | 5,601,548    | 4,024,601     | 1,000,114    | 58,153         | 84.55%         | 90.01%          | 79.48%         | 72.30%           | 0.27           | 1.00            | 1.00           | 0.98             |
| Intronic               | 2,737,659    | 4,940,510     | 1,021,822    | 68,875         | 84.14%         | 90.13%          | 79.24%         | 71.55%           | 0.00           | 0.28            | 0.57           | 0.71             |
| Long-noncoding RNAs    | NA           | 3,714,726     | 693,810      | 86,601         | NA             | 90.18%          | 78.28%         | 67.68%           | NA             | 0.00            | 1.17           | 0.69             |
| Noncoding Gene         | NA           | 16,922        | 11,082       | 552            | NA             | 90.45%          | 78.74%         | 72.35%           | NA             | 1.67            | 0.34           | 1.00             |
| Pseudogene             | 255          | 58,586        | 5,900        | 924            | 80.19%         | 90.29%          | 78.93%         | 69.58%           | 2.65           | 0.70            | 0.00           | 0.00             |
| Small RNAs             | 412          | 1,047         | 549          | 105            | 81.10%         | 89.41%          | 79.57%         | 75.54%           | 2.04           | **4.64 (-)**             | 1.15           | 2.15             |
| Three Prime UTR        | 32,916       | 159,884       | 100,727      | 17,423         | 84.86%         | 90.31%          | 78.13%         | 64.72%           | 0.49           | 0.81            | 1.44           | 1.76             |

### 14) Testing proportional signal changes over evolutionary time  

We calculated the proportion of phylogenetic signal from each locus type for each dated node in the reference topology.  

For example, of the sites providing phylogenetic signal that defines the split of (humans + chimps + bonobos) from other great apes, here are the annotation breakdowns:  

1. 47.5% Intronic
2. 38.9% Intergenic
3. 35.7% lncRNA
4. 1.59% 3'UTR
5. 0.76% CDS
6. 0.55% Pseudogene
7. 0.21% 5'UTR
8. 0.17% Noncoding genes
9. 0.01% smRNA

**Note:** Percentages add up to >100% due to sites having more than one annotation (e.g. lncRNA within introns)  

Calculating these percentages for each node and running linear models against node age, we were able to determine whether the signal from different locus types were broadly informative, or rather, if they provided disproportionate signal to older or younger nodes.  

**Results of linear models testing for time effects on signal distribution**  
**Note:** Bold numbers indicate significant results

| Dataset  | Annotation    | Change in Percent Split Support per MY | StdErr   | t_value | p_value  | Adj_R_Sq |
|----------|---------------|----------------------------------------|----------|---------|----------|----------|
| **Pecora**   | **CDS**           | 2.38E-02                               | 4.76E-03 | 5.00    | 2.46E-03 | 0.77     |
| Pecora   | fivePrimeUTR  | 3.14E-04                               | 2.50E-04 | 1.26    | 2.55E-01 | 0.08     |
| Pecora   | intergenic    | -2.54E-02                              | 2.08E-02 | -1.22   | 2.68E-01 | 0.07     |
| Pecora   | intronic      | 8.96E-04                               | 1.95E-02 | 0.05    | 9.65E-01 | -0.17    |
| Pecora   | pseudogene    | 7.14E-05                               | 2.66E-05 | 2.68    | 3.65E-02 | 0.47     |
| Pecora   | smRNA         | -7.84E-05                              | 6.10E-05 | -1.29   | 2.46E-01 | 0.09     |
| Pecora   | threePrimeUTR | 8.11E-04                               | 6.32E-04 | 1.28    | 2.47E-01 | 0.08     |
| Primates | CDS           | -7.74E-03                              | 4.76E-03 | -1.63   | 1.55E-01 | 0.19     |
| Primates | fivePrimeUTR  | 4.57E-04                               | 7.27E-04 | 0.63    | 5.53E-01 | -0.09    |
| Primates | intergenic    | -6.47E-02                              | 3.25E-02 | -1.99   | 9.38E-02 | 0.30     |
| Primates | intronic      | 7.46E-02                               | 3.39E-02 | 2.20    | 7.00E-02 | 0.35     |
| Primates | lncRNA        | 4.09E-02                               | 1.88E-02 | 2.18    | 7.20E-02 | 0.35     |
| Primates | ncGenes       | -3.08E-04                              | 5.11E-04 | -0.60   | 5.69E-01 | -0.10    |
| Primates | pseudogene    | -1.25E-03                              | 7.46E-04 | -1.68   | 1.45E-01 | 0.21     |
| Primates | smRNA         | 1.25E-05                               | 9.88E-05 | 0.13    | 9.03E-01 | -0.16    |
| Primates | threePrimeUTR | -2.14E-03                              | 4.46E-03 | -0.48   | 6.49E-01 | -0.12    |
| **Rodents**  | **CDS**           | 1.68E-01                               | 3.61E-02 | 4.66    | 3.48E-03 | 0.75     |
| Rodents  | fivePrimeUTR  | 2.71E-03                               | 2.93E-03 | 0.93    | 3.90E-01 | -0.02    |
| Rodents  | intergenic    | -3.02E-02                              | 2.22E-02 | -1.36   | 2.22E-01 | 0.11     |
| **Rodents**  | **intronic**      | -1.24E-01                              | 1.90E-02 | -6.55   | 6.04E-04 | 0.86     |
| Rodents  | lncRNA        | -1.45E-02                              | 9.59E-03 | -1.51   | 1.82E-01 | 0.15     |
| Rodents  | ncGenes       | -4.80E-04                              | 8.42E-04 | -0.57   | 5.89E-01 | -0.11    |
| Rodents  | pseudogene    | 4.92E-04                               | 1.09E-03 | 0.45    | 6.67E-01 | -0.13    |
| Rodents  | smRNA         | -7.12E-05                              | 2.33E-04 | -0.31   | 7.70E-01 | -0.15    |
| Rodents  | threePrimeUTR | 1.01E-02                               | 4.97E-03 | 2.04    | 8.77E-02 | 0.31     |
| **Combined** | **CDS**           | 2.37E-01                               | 7.01E-02 | 3.38    | 2.00E-03 | 0.25     |
| Combined | fivePrimeUTR  | 3.80E-03                               | 5.09E-03 | 0.75    | 4.62E-01 | -0.01    |
| Combined | intergenic    | -8.15E-02                              | 5.21E-02 | -1.56   | 1.28E-01 | 0.04     |
| **Combined** | **intronic**      | -8.49E-02                              | 2.51E-02 | -3.38   | 2.00E-03 | 0.25     |
| Combined | lncRNA        | 1.67E-02                               | 2.31E-02 | 0.72    | 4.75E-01 | -0.02    |
| Combined | ncGenes       | -5.64E-04                              | 1.63E-03 | -0.35   | 7.32E-01 | -0.03    |
| Combined | pseudogene    | -1.62E-03                              | 1.40E-03 | -1.16   | 2.54E-01 | 0.01     |
| Combined | smRNA         | -2.13E-04                              | 5.73E-04 | -0.37   | 7.12E-01 | -0.03    |
| Combined | threePrimeUTR | 2.84E-02                               | 2.34E-02 | 1.22    | 2.33E-01 | 0.02     |
