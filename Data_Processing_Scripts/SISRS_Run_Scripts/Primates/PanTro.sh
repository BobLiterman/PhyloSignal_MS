
#!/bin/sh
bowtie2 -p 20 -N 1 --local -x /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/Composite_Genome/contigs -U /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/Reads/TrimReads/PanTro/PanTro_SRR748063_Trim_1.fastq.gz,/net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/Reads/TrimReads/PanTro/PanTro_SRR748064_Trim_1.fastq.gz,/net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/Reads/TrimReads/PanTro/PanTro_SRR748065_Trim_1.fastq.gz,/net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/Reads/TrimReads/PanTro/PanTro_SRR748063_Trim_2.fastq.gz,/net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/Reads/TrimReads/PanTro/PanTro_SRR748064_Trim_2.fastq.gz,/net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/Reads/TrimReads/PanTro/PanTro_SRR748065_Trim_2.fastq.gz | samtools view -Su -@ 20 -F 4 - | samtools sort -@ 20 - -o /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/PanTro/PanTro_Temp.bam

samtools view -@ 20 -H /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/PanTro/PanTro_Temp.bam > /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/PanTro/PanTro_Header.sam

samtools view -@ 20 /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/PanTro/PanTro_Temp.bam | grep -v "XS:" | cat /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/PanTro/PanTro_Header.sam - | samtools view -@ 20 -b - > /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/PanTro/PanTro.bam

rm /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/PanTro/PanTro_Temp.bam
rm /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/PanTro/PanTro_Header.sam

samtools mpileup -f /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/Composite_Genome/contigs.fa /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/PanTro/PanTro.bam > /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/PanTro/PanTro.pileups

python /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/scripts/specific_genome.py /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/PanTro /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/Composite_Genome/contigs.fa

samtools faidx /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/PanTro/contigs.fa
bowtie2-build /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/PanTro/contigs.fa /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/PanTro/contigs -p 20

bowtie2 -p 20 -N 1 --local -x /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/PanTro/contigs -U /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/Reads/TrimReads/PanTro/PanTro_SRR748063_Trim_1.fastq.gz,/net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/Reads/TrimReads/PanTro/PanTro_SRR748064_Trim_1.fastq.gz,/net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/Reads/TrimReads/PanTro/PanTro_SRR748065_Trim_1.fastq.gz,/net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/Reads/TrimReads/PanTro/PanTro_SRR748063_Trim_2.fastq.gz,/net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/Reads/TrimReads/PanTro/PanTro_SRR748064_Trim_2.fastq.gz,/net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/Reads/TrimReads/PanTro/PanTro_SRR748065_Trim_2.fastq.gz | samtools view -Su -@ 20 -F 4 - | samtools sort -@ 20 - -o /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/PanTro/PanTro_Temp.bam

samtools view -@ 20 -H /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/PanTro/PanTro_Temp.bam > /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/PanTro/PanTro_Header.sam
samtools view -@ 20 /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/PanTro/PanTro_Temp.bam | grep -v "XS:" | cat /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/PanTro/PanTro_Header.sam - | samtools view -@ 20 -b - > /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/PanTro/PanTro.bam

rm /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/PanTro/PanTro_Temp.bam
rm /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/PanTro/PanTro_Header.sam

samtools index /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/PanTro/PanTro.bam

samtools mpileup -f /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/Composite_Genome/contigs.fa /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/PanTro/PanTro.bam > /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/PanTro/PanTro.pileups

python /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/scripts/get_pruned_dict.py /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/PanTro /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/Composite_Genome 3 1.0

