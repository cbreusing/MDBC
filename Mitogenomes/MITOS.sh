# /bin/bash
#$ -S /bin/bash
#$ -q sThC.q
#$ -l mres=8G,h_data=8G,h_vmem=8G
#$ -cwd
#$ -j y
#$ -N MITOS
#$ -o MITOS_$TASK_ID.log
#$ -t 1-378 -tc 10

eval "$(conda shell.bash hook)"
conda activate mitos

table=$(sed -n "${SGE_TASK_ID}p" assembly.list | perl -anle 'print $F[2]')
FILE=$(sed -n "${SGE_TASK_ID}p" assembly.list | perl -anle 'print $F[0]')

mkdir ${FILE}_mitos
sed -i "s/>.*/>${FILE}.1/g" ${FILE}_mitogenome.FULL.fasta
# Add --linear option for linear assemblies
runmitos.py -i ${FILE}_mitogenome.FULL.fasta -c ${table} -o ${FILE}_mitos -R /home/breusingc/mambaforge/envs/mitos/dbs -r refseq89m --locandgloc --best --debug

conda deactivate

echo = `date` job $JOB_NAME $SGE_TASK_ID done


