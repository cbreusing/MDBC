# /bin/sh
#$ -S /bin/sh
#$ -q sThC.q
#$ -l mres=64G,h_data=8G,h_vmem=8G
#$ -cwd
#$ -j y
#$ -pe mthread 8
#$ -N Mitofinder
#$ -o Mitofinder_$TASK_ID.log
#$ -t 1-1032 -tc 10

module load bio/mitofinder/1.4

FILE=$(sed -n "${SGE_TASK_ID}p" redo.list | perl -anle 'print $F[0]')
TAXA=$(sed -n "${SGE_TASK_ID}p" redo.list | perl -anle 'print $F[1]')
TABLE=$(sed -n "${SGE_TASK_ID}p" redo.list | perl -anle 'print $F[2]')

# Option 1: Assemble and annotate from trimmed reads
#mitofinder -j ${FILE} -1 ${FILE}_R1_clean.fastq -2 ${FILE}_R2_clean.fastq -r /scratch/nmnh_mdbc/breusingc/databases/mitofinder/${TAXA}_reference.gb --max-contig-size 80000 -o ${TABLE} -p ${NSLOTS} -m 64 -t mitfi --metaspades --rename-contig yes --new-genes --allow-intron --adjust-direction

# Option 2: Annotate from previously assembled metagenome (in case first option fails or for re-annotation of curated mitogenome)
mitofinder -j ${FILE} -a /scratch/nmnh_mdbc/breusingc/genohub_9869237/metagenomes/${FILE}_metagenome.fasta -r /scratch/nmnh_mdbc/breusingc/databases/mitofinder/${TAXA}_reference.gb --max-contig-size 80000 -o ${TABLE} -p ${NSLOTS} -m 64 -t mitfi --rename-contig yes --new-genes --allow-intron --adjust-direction 

echo = `date` job $JOB_NAME $SGE_TASK_ID done

