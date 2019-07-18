module load BEDTools/2.26.0-foss-2016b
for f in *.bed; do echo $f; bedtools merge -i $f > merge_$f; cat merge_$f | awk -F'\t' 'BEGIN{SUM=0}{ SUM+=$3-$2 }END{print SUM}';done
