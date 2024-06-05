# /bin/sh
#$ -S /bin/sh
#$ -q sThC.q
#$ -l mres=8G,h_data=8G,h_vmem=8G
#$ -cwd
#$ -j y
#$ -N MITObim
#$ -o MITObim_$TASK_ID.log
#$ -t 1-378 -tc 10

module load bio/bbmap

FILE=$(sed -n "${SGE_TASK_ID}p" filelist.txt)

reformat.sh in1=../${FILE}_R1_clean.fastq in2=../${FILE}_R2_clean.fastq out=${FILE}_interleaved.fastq
mkdir ${FILE}_mitobim
cd ${FILE}_mitobim
MITObim.pl -start 1 -end 100 -sample ${FILE} -ref ${FILE}_COI -readpool ../${FILE}_interleaved.fastq --quick ../COI/final_seqs/${FILE}.COI.FINAL.region.fasta --clean

echo = `date` job $JOB_NAME $SGE_TASK_ID done




