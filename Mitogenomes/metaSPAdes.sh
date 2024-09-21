# /bin/sh
#$ -S /bin/sh
#$ -q mThM.q
#$ -l mres=256G,h_data=16G,h_vmem=16G,himem
#$ -l ssd_res=200G -v SSD_SAVE_MAX=0
#$ -cwd
#$ -j y
#$ -pe mthread 16
#$ -N metaspades
#$ -o metaspades_$TASK_ID.log
#$ -t 1-1032 -tc 10

module load bio/spades
module load tools/ssd

FILE=$(sed -n "${SGE_TASK_ID}p" redo_metaspades.list)

metaspades.py -1 ../${FILE}_R1_clean.fastq -2 ../${FILE}_R2_clean.fastq -o ${FILE}_metaspades -m 256 -t ${NSLOTS} --tmp-dir $SSD_DIR/${FILE}_metaspades
mv ${FILE}_metaspades/scaffolds.fasta ${FILE}.metaspades.fasta
rm -r ${FILE}_metaspades

echo = `date` job $JOB_NAME $SGE_TASK_ID done


