# /bin/sh
#$ -S /bin/bash
#$ -q sThM.q
#$ -l mres=16G,h_data=16G,h_vmem=16G,himem
#$ -cwd
#$ -j y
#$ -N MITObim
#$ -o MITObim_$TASK_ID.log
#$ -t 1-374 -tc 10

module load bio/bbmap

FILE=$(sed -n "${SGE_TASK_ID}p" mitobim.list)

reformat.sh in1=../${FILE}_R1_clean.fastq in2=../${FILE}_R2_clean.fastq out=../${FILE}_interleaved.fastq
mkdir ${FILE}_mitobim
cd ${FILE}_mitobim

eval "$(conda shell.bash hook)"
conda activate mitobim

MITObim.pl -start 1 -end 100 -sample ${FILE} -ref ${FILE}_COI -readpool ../../${FILE}_interleaved.fastq --quick ../../barcodes/COI/final_seqs/${FILE}.COI.FINAL.fasta --clean

conda deactivate

echo = `date` job $JOB_NAME $SGE_TASK_ID done

