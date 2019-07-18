#!/usr/bin/env python3

# Argument 1: NonIntronic BED [cat (CDS + UTR) BED files]
# Argument 2: Gene BED File
# Argument 3: Output file for Intronic BED File
# Argument 4: Output file for Noncoding Gene File

import sys
import os
import pandas as pd
from pybedtools import *
from collections import Counter

#Read in Non-Intron data
nonIntronDF = pd.read_csv(sys.argv[1],sep="\t",header=None)
nonIntronDF.columns = ['chrom', 'start', 'end', 'name', 'score', 'strand']
nonIntronDF['name']=nonIntronDF['name'].str.split('_',1,expand=True)[1]
uniqueNonIntron = list(set(nonIntronDF['name']))
nonIntronBED = BedTool.from_dataframe(nonIntronDF).sort()

#Read in Genic data
genicDF = pd.read_csv(sys.argv[2],sep="\t",header=None)
genicDF.columns = ['chrom', 'start', 'end', 'name', 'score', 'strand']
genicDF['name']=genicDF['name'].str.split('_',1,expand=True)[1]
uniqueGene = list(set(genicDF['name']))

#Filter genic data by presence of CDS or UTR (No CDS or UTR ~ Not a 'real' intron)
ncCheck = list(set(uniqueGene) - set(uniqueNonIntron))

if len(ncCheck) > 0:
    no_CDS_UTR_DF = BedTool.from_dataframe(genicDF[~genicDF['name'].isin(uniqueNonIntron)]).sort().to_dataframe()
    no_CDS_UTR_DF.to_csv(sys.argv[4],sep='\t',header=False,index=False)
    genicDF = genicDF[genicDF['name'].isin(uniqueNonIntron)]

genicList = list(set(genicDF['name']))
genicBED = BedTool.from_dataframe(genicDF).sort()

#Subtract Gene - NonIntron to get Intronic
intronDF = pd.DataFrame()
for i in range(0,len(genicList)):
    tempSubtract = BedTool.subtract(genicBED.filter(lambda gene: gene.name == genicList[i]),nonIntronBED.filter(lambda gene: gene.name == genicList[i]).sort().merge(c=[4,5,6],o='distinct'))
    if len(tempSubtract) > 0:
        intronDF = intronDF.append(tempSubtract.to_dataframe(),ignore_index=True)

#Create labels as "Intronic_<gene>.<#>" ie) Intronic_GENE.3 is the third intronic interval for GENE (relative to + strand)
#labelList = []
#intCount = dict(Counter(intronDF['name']))
#for gene in intCount.keys():
#    label1 = 'Intronic_' + str(gene) + "."
#    for i in range(1,(intCount[str(gene)]+1)):
#        labelList.append(label1+str(i))
#intronDF['name'] = labelList

#Name column without numbering
intronDF['name'] = 'Intronic_'+ intronDF['name']

intronDF=BedTool.from_dataframe(intronDF).sort().to_dataframe()
       
intronDF.to_csv(sys.argv[3],sep='\t',header=False,index=False)
