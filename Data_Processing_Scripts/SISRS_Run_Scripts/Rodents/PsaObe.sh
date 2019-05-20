
#!/bin/sh
bowtie2 -p 20 -N 1 --local -x /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/Composite_Genome/contigs -U /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/Reads/TrimReads/PsaObe/PsaObe_SRR5067751_Trim_1.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/Reads/TrimReads/PsaObe/PsaObe_SRR5067752_Trim_1.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/Reads/TrimReads/PsaObe/PsaObe_SRR5067753_Trim_1.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/Reads/TrimReads/PsaObe/PsaObe_SRR5067751_Trim_2.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/Reads/TrimReads/PsaObe/PsaObe_SRR5067752_Trim_2.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/Reads/TrimReads/PsaObe/PsaObe_SRR5067753_Trim_2.fastq.gz | samtools view -Su -@ 20 -F 4 - | samtools sort -@ 20 - -o /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/PsaObe/PsaObe_Temp.bam

samtools view -@ 20 -H /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/PsaObe/PsaObe_Temp.bam > /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/PsaObe/PsaObe_Header.sam

samtools view -@ 20 /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/PsaObe/PsaObe_Temp.bam | grep -v "XS:" | cat /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/PsaObe/PsaObe_Header.sam - | samtools view -@ 20 -b - > /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/PsaObe/PsaObe.bam

rm /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/PsaObe/PsaObe_Temp.bam
rm /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/PsaObe/PsaObe_Header.sam

samtools mpileup -f /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/Composite_Genome/contigs.fa /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/PsaObe/PsaObe.bam > /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/PsaObe/PsaObe.pileups

python /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/scripts/specific_genome.py /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/PsaObe /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/Composite_Genome/contigs.fa

samtools faidx /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/PsaObe/contigs.fa
bowtie2-build /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/PsaObe/contigs.fa /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/PsaObe/contigs -p 20

bowtie2 -p 20 -N 1 --local -x /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/PsaObe/contigs -U /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/Reads/TrimReads/PsaObe/PsaObe_SRR5067751_Trim_1.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/Reads/TrimReads/PsaObe/PsaObe_SRR5067752_Trim_1.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/Reads/TrimReads/PsaObe/PsaObe_SRR5067753_Trim_1.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/Reads/TrimReads/PsaObe/PsaObe_SRR5067751_Trim_2.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/Reads/TrimReads/PsaObe/PsaObe_SRR5067752_Trim_2.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/Reads/TrimReads/PsaObe/PsaObe_SRR5067753_Trim_2.fastq.gz | samtools view -Su -@ 20 -F 4 - | samtools sort -@ 20 - -o /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/PsaObe/PsaObe_Temp.bam

samtools view -@ 20 -H /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/PsaObe/PsaObe_Temp.bam > /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/PsaObe/PsaObe_Header.sam
samtools view -@ 20 /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/PsaObe/PsaObe_Temp.bam | grep -v "XS:" | cat /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/PsaObe/PsaObe_Header.sam - | samtools view -@ 20 -b - > /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/PsaObe/PsaObe.bam

rm /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/PsaObe/PsaObe_Temp.bam
rm /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/PsaObe/PsaObe_Header.sam

samtools index /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/PsaObe/PsaObe.bam

samtools mpileup -f /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/Composite_Genome/contigs.fa /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/PsaObe/PsaObe.bam > /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/PsaObe/PsaObe.pileups

python /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/scripts/get_pruned_dict.py /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/PsaObe /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/Composite_Genome 3 1.0

