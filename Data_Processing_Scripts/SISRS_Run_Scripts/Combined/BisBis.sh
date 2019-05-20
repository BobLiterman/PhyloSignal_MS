
#!/bin/sh
bowtie2 -p 20 -N 1 --local -x /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/Composite_Genome/contigs -U /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/Reads/TrimReads/BisBis/BisBis_SRR3509077_Trim_1.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/Reads/TrimReads/BisBis/BisBis_SRR3509078_Trim_1.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/Reads/TrimReads/BisBis/BisBis_SRR3509077_Trim_2.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/Reads/TrimReads/BisBis/BisBis_SRR3509078_Trim_2.fastq.gz | samtools view -Su -@ 20 -F 4 - | samtools sort -@ 20 - -o /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/BisBis/BisBis_Temp.bam

samtools view -@ 20 -H /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/BisBis/BisBis_Temp.bam > /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/BisBis/BisBis_Header.sam

samtools view -@ 20 /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/BisBis/BisBis_Temp.bam | grep -v "XS:" | cat /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/BisBis/BisBis_Header.sam - | samtools view -@ 20 -b - > /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/BisBis/BisBis.bam

rm /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/BisBis/BisBis_Temp.bam
rm /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/BisBis/BisBis_Header.sam

samtools mpileup -f /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/Composite_Genome/contigs.fa /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/BisBis/BisBis.bam > /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/BisBis/BisBis.pileups

python /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/scripts/specific_genome.py /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/BisBis /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/Composite_Genome/contigs.fa

samtools faidx /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/BisBis/contigs.fa
bowtie2-build /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/BisBis/contigs.fa /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/BisBis/contigs -p 20

bowtie2 -p 20 -N 1 --local -x /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/BisBis/contigs -U /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/Reads/TrimReads/BisBis/BisBis_SRR3509077_Trim_1.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/Reads/TrimReads/BisBis/BisBis_SRR3509078_Trim_1.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/Reads/TrimReads/BisBis/BisBis_SRR3509077_Trim_2.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/Reads/TrimReads/BisBis/BisBis_SRR3509078_Trim_2.fastq.gz | samtools view -Su -@ 20 -F 4 - | samtools sort -@ 20 - -o /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/BisBis/BisBis_Temp.bam

samtools view -@ 20 -H /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/BisBis/BisBis_Temp.bam > /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/BisBis/BisBis_Header.sam
samtools view -@ 20 /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/BisBis/BisBis_Temp.bam | grep -v "XS:" | cat /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/BisBis/BisBis_Header.sam - | samtools view -@ 20 -b - > /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/BisBis/BisBis.bam

rm /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/BisBis/BisBis_Temp.bam
rm /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/BisBis/BisBis_Header.sam

samtools index /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/BisBis/BisBis.bam

samtools mpileup -f /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/Composite_Genome/contigs.fa /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/BisBis/BisBis.bam > /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/BisBis/BisBis.pileups

python /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/scripts/get_pruned_dict.py /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/BisBis /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/Composite_Genome 3 1.0

