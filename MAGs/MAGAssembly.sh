# /bin/bash
#$ -S /bin/bash
#$ -q sThM.q
#$ -pe mthread 24
#$ -l mres=480G,h_data=20G,h_vmem=20G,himem
#$ -cwd
#$ -j y
#$ -N MAGAssembly
#$ -o MAGAssembly_$TASK_ID.log
#$ -t 1-378 -tc 10

module load bio/samtools
module load bio/bowtie2
module load bio/hmmer
module load tools/R
module load bio/ruby

FILE=$(sed -n "${SGE_TASK_ID}p" filelist.txt)

mkdir ${FILE}_MAGs
cd ${FILE}_MAGs
ln -s /scratch/nmnh_mdbc/breusingc/pisces/mitogenomes/${FILE}_mitofinder/${FILE}/${FILE}_link_metaspades.scafSeq scaffolds.fasta
bowtie2-build scaffolds.fasta scaffolds.fasta
bowtie2 -p ${NSLOTS} -x scaffolds.fasta -1 ../../${FILE}_R1_clean.fastq -2 ../../${FILE}_R2_clean.fastq | samtools view -bS -h -@ ${NSLOTS} - | samtools sort -@ ${NSLOTS} - > ${FILE}.bowtie2.sorted.bam
eval "$(conda shell.bash hook)"
conda activate metabat2
jgi_summarize_bam_contig_depths --outputDepth depth.txt ${FILE}.bowtie2.sorted.bam
metabat2 -i scaffolds.fasta -a depth.txt -m 1500 -o metabat/${FILE} --unbinned -t ${NSLOTS}
conda deactivate
conda activate maxbin2
mkdir maxbin
run_MaxBin.pl -contig scaffolds.fasta -reads ../../${FILE}_R1_clean.fastq -reads2 ../../${FILE}_R2_clean.fastq -out maxbin/${FILE} -thread ${NSLOTS} -min_contig_length 500
mkdir maxbin/bins
mv maxbin/*fasta maxbin/bins/.
mv maxbin/${FILE}.noclass maxbin/bins/${FILE}.noclass.fasta
mv maxbin/${FILE}.tooshort maxbin/bins/${FILE}.tooshort.fasta
conda deactivate
conda activate das_tool
/home/breusingc/scripts/Fasta_to_Scaffolds2Bin.sh -i maxbin/bins -e fasta > maxbin.scaffolds2bin.tsv
/home/breusingc/scripts/Fasta_to_Scaffolds2Bin.sh -i metabat -e fa > metabat.scaffolds2bin.tsv
DAS_Tool -i maxbin.scaffolds2bin.tsv,metabat.scaffolds2bin.tsv -l MaxBin2,metaBAT2 --score_threshold 0.5 -c scaffolds.fasta -o DAS_Tool/${FILE} --write_bins -t ${NSLOTS}
conda deactivate
conda activate gtdbtk-2.1.1
gtdbtk classify_wf --genome_dir DAS_Tool/${FILE}_DASTool_bins --out_dir gtdbtk -x fa --cpus ${NSLOTS} --pplacer_cpus 1
conda deactivate

echo = `date` job $JOB_NAME $SGE_TASK_ID done
