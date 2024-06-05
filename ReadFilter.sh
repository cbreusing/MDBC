# /bin/sh
#$ -S /bin/sh
#$ -q sThC.q
#$ -pe mthread 24
#$ -l mres=36G,h_data=1.5G,h_vmem=1.5G
#$ -cwd
#$ -j y
#$ -N ReadFilter
#$ -o ReadFilter_$TASK_ID.log
#$ -t 1-378 -tc 10

module load bio/fastqc
module load bio/trimmomatic
module load bio/samtools
module load bio/bowtie2
module load bio/seqtk

FILE=$(sed -n "${SGE_TASK_ID}p" filelist.txt)

fastqc -t ${NSLOTS} ${FILE}_R1.fastq.gz
fastqc -t ${NSLOTS} ${FILE}_R2.fastq.gz

fastp --in1 ${FILE}_R1.fastq.gz --out1 ${FILE}_gtrim_1.fq --in2 ${FILE}_R2.fastq.gz --out2 ${FILE}_gtrim_2.fq -A -Q -L -g -y -w ${NSLOTS}
java -jar /share/apps/bioinformatics/trimmomatic/0.39/trimmomatic-0.39.jar PE -threads ${NSLOTS} -phred33 ${FILE}_gtrim_1.fq ${FILE}_gtrim_2.fq ${FILE}_R1_paired.fq ${FILE}_R1_unpaired.fq ${FILE}_R2_paired.fq ${FILE}_R2_unpaired.fq ILLUMINACLIP:/home/breusingc/adaptors/NEBNext.fasta:2:30:10:2:True SLIDINGWINDOW:4:20 LEADING:5 TRAILING:5 MINLEN:50
bowtie2 -p ${NSLOTS} -x /scratch/nmnh_mdbc/breusingc/databases/contaminants -1 ${FILE}_R1_paired.fq -2 ${FILE}_R2_paired.fq | samtools view -bS -h -@ ${NSLOTS} - | samtools sort -@ ${NSLOTS} - > ${FILE}.bowtie2.cont.sorted.bam
samtools view -@ ${NSLOTS} -f12 ${FILE}.bowtie2.cont.sorted.bam > ${FILE}.cont.unmapped.sam
cut -f1 ${FILE}.cont.unmapped.sam | sort | uniq > ${FILE}.cont.unmapped_ids.lst
seqtk subseq ${FILE}_R1_paired.fq ${FILE}.cont.unmapped_ids.lst > ${FILE}_R1_clean.fastq
seqtk subseq ${FILE}_R2_paired.fq ${FILE}.cont.unmapped_ids.lst > ${FILE}_R2_clean.fastq

echo = `date` job $JOB_NAME_$SGE_TASK_ID done
