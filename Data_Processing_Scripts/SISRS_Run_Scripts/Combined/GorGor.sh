
#!/bin/sh
bowtie2 -p 20 -N 1 --local -x /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/Composite_Genome/contigs -U /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/Reads/TrimReads/GorGor/GorGor_SRR748174_Trim_1.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/Reads/TrimReads/GorGor/GorGor_SRR748178_Trim_1.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/Reads/TrimReads/GorGor/GorGor_SRR748174_Trim_2.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/Reads/TrimReads/GorGor/GorGor_SRR748178_Trim_2.fastq.gz | samtools view -Su -@ 20 -F 4 - | samtools sort -@ 20 - -o /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/GorGor/GorGor_Temp.bam

samtools view -@ 20 -H /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/GorGor/GorGor_Temp.bam > /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/GorGor/GorGor_Header.sam

samtools view -@ 20 /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/GorGor/GorGor_Temp.bam | grep -v "XS:" | cat /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/GorGor/GorGor_Header.sam - | samtools view -@ 20 -b - > /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/GorGor/GorGor.bam

rm /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/GorGor/GorGor_Temp.bam
rm /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/GorGor/GorGor_Header.sam

samtools mpileup -f /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/Composite_Genome/contigs.fa /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/GorGor/GorGor.bam > /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/GorGor/GorGor.pileups

python /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/scripts/specific_genome.py /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/GorGor /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/Composite_Genome/contigs.fa

samtools faidx /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/GorGor/contigs.fa
bowtie2-build /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/GorGor/contigs.fa /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/GorGor/contigs -p 20

bowtie2 -p 20 -N 1 --local -x /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/GorGor/contigs -U /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/Reads/TrimReads/GorGor/GorGor_SRR748174_Trim_1.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/Reads/TrimReads/GorGor/GorGor_SRR748178_Trim_1.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/Reads/TrimReads/GorGor/GorGor_SRR748174_Trim_2.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/Reads/TrimReads/GorGor/GorGor_SRR748178_Trim_2.fastq.gz | samtools view -Su -@ 20 -F 4 - | samtools sort -@ 20 - -o /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/GorGor/GorGor_Temp.bam

samtools view -@ 20 -H /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/GorGor/GorGor_Temp.bam > /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/GorGor/GorGor_Header.sam
samtools view -@ 20 /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/GorGor/GorGor_Temp.bam | grep -v "XS:" | cat /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/GorGor/GorGor_Header.sam - | samtools view -@ 20 -b - > /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/GorGor/GorGor.bam

rm /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/GorGor/GorGor_Temp.bam
rm /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/GorGor/GorGor_Header.sam

samtools index /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/GorGor/GorGor.bam

samtools mpileup -f /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/Composite_Genome/contigs.fa /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/GorGor/GorGor.bam > /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/GorGor/GorGor.pileups

python /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/scripts/get_pruned_dict.py /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/GorGor /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Combined/SISRS_Run/Composite_Genome 3 1.0

