# /bin/sh
#$ -S /bin/bash
#$ -q sThC.q
#$ -pe mthread 8
#$ -l mres=64G,h_data=8G,h_vmem=8G
#$ -l ssd_res=200G -v SSD_SAVE_MAX=0
#$ -cwd
#$ -j y
#$ -N Circlator
#$ -o Circlator_$TASK_ID.log
#$ -t 1-796 -tc 10

module load bio/bbmap
module load tools/ssd

eval "$(conda shell.bash hook)"
conda activate circlator

FILE=$(sed -n "${SGE_TASK_ID}p" circularize.list)

cd ${FILE}/${FILE}_MitoFinder_mitfi_Final_Results
sed -i "s/>.*/>${FILE}.1/g" ${FILE}_mtDNA_contig.fasta
bwa index ${FILE}_mtDNA_contig.fasta
bwa mem -t ${NSLOTS} ${FILE}_mtDNA_contig.fasta ../../../${FILE}_R1_clean.fastq ../../../${FILE}_R2_clean.fastq | samtools view -bS -h -@ ${NSLOTS} - | samtools sort -@ ${NSLOTS} - > ${FILE}.mt.mapped.sorted.bam
LEN=`bioawk -c fastx '{ print length($seq) }' < ${FILE}_mtDNA_contig.fasta`
# Try to assemble the trailing 500-1000 bp
END=`echo "${LEN}-1000" | bc`
samtools index ${FILE}.mt.mapped.sorted.bam
samtools view -h -b -@ ${NSLOTS} -F12 ${FILE}.mt.mapped.sorted.bam ${FILE}.1:1-1000 ${FILE}.1:${END} > ${FILE}.mt.mappedEnds.bam
samtools bam2fq -1 ${FILE}.mt.mappedEnds_1.fq -2 ${FILE}.mt.mappedEnds_2.fq -N ${FILE}.mt.mappedEnds.bam
repair.sh in1=${FILE}.mt.mappedEnds_1.fq in2=${FILE}.mt.mappedEnds_2.fq out1=${FILE}.mt.mappedEnds.fixed.1.fq out2=${FILE}.mt.mappedEnds.fixed.2.fq overwrite=true
spades.py --only-assembler --careful -t ${NSLOTS} -1 ${FILE}.mt.mappedEnds.fixed.1.fq -2 ${FILE}.mt.mappedEnds.fixed.2.fq -o spades_circular --tmp-dir $SSD_DIR/${FILE}
circlator merge --min_length_merge 50 --min_length 50 --ref_end 100 --reassemble_end 100 ${FILE}_mtDNA_contig.fasta spades_circular/scaffolds.fasta ${FILE}_mitogenome.merged
circlator clean ${FILE}_mitogenome.merged.fasta ${FILE}_mitogenome.FINAL
#circlator fixstart --genes_fa ori_genes.fasta ${FILE}_mitogenome.FINAL.fasta ${FILE}_mitogenome.FINAL.fixed

conda deactivate

echo = `date` job $JOB_NAME $SGE_TASK_ID done


