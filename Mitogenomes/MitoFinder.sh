# /bin/sh
#$ -S /bin/sh
#$ -q sThC.q
#$ -l mres=32G,h_data=4G,h_vmem=4G
#$ -cwd
#$ -j y
#$ -pe mthread 8
#$ -N Mitofinder
#$ -o Mitofinder_$TASK_ID.log
#$ -t 1-378 -tc 10

module load bio/mitofinder/1.4

taxa=$(sed -n "${SGE_TASK_ID}p" assembly.list | perl -anle 'print $F[1]')
table=$(sed -n "${SGE_TASK_ID}p" assembly.list | perl -anle 'print $F[2]')
FILE=$(sed -n "${SGE_TASK_ID}p" assembly.list | perl -anle 'print $F[0]')

# Option 1: Assemble and annotate from trimmed reads
mitofinder -j ${FILE} -1 ${FILE}_R1_clean.fastq -2 ${FILE}_R2_clean.fastq -r /scratch/nmnh_mdbc/breusingc/databases/${taxa}_reference.gb --max-contig-size 80000 --ignore -o ${table} -p ${NSLOTS} -m 32 -t mitfi --metaspades --rename-contig yes --new-genes --allow-intron

# Option 2: Annotate from previously assembled metagenome (in case first option fails or for re-annotation of curaed mitogenome)
#mitofinder -j ${FILE} -a ${FILE}_metaspades/scaffolds.fasta -r /scratch/nmnh_mdbc/breusingc/databases/${taxa}_reference.gb --max-contig-size 80000 --ignore -o ${table} -p ${NSLOTS} -m 32 -t mitfi --rename-contig yes --new-genes --allow-intron

echo = `date` job $JOB_NAME $SGE_TASK_ID done

