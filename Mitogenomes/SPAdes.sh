# /bin/sh
#$ -S /bin/sh
#$ -q sThC.q
#$ -l mres=128G,h_data=4G,h_vmem=4G
#$ -l ssd_res=200G -v SSD_SAVE_MAX=0
#$ -cwd
#$ -j y
#$ -pe mthread 32
#$ -N Spades
#$ -o Spades_$TASK_ID.log
#$ -t 1-378 -tc 10

module load bio/spades
module load tools/ssd

FILE=$(sed -n "${SGE_TASK_ID}p" filelist.txt)

metaspades.py -1 ../${FILE}_R1_clean.fastq -2 ../${FILE}_R2_clean.fastq -o ${FILE}_metaspades -m 128 -t ${NSLOTS} --tmp-dir $SSD_DIR/${FILE}_metaspades
spades.py -1 ../${FILE}_R1_clean.fastq -2 ../${FILE}_R2_clean.fastq -o ${FILE}_spades -m 128 -t ${NSLOTS} --tmp-dir $SSD_DIR/${FILE}_spades
