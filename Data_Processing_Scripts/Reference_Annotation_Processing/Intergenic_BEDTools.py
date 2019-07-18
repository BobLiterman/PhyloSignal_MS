#!/usr/bin/env python3

# Argument 1: Chromsome BED (0 - Chrom Length)
# Argument 2: Merged BED file of all other annotations
# Argument 3: Output file for Intergenic
# Script produces Unannotated/Intergenic BED file: Chrom - All Annotations

import sys
import os
import pandas as pd
from pybedtools import *
from collections import Counter

#Read in chrom + genic datasets
chromDF = pd.read_csv(sys.argv[1],sep="\t",header=None)
chromDF.columns = ['chrom', 'start', 'end', 'name', 'score', 'strand']
genicDF = pd.read_csv(sys.argv[2],sep="\t",header=None)
genicDF.columns = ['chrom', 'start', 'end']

#Sort chrom file, and sort/merge gene file
chromBED = BedTool.from_dataframe(chromDF).sort()
genicBED = BedTool.from_dataframe(genicDF).sort()

#Subtract Chrom - Genic (Genes + Pseudogenes + ncRNA + lncRNA) to get Intergenic
intergenicDF = BedTool.subtract(chromBED,genicBED).sort().to_dataframe()

#Count number of intergenic regions by chrom
intCount = dict(Counter(intergenicDF['chrom']))

#Create labels as "Intergenic_Chr<chr>.<#>" ie) Intergenic_Chr1.1 is the first intergenic region on Chr1 
labelList = []
for chrom in intCount.keys():
    label1 = 'Intergenic_Chr' + str(chrom)
    for i in range(1,(intCount[str(chrom)]+1)):
        labelList.append(label1+'.'+str(i))
intergenicDF['name'] = labelList
intergenicDF.to_csv(sys.argv[3],sep='\t',header=False,index=False)
