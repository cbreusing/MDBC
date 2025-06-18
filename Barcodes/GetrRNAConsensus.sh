# /bin/sh
#$ -S /bin/bash
#$ -q sThM.q
#$ -l mres=16G,h_data=16G,h_vmem=16G,himem
#$ -cwd
#$ -j y
#$ -N GetrRNAConsensus
#$ -o GetrRNAConsensus_$TASK_ID.log
#$ -t 1-1032 -tc 10
 
module load bio/seqkit

FILE=$(sed -n "${SGE_TASK_ID}p" filelist.txt)

eval "$(conda shell.bash hook)"
conda activate vsearch

cat barcodes/18S/final_seqs/${FILE}.18S.FINAL.region.fasta barrnap/${FILE}/${FILE}.18S.FINAL.fasta | seqkit sort -l -r | awk "/^>/ {n++} n>1 {exit} 1" > barcodes/18S/final_seqs/${FILE}.18S.FINAL.consensus.fasta
sed -i "s/>.*/>${FILE}/g" barcodes/18S/final_seqs/${FILE}.18S.FINAL.consensus.fasta
vsearch --orient barcodes/18S/final_seqs/${FILE}.18S.FINAL.consensus.fasta --db /scratch/nmnh_mdbc/breusingc/databases/SILVA_138.1_SSURef_NR99_tax_silva_trunc.fasta --fastaout barcodes/18S/final_seqs/${FILE}.18S.FINAL.oriented.fasta --notmatched barcodes/18S/final_seqs/${FILE}.18S.FINAL.nomatch.fasta --notrunclabels
cat barcodes/18S/final_seqs/${FILE}.18S.FINAL.nomatch.fasta >> barcodes/18S/final_seqs/${FILE}.18S.FINAL.oriented.fasta
mv barcodes/18S/final_seqs/${FILE}.18S.FINAL.oriented.fasta barcodes/18S/final_seqs/${FILE}.18S.FINAL.fasta
rm barcodes/18S/final_seqs/${FILE}.18S.FINAL.nomatch.fasta
rm barcodes/18S/final_seqs/${FILE}.18S.FINAL.oriented.fasta
rm barcodes/18S/final_seqs/${FILE}.18S.FINAL.consensus.fasta
cat /scratch/nmnh_mdbc/breusingc/genohub_9869237/barcodes/28S/final_seqs/${FILE}.28S.FINAL.region.fasta barrnap/${FILE}/${FILE}.28S.FINAL.fasta | seqkit sort -l -r | awk "/^>/ {n++} n>1 {exit} 1" > barcodes/28S/final_seqs/${FILE}.28S.FINAL.consensus.fasta
sed -i "s/>.*/>${FILE}/g" barcodes/28S/final_seqs/${FILE}.28S.FINAL.consensus.fasta
vsearch --orient barcodes/28S/final_seqs/${FILE}.28S.FINAL.consensus.fasta --db /scratch/nmnh_mdbc/breusingc/databases/SILVA_138.1_LSURef_NR99_tax_silva_trunc.fasta --fastaout barcodes/28S/final_seqs/${FILE}.28S.FINAL.oriented.fasta --notmatched barcodes/28S/final_seqs/${FILE}.28S.FINAL.nomatch.fasta --notrunclabels
cat barcodes/28S/final_seqs/${FILE}.28S.FINAL.nomatch.fasta >> barcodes/28S/final_seqs/${FILE}.28S.FINAL.oriented.fasta
mv barcodes/28S/final_seqs/${FILE}.28S.FINAL.oriented.fasta barcodes/28S/final_seqs/${FILE}.28S.FINAL.fasta
rm barcodes/28S/final_seqs/${FILE}.28S.FINAL.nomatch.fasta
rm barcodes/28S/final_seqs/${FILE}.28S.FINAL.oriented.fasta
rm barcodes/28S/final_seqs/${FILE}.28S.FINAL.consensus.fasta

conda deactivate

echo = `date` job $JOB_NAME $SGE_TASK_ID done
