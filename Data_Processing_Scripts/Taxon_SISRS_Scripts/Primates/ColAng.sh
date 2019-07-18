
#!/bin/sh
bowtie2 -p 20 -N 1 --local -x /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/Composite_Genome/contigs -U /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/Reads/TrimReads/ColAng/ColAng_SRR1687491_Trim_1.fastq.gz,/net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/Reads/TrimReads/ColAng/ColAng_SRR1687495_Trim_1.fastq.gz,/net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/Reads/TrimReads/ColAng/ColAng_SRR1687501_Trim_1.fastq.gz,/net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/Reads/TrimReads/ColAng/ColAng_SRR1687491_Trim_2.fastq.gz,/net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/Reads/TrimReads/ColAng/ColAng_SRR1687495_Trim_2.fastq.gz,/net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/Reads/TrimReads/ColAng/ColAng_SRR1687501_Trim_2.fastq.gz | samtools view -Su -@ 20 -F 4 - | samtools sort -@ 20 - -o /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/ColAng/ColAng_Temp.bam

samtools view -@ 20 -H /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/ColAng/ColAng_Temp.bam > /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/ColAng/ColAng_Header.sam

samtools view -@ 20 /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/ColAng/ColAng_Temp.bam | grep -v "XS:" | cat /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/ColAng/ColAng_Header.sam - | samtools view -@ 20 -b - > /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/ColAng/ColAng.bam

rm /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/ColAng/ColAng_Temp.bam
rm /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/ColAng/ColAng_Header.sam

samtools mpileup -f /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/Composite_Genome/contigs.fa /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/ColAng/ColAng.bam > /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/ColAng/ColAng.pileups

python /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/scripts/specific_genome.py /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/ColAng /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/Composite_Genome/contigs.fa

samtools faidx /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/ColAng/contigs.fa
bowtie2-build /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/ColAng/contigs.fa /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/ColAng/contigs -p 20

bowtie2 -p 20 -N 1 --local -x /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/ColAng/contigs -U /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/Reads/TrimReads/ColAng/ColAng_SRR1687491_Trim_1.fastq.gz,/net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/Reads/TrimReads/ColAng/ColAng_SRR1687495_Trim_1.fastq.gz,/net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/Reads/TrimReads/ColAng/ColAng_SRR1687501_Trim_1.fastq.gz,/net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/Reads/TrimReads/ColAng/ColAng_SRR1687491_Trim_2.fastq.gz,/net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/Reads/TrimReads/ColAng/ColAng_SRR1687495_Trim_2.fastq.gz,/net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/Reads/TrimReads/ColAng/ColAng_SRR1687501_Trim_2.fastq.gz | samtools view -Su -@ 20 -F 4 - | samtools sort -@ 20 - -o /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/ColAng/ColAng_Temp.bam

samtools view -@ 20 -H /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/ColAng/ColAng_Temp.bam > /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/ColAng/ColAng_Header.sam
samtools view -@ 20 /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/ColAng/ColAng_Temp.bam | grep -v "XS:" | cat /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/ColAng/ColAng_Header.sam - | samtools view -@ 20 -b - > /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/ColAng/ColAng.bam

rm /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/ColAng/ColAng_Temp.bam
rm /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/ColAng/ColAng_Header.sam

samtools index /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/ColAng/ColAng.bam

samtools mpileup -f /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/Composite_Genome/contigs.fa /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/ColAng/ColAng.bam > /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/ColAng/ColAng.pileups

python /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/scripts/get_pruned_dict.py /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/ColAng /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/Composite_Genome 3 1.0

