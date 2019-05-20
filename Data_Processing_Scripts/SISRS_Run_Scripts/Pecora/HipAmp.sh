
#!/bin/sh
bowtie2 -p 20 -N 1 --local -x /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Cetartiodactyla/SISRS_Run/Composite_Genome/contigs -U /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Cetartiodactyla/Reads/TrimReads/HipAmp/HipAmp_SRR5663646_Trim_1.fastq.gz,/net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Cetartiodactyla/Reads/TrimReads/HipAmp/HipAmp_SRR5663649_Trim_1.fastq.gz,/net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Cetartiodactyla/Reads/TrimReads/HipAmp/HipAmp_SRR5663646_Trim_2.fastq.gz,/net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Cetartiodactyla/Reads/TrimReads/HipAmp/HipAmp_SRR5663649_Trim_2.fastq.gz | samtools view -Su -@ 20 -F 4 - | samtools sort -@ 20 - -o /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Cetartiodactyla/SISRS_Run/HipAmp/HipAmp_Temp.bam

samtools view -@ 20 -H /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Cetartiodactyla/SISRS_Run/HipAmp/HipAmp_Temp.bam > /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Cetartiodactyla/SISRS_Run/HipAmp/HipAmp_Header.sam

samtools view -@ 20 /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Cetartiodactyla/SISRS_Run/HipAmp/HipAmp_Temp.bam | grep -v "XS:" | cat /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Cetartiodactyla/SISRS_Run/HipAmp/HipAmp_Header.sam - | samtools view -@ 20 -b - > /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Cetartiodactyla/SISRS_Run/HipAmp/HipAmp.bam

rm /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Cetartiodactyla/SISRS_Run/HipAmp/HipAmp_Temp.bam
rm /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Cetartiodactyla/SISRS_Run/HipAmp/HipAmp_Header.sam

samtools mpileup -f /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Cetartiodactyla/SISRS_Run/Composite_Genome/contigs.fa /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Cetartiodactyla/SISRS_Run/HipAmp/HipAmp.bam > /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Cetartiodactyla/SISRS_Run/HipAmp/HipAmp.pileups

python /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Cetartiodactyla/scripts/specific_genome.py /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Cetartiodactyla/SISRS_Run/HipAmp /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Cetartiodactyla/SISRS_Run/Composite_Genome/contigs.fa

samtools faidx /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Cetartiodactyla/SISRS_Run/HipAmp/contigs.fa
bowtie2-build /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Cetartiodactyla/SISRS_Run/HipAmp/contigs.fa /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Cetartiodactyla/SISRS_Run/HipAmp/contigs -p 20

bowtie2 -p 20 -N 1 --local -x /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Cetartiodactyla/SISRS_Run/HipAmp/contigs -U /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Cetartiodactyla/Reads/TrimReads/HipAmp/HipAmp_SRR5663646_Trim_1.fastq.gz,/net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Cetartiodactyla/Reads/TrimReads/HipAmp/HipAmp_SRR5663649_Trim_1.fastq.gz,/net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Cetartiodactyla/Reads/TrimReads/HipAmp/HipAmp_SRR5663646_Trim_2.fastq.gz,/net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Cetartiodactyla/Reads/TrimReads/HipAmp/HipAmp_SRR5663649_Trim_2.fastq.gz | samtools view -Su -@ 20 -F 4 - | samtools sort -@ 20 - -o /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Cetartiodactyla/SISRS_Run/HipAmp/HipAmp_Temp.bam

samtools view -@ 20 -H /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Cetartiodactyla/SISRS_Run/HipAmp/HipAmp_Temp.bam > /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Cetartiodactyla/SISRS_Run/HipAmp/HipAmp_Header.sam
samtools view -@ 20 /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Cetartiodactyla/SISRS_Run/HipAmp/HipAmp_Temp.bam | grep -v "XS:" | cat /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Cetartiodactyla/SISRS_Run/HipAmp/HipAmp_Header.sam - | samtools view -@ 20 -b - > /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Cetartiodactyla/SISRS_Run/HipAmp/HipAmp.bam

rm /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Cetartiodactyla/SISRS_Run/HipAmp/HipAmp_Temp.bam
rm /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Cetartiodactyla/SISRS_Run/HipAmp/HipAmp_Header.sam

samtools index /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Cetartiodactyla/SISRS_Run/HipAmp/HipAmp.bam

samtools mpileup -f /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Cetartiodactyla/SISRS_Run/Composite_Genome/contigs.fa /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Cetartiodactyla/SISRS_Run/HipAmp/HipAmp.bam > /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Cetartiodactyla/SISRS_Run/HipAmp/HipAmp.pileups

python /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Cetartiodactyla/scripts/get_pruned_dict.py /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Cetartiodactyla/SISRS_Run/HipAmp /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Cetartiodactyla/SISRS_Run/Composite_Genome 3 1.0

