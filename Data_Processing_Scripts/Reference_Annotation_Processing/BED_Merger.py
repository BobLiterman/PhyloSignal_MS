#!/usr/bin/env python3
# Argument 1: BED file to be ID-converted and merged
# Argument 2: Path to output BED
# Argument 3: Name of BioMART server (e.g. hsapiens_gene_ensembl)
# Argument 4: Species-specific Ensembl prefix (e.g. ENS; ENSMUS; ENSBTA)
# Input BED format: Chrom,Start,End,Name,Score,Strand, where 'Name' is <AnnotationType>_ENS(G/T/P)

import sys
import pandas as pd
from pybedtools import *
from biomart import BiomartServer
import math
import time

inputBED = pd.read_csv(sys.argv[1],sep='\t',header=None)
inputBED.columns = ['chrom', 'start', 'end', 'name', 'score', 'strand']
inputBED['Clean_Name'] = inputBED['name'].str.split('_',1,expand=True)[1]
inputBED['Cat'] = inputBED['name'].str.split('_',1,expand=True)[0]
inputBED = inputBED.drop('name',axis=1)
transcriptIDs = list(set(list(inputBED['Clean_Name'])))

genePre = str(sys.argv[4])+'G'
transcriptPre = str(sys.argv[4])+'T'
peptidePre = str(sys.argv[4])+'P'


bioMartDict = {genePre:'ensembl_gene_id',transcriptPre:'ensembl_transcript_id',peptidePre:'ensembl_peptide_id'}
ensLabel = bioMartDict[transcriptIDs[0][0:len(genePre)]]

server = BiomartServer( "http://useast.ensembl.org/biomart"  )
mart = server.datasets[str(sys.argv[3])]

idList = []
convertedList = []
chunkSize = 200
chunks = math.ceil(len(transcriptIDs)/chunkSize)

if (chunks == 1):
    response = mart.search({
      'filters': {
          ensLabel: transcriptIDs
      },
      'attributes': [
          ensLabel, 'ensembl_gene_id'
      ]
    })
    for line in response.iter_lines():
        line = line.decode('utf-8')
        idList.append(line.split("\t")[0])
        convertedList.append(line.split("\t")[1])
else:
    for i in range(0,chunks):
        time.sleep(1)
        startLoop = (i*chunkSize)
        numLeft = len(transcriptIDs) - startLoop
        if (numLeft <= chunkSize):
            endLoop = startLoop + numLeft
        else:
            endLoop = startLoop + chunkSize
        response = mart.search({
          'filters': {
              ensLabel: transcriptIDs[startLoop:endLoop]
          },
          'attributes': [
              ensLabel, 'ensembl_gene_id'
          ]
        })
        for line in response.iter_lines():
            line = line.decode('utf-8')
            idList.append(line.split("\t")[0])
            convertedList.append(line.split("\t")[1])

convertDict = dict(zip(idList,convertedList))

noResponse = list(set(inputBED['Clean_Name'].tolist()) - set(idList))

inputBED = inputBED[~inputBED['Clean_Name'].isin(noResponse)]
cleanList = inputBED['Clean_Name'].tolist()


geneList = list(map(lambda x:convertDict[x], cleanList))
inputBED['tempName'] = geneList
inputBED['name'] = inputBED['Cat'].astype(str) + "_" + inputBED['tempName'].astype(str)
cols = ['chrom', 'start', 'end', 'name', 'score', 'strand']
forMerge = inputBED[cols]

uniqueGenes = list(set(forMerge['name'].tolist()))
mergedDF = pd.DataFrame()

for i in range(0,len(uniqueGenes)):
    mergedDF = mergedDF.append(BedTool.from_dataframe(forMerge[forMerge['name']==uniqueGenes[i]]).sort().merge(c=[4,5,6],o='distinct').to_dataframe(),ignore_index=True)

BedTool.from_dataframe(mergedDF).sort().to_dataframe().to_csv(sys.argv[2],sep='\t',header=False,index=False)

