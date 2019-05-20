
#!/bin/sh
bowtie2 -p 20 -N 1 --local -x /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/Composite_Genome/contigs -U /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/Reads/TrimReads/MusCar/MusCar_ERR133991_Trim_1.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/Reads/TrimReads/MusCar/MusCar_ERR133992_Trim_1.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/Reads/TrimReads/MusCar/MusCar_ERR133990_Trim_2.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/Reads/TrimReads/MusCar/MusCar_ERR133991_Trim_2.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/Reads/TrimReads/MusCar/MusCar_ERR133993_Trim_2.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/Reads/TrimReads/MusCar/MusCar_ERR133990_Trim_1.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/Reads/TrimReads/MusCar/MusCar_ERR133993_Trim_1.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/Reads/TrimReads/MusCar/MusCar_ERR133992_Trim_2.fastq.gz | samtools view -Su -@ 20 -F 4 - | samtools sort -@ 20 - -o /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MusCar/MusCar_Temp.bam

samtools view -@ 20 -H /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MusCar/MusCar_Temp.bam > /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MusCar/MusCar_Header.sam

samtools view -@ 20 /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MusCar/MusCar_Temp.bam | grep -v "XS:" | cat /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MusCar/MusCar_Header.sam - | samtools view -@ 20 -b - > /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MusCar/MusCar.bam

rm /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MusCar/MusCar_Temp.bam
rm /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MusCar/MusCar_Header.sam

samtools mpileup -f /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/Composite_Genome/contigs.fa /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MusCar/MusCar.bam > /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MusCar/MusCar.pileups

python /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/scripts/specific_genome.py /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MusCar /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/Composite_Genome/contigs.fa

samtools faidx /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MusCar/contigs.fa
bowtie2-build /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MusCar/contigs.fa /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MusCar/contigs -p 20

bowtie2 -p 20 -N 1 --local -x /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MusCar/contigs -U /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/Reads/TrimReads/MusCar/MusCar_ERR133991_Trim_1.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/Reads/TrimReads/MusCar/MusCar_ERR133992_Trim_1.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/Reads/TrimReads/MusCar/MusCar_ERR133990_Trim_2.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/Reads/TrimReads/MusCar/MusCar_ERR133991_Trim_2.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/Reads/TrimReads/MusCar/MusCar_ERR133993_Trim_2.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/Reads/TrimReads/MusCar/MusCar_ERR133990_Trim_1.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/Reads/TrimReads/MusCar/MusCar_ERR133993_Trim_1.fastq.gz,/net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/Reads/TrimReads/MusCar/MusCar_ERR133992_Trim_2.fastq.gz | samtools view -Su -@ 20 -F 4 - | samtools sort -@ 20 - -o /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MusCar/MusCar_Temp.bam

samtools view -@ 20 -H /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MusCar/MusCar_Temp.bam > /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MusCar/MusCar_Header.sam
samtools view -@ 20 /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MusCar/MusCar_Temp.bam | grep -v "XS:" | cat /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MusCar/MusCar_Header.sam - | samtools view -@ 20 -b - > /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MusCar/MusCar.bam

rm /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MusCar/MusCar_Temp.bam
rm /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MusCar/MusCar_Header.sam

samtools index /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MusCar/MusCar.bam

samtools mpileup -f /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/Composite_Genome/contigs.fa /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MusCar/MusCar.bam > /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MusCar/MusCar.pileups

python /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/scripts/get_pruned_dict.py /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/MusCar /net/fs03/data3/schwartzlab/bob/Rerun_Mammals/Rodents/SISRS_Run/Composite_Genome 3 1.0

