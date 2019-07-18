
#!/bin/sh
bowtie2 -p 20 -N 1 --local -x /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/Composite_Genome/contigs -U /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/Reads/TrimReads/MerUng/MerUng_SRR7041744_Trim_1.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/Reads/TrimReads/MerUng/MerUng_SRR7041746_Trim_1.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/Reads/TrimReads/MerUng/MerUng_SRR7041747_Trim_1.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/Reads/TrimReads/MerUng/MerUng_SRR7041744_Trim_2.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/Reads/TrimReads/MerUng/MerUng_SRR7041746_Trim_2.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/Reads/TrimReads/MerUng/MerUng_SRR7041747_Trim_2.fastq.gz | samtools view -Su -@ 20 -F 4 - | samtools sort -@ 20 - -o /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MerUng/MerUng_Temp.bam

samtools view -@ 20 -H /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MerUng/MerUng_Temp.bam > /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MerUng/MerUng_Header.sam

samtools view -@ 20 /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MerUng/MerUng_Temp.bam | grep -v "XS:" | cat /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MerUng/MerUng_Header.sam - | samtools view -@ 20 -b - > /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MerUng/MerUng.bam

rm /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MerUng/MerUng_Temp.bam
rm /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MerUng/MerUng_Header.sam

samtools mpileup -f /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/Composite_Genome/contigs.fa /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MerUng/MerUng.bam > /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MerUng/MerUng.pileups

python /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/scripts/specific_genome.py /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MerUng /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/Composite_Genome/contigs.fa

samtools faidx /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MerUng/contigs.fa
bowtie2-build /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MerUng/contigs.fa /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MerUng/contigs -p 20

bowtie2 -p 20 -N 1 --local -x /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MerUng/contigs -U /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/Reads/TrimReads/MerUng/MerUng_SRR7041744_Trim_1.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/Reads/TrimReads/MerUng/MerUng_SRR7041746_Trim_1.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/Reads/TrimReads/MerUng/MerUng_SRR7041747_Trim_1.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/Reads/TrimReads/MerUng/MerUng_SRR7041744_Trim_2.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/Reads/TrimReads/MerUng/MerUng_SRR7041746_Trim_2.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/Reads/TrimReads/MerUng/MerUng_SRR7041747_Trim_2.fastq.gz | samtools view -Su -@ 20 -F 4 - | samtools sort -@ 20 - -o /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MerUng/MerUng_Temp.bam

samtools view -@ 20 -H /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MerUng/MerUng_Temp.bam > /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MerUng/MerUng_Header.sam
samtools view -@ 20 /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MerUng/MerUng_Temp.bam | grep -v "XS:" | cat /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MerUng/MerUng_Header.sam - | samtools view -@ 20 -b - > /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MerUng/MerUng.bam

rm /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MerUng/MerUng_Temp.bam
rm /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MerUng/MerUng_Header.sam

samtools index /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MerUng/MerUng.bam

samtools mpileup -f /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/Composite_Genome/contigs.fa /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MerUng/MerUng.bam > /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MerUng/MerUng.pileups

python /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/scripts/get_pruned_dict.py /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MerUng /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/Composite_Genome 3 1.0

