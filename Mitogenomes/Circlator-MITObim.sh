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
#$ -t 1-374 -tc 10

module load bio/bbmap
module load tools/ssd

eval "$(conda shell.bash hook)"
conda activate circlator

FILE=$(sed -n "${SGE_TASK_ID}p" circularize.list)

cd ${FILE}_mitobim
bwa index ${FILE}_link_MITObim.fasta
bwa mem -p -t ${NSLOTS} ${FILE}_link_MITObim.fasta ${FILE}_readpool.fq | samtools view -bS -h -@ ${NSLOTS} - | samtools sort -@ ${NSLOTS} - > ${FILE}.mt.mapped.sorted.bam
LEN=`bioawk -c fastx '{ print length($seq) }' < ${FILE}_link_MITObim.fasta`
END=`echo "${LEN}-500" | bc`
samtools index ${FILE}.mt.mapped.sorted.bam
samtools view -h -b -@ ${NSLOTS} -F12 ${FILE}.mt.mapped.sorted.bam ${FILE}:1-500 ${FILE}:${END} > ${FILE}.mt.mappedEnds.bam
samtools bam2fq -1 ${FILE}.mt.mappedEnds_1.fq -2 ${FILE}.mt.mappedEnds_2.fq -N ${FILE}.mt.mappedEnds.bam
repair.sh in1=${FILE}.mt.mappedEnds_1.fq in2=${FILE}.mt.mappedEnds_2.fq out1=${FILE}.mt.mappedEnds.fixed.1.fq out2=${FILE}.mt.mappedEnds.fixed.2.fq overwrite=true
spades.py --only-assembler --careful -t ${NSLOTS} -1 ${FILE}.mt.mappedEnds.fixed.1.fq -2 ${FILE}.mt.mappedEnds.fixed.2.fq -o spades_circular --tmp-dir $SSD_DIR/${FILE}
circlator merge --min_length_merge 50 --min_length 50 --ref_end 100 --reassemble_end 100 ${FILE}_link_MITObim.fasta spades/scaffolds.fasta ${FILE}_mitogenome.merged
circlator clean ${FILE}_mitogenome.merged.fasta ${FILE}_mitogenome.FINAL
#circlator fixstart --genes_fa ori_genes.fasta ${FILE}_mitogenome.FINAL.fasta ${FILE}_mitogenome.FINAL.fixed

conda deactivate

echo = `date` job $JOB_NAME $SGE_TASK_ID done
