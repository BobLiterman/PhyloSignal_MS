
#!/bin/sh
bowtie2 -p 20 -N 1 --local -x /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/Composite_Genome/contigs -U /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/Reads/TrimReads/PapCyn/PapCyn_SRR1513473_Trim_1.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/Reads/TrimReads/PapCyn/PapCyn_SRR1699449_Trim_1.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/Reads/TrimReads/PapCyn/PapCyn_SRR1699450_Trim_1.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/Reads/TrimReads/PapCyn/PapCyn_SRR1513473_Trim_2.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/Reads/TrimReads/PapCyn/PapCyn_SRR1699449_Trim_2.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/Reads/TrimReads/PapCyn/PapCyn_SRR1699450_Trim_2.fastq.gz | samtools view -Su -@ 20 -F 4 - | samtools sort -@ 20 - -o /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/PapCyn/PapCyn_Temp.bam

samtools view -@ 20 -H /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/PapCyn/PapCyn_Temp.bam > /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/PapCyn/PapCyn_Header.sam

samtools view -@ 20 /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/PapCyn/PapCyn_Temp.bam | grep -v "XS:" | cat /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/PapCyn/PapCyn_Header.sam - | samtools view -@ 20 -b - > /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/PapCyn/PapCyn.bam

rm /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/PapCyn/PapCyn_Temp.bam
rm /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/PapCyn/PapCyn_Header.sam

samtools mpileup -f /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/Composite_Genome/contigs.fa /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/PapCyn/PapCyn.bam > /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/PapCyn/PapCyn.pileups

python /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/scripts/specific_genome.py /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/PapCyn /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/Composite_Genome/contigs.fa

samtools faidx /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/PapCyn/contigs.fa
bowtie2-build /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/PapCyn/contigs.fa /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/PapCyn/contigs -p 20

bowtie2 -p 20 -N 1 --local -x /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/PapCyn/contigs -U /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/Reads/TrimReads/PapCyn/PapCyn_SRR1513473_Trim_1.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/Reads/TrimReads/PapCyn/PapCyn_SRR1699449_Trim_1.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/Reads/TrimReads/PapCyn/PapCyn_SRR1699450_Trim_1.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/Reads/TrimReads/PapCyn/PapCyn_SRR1513473_Trim_2.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/Reads/TrimReads/PapCyn/PapCyn_SRR1699449_Trim_2.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/Reads/TrimReads/PapCyn/PapCyn_SRR1699450_Trim_2.fastq.gz | samtools view -Su -@ 20 -F 4 - | samtools sort -@ 20 - -o /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/PapCyn/PapCyn_Temp.bam

samtools view -@ 20 -H /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/PapCyn/PapCyn_Temp.bam > /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/PapCyn/PapCyn_Header.sam
samtools view -@ 20 /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/PapCyn/PapCyn_Temp.bam | grep -v "XS:" | cat /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/PapCyn/PapCyn_Header.sam - | samtools view -@ 20 -b - > /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/PapCyn/PapCyn.bam

rm /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/PapCyn/PapCyn_Temp.bam
rm /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/PapCyn/PapCyn_Header.sam

samtools index /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/PapCyn/PapCyn.bam

samtools mpileup -f /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/Composite_Genome/contigs.fa /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/PapCyn/PapCyn.bam > /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/PapCyn/PapCyn.pileups

python /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/scripts/get_pruned_dict.py /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/PapCyn /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/Composite_Genome 3 1.0

