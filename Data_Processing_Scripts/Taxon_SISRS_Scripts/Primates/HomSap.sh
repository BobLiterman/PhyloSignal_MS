
#!/bin/sh
bowtie2 -p 20 -N 1 --local -x /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/Composite_Genome/contigs -U /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/Reads/TrimReads/HomSap/HomSap_ERR229778_Trim_1.fastq.gz,/net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/Reads/TrimReads/HomSap/HomSap_ERR229779_Trim_1.fastq.gz,/net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/Reads/TrimReads/HomSap/HomSap_ERR229780_Trim_1.fastq.gz,/net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/Reads/TrimReads/HomSap/HomSap_ERR229784_Trim_1.fastq.gz,/net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/Reads/TrimReads/HomSap/HomSap_ERR229778_Trim_2.fastq.gz,/net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/Reads/TrimReads/HomSap/HomSap_ERR229779_Trim_2.fastq.gz,/net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/Reads/TrimReads/HomSap/HomSap_ERR229780_Trim_2.fastq.gz,/net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/Reads/TrimReads/HomSap/HomSap_ERR229784_Trim_2.fastq.gz | samtools view -Su -@ 20 -F 4 - | samtools sort -@ 20 - -o /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/HomSap/HomSap_Temp.bam

samtools view -@ 20 -H /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/HomSap/HomSap_Temp.bam > /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/HomSap/HomSap_Header.sam

samtools view -@ 20 /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/HomSap/HomSap_Temp.bam | grep -v "XS:" | cat /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/HomSap/HomSap_Header.sam - | samtools view -@ 20 -b - > /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/HomSap/HomSap.bam

rm /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/HomSap/HomSap_Temp.bam
rm /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/HomSap/HomSap_Header.sam

samtools mpileup -f /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/Composite_Genome/contigs.fa /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/HomSap/HomSap.bam > /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/HomSap/HomSap.pileups

python /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/scripts/specific_genome.py /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/HomSap /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/Composite_Genome/contigs.fa

samtools faidx /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/HomSap/contigs.fa
bowtie2-build /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/HomSap/contigs.fa /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/HomSap/contigs -p 20

bowtie2 -p 20 -N 1 --local -x /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/HomSap/contigs -U /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/Reads/TrimReads/HomSap/HomSap_ERR229778_Trim_1.fastq.gz,/net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/Reads/TrimReads/HomSap/HomSap_ERR229779_Trim_1.fastq.gz,/net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/Reads/TrimReads/HomSap/HomSap_ERR229780_Trim_1.fastq.gz,/net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/Reads/TrimReads/HomSap/HomSap_ERR229784_Trim_1.fastq.gz,/net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/Reads/TrimReads/HomSap/HomSap_ERR229778_Trim_2.fastq.gz,/net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/Reads/TrimReads/HomSap/HomSap_ERR229779_Trim_2.fastq.gz,/net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/Reads/TrimReads/HomSap/HomSap_ERR229780_Trim_2.fastq.gz,/net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/Reads/TrimReads/HomSap/HomSap_ERR229784_Trim_2.fastq.gz | samtools view -Su -@ 20 -F 4 - | samtools sort -@ 20 - -o /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/HomSap/HomSap_Temp.bam

samtools view -@ 20 -H /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/HomSap/HomSap_Temp.bam > /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/HomSap/HomSap_Header.sam
samtools view -@ 20 /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/HomSap/HomSap_Temp.bam | grep -v "XS:" | cat /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/HomSap/HomSap_Header.sam - | samtools view -@ 20 -b - > /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/HomSap/HomSap.bam

rm /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/HomSap/HomSap_Temp.bam
rm /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/HomSap/HomSap_Header.sam

samtools index /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/HomSap/HomSap.bam

samtools mpileup -f /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/Composite_Genome/contigs.fa /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/HomSap/HomSap.bam > /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/HomSap/HomSap.pileups

python /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/scripts/get_pruned_dict.py /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/HomSap /net/fs03.cluster.com/data3/schwartzlab/bob/Rerun_Mammals/Primates/SISRS_Run/Composite_Genome 3 1.0

