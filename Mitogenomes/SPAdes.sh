# /bin/sh
#$ -S /bin/sh
#$ -q mThM.q
#$ -l mres=256G,h_data=16G,h_vmem=16G,himem
#$ -l ssd_res=200G -v SSD_SAVE_MAX=0
#$ -cwd
#$ -j y
#$ -pe mthread 16
#$ -N Spades
#$ -o Spades_$TASK_ID.log
#$ -t 1-1032 -tc 10

module load bio/spades
module load tools/ssd

FILE=$(sed -n "${SGE_TASK_ID}p" redo_spades.list)

spades.py -1 ../${FILE}_R1_clean.fastq -2 ../${FILE}_R2_clean.fastq -o ${FILE}_spades -m 256 -t ${NSLOTS} --tmp-dir $SSD_DIR/${FILE}_spades
mv ${FILE}_spades/scaffolds.fasta ${FILE}.spades.fasta
rm -r ${FILE}_spades

echo = `date` job $JOB_NAME $SGE_TASK_ID done
