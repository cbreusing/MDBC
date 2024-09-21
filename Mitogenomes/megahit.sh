# /bin/sh
#$ -S /bin/sh
#$ -q mThC.q
#$ -l mres=128G,h_data=8G,h_vmem=8G
#$ -cwd
#$ -j y
#$ -pe mthread 16
#$ -N megahit
#$ -o megahit_$TASK_ID.log
#$ -t 1-46 -tc 10

FILE=$(sed -n "${SGE_TASK_ID}p" redo_metaspades.list)

megahit -1 ../${FILE}_R1_clean.fastq -2 ../${FILE}_R2_clean.fastq -o ${FILE}_megahit -t ${NSLOTS}

echo = `date` job $JOB_NAME $SGE_TASK_ID done


