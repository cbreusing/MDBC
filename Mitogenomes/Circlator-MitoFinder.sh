# /bin/sh
#$ -S /bin/sh
#$ -q sThC.q
#$ -pe mthread 8
#$ -l mres=24G,h_data=3G,h_vmem=3G
#$ -cwd
#$ -j y
#$ -N Circlator
#$ -o Circlator.log

module load bio/bwa
module load bio/samtools/1.9
module load bio/spades/3.15.5
module load bio/bbmap

for FILE in `cat circularize-mitofinder.list`
do
cd ${FILE}_mitofinder/${FILE}/${FILE}_MitoFinder_*_Final_Results
sed -i "s/>.*/>${FILE}.1/g" ${FILE}_mtDNA_contig_1.fasta
bwa index ${FILE}_mtDNA_contig_1.fasta
bwa mem -p -t ${NSLOTS} ${FILE}_mtDNA_contig_1.fasta ../../../${FILE}_interleaved.fastq | samtools view -bS -h -@ ${NSLOTS} - | samtools sort -@ ${NSLOTS} - > ${FILE}.mt.mapped.sorted.bam
LEN=`bioawk -c fastx '{ print length($seq) }' < ${FILE}_mtDNA_contig_1.fasta`
# Try to assemble the trailing 500-1000 bp
END=`echo "${LEN}-1000" | bc`
samtools index ${FILE}.mt.mapped.sorted.bam
samtools view -h -b -@ ${NSLOTS} -F12 ${FILE}.mt.mapped.sorted.bam ${FILE}.1:1-1000 ${FILE}.1:${END} > ${FILE}.mt.mappedEnds.bam
samtools bam2fq -1 ${FILE}.mt.mappedEnds_1.fq -2 ${FILE}.mt.mappedEnds_2.fq -N ${FILE}.mt.mappedEnds.bam
repair.sh in1=${FILE}.mt.mappedEnds_1.fq in2=${FILE}.mt.mappedEnds_2.fq out1=${FILE}.mt.mappedEnds.fixed.1.fq out2=${FILE}.mt.mappedEnds.fixed.2.fq overwrite=true
spades.py --only-assembler --careful -t ${NSLOTS} -1 ${FILE}.mt.mappedEnds.fixed.1.fq -2 ${FILE}.mt.mappedEnds.fixed.2.fq -o spades_circular
circlator merge --min_length_merge 50 --min_length 50 --ref_end 100 --reassemble_end 100 ${FILE}_mtDNA_contig_1.fasta spades_circular/scaffolds.fasta ${FILE}_mitogenome.merged
circlator clean ${FILE}_mitogenome.merged.fasta ${FILE}_mitogenome.FINAL
#circlator fixstart --genes_fa ori_genes.fasta ${FILE}_mitogenome.FINAL.fasta ${FILE}_mitogenome.FINAL.fixed
cd ../../..
done

echo = `date` job $JOB_NAME done
