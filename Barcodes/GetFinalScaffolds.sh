# /bin/sh
#$ -S /bin/bash
#$ -q sThM.q
#$ -l mres=50G,h_data=50G,h_vmem=50G,himem
#$ -cwd
#$ -j y
#$ -N GetFinalScaffolds
#$ -o GetFinalScaffolds_$TASK_ID.log
#$ -t 1-1032 -tc 10

module load bio/bedtools
module load bio/seqkit

eval "$(conda shell.bash hook)"
conda activate vsearch

FILE=$(sed -n "${SGE_TASK_ID}p" filelist.txt | perl -anle 'print $F[0]')
TAXON=$(sed -n "${SGE_TASK_ID}p" filelist.txt | perl -anle 'print $F[1]')

cat blast.${FILE}.mito.topHit.txt blast.${FILE}.COI.topHit.txt | grep "${TAXON}" | perl -anle 'print $F[0] . "\t" . $F[6] . "\t" . $F[7]' | sort -u > ${FILE}.COI.bed
bedtools getfasta -fi ${FILE}_COI.fasta -bed ${FILE}.COI.bed -fullHeader | seqkit sort -l -r > COI/${FILE}.COI.${TAXON}.fasta
awk "/^>/ {n++} n>1 {exit} 1" COI/${FILE}.COI.${TAXON}.fasta > COI/final_seqs/${FILE}.COI.FINAL.region.fasta
vsearch --orient COI/final_seqs/${FILE}.COI.FINAL.region.fasta --db /scratch/dbs/blast/bold/fasta/bold_coi_2023_05_12.fasta --fastaout COI/final_seqs/${FILE}.COI.FINAL.oriented.fasta --notmatched COI/final_seqs/${FILE}.COI.FINAL.nomatch.fasta --notrunclabels
cat COI/final_seqs/${FILE}.COI.FINAL.nomatch.fasta >> COI/final_seqs/${FILE}.COI.FINAL.oriented.fasta
mv COI/final_seqs/${FILE}.COI.FINAL.oriented.fasta COI/final_seqs/${FILE}.COI.FINAL.fasta
rm COI/final_seqs/${FILE}.COI.FINAL.nomatch.fasta
rm COI/final_seqs/${FILE}.COI.FINAL.oriented.fasta
rm COI/final_seqs/${FILE}.COI.FINAL.region.fasta
sed -i "s/>.*/>${FILE}/g" COI/final_seqs/${FILE}.COI.FINAL.fasta

cat blast.${FILE}.18S.topHit.txt blast.${FILE}.18Snt.topHit.txt | grep "${TAXON}" | perl -anle 'print $F[0] . "\t" . $F[6] . "\t" . $F[7]' | sort -u > ${FILE}.18S.bed
bedtools getfasta -fi ${FILE}_18S.fasta -bed ${FILE}.18S.bed -fullHeader | seqkit sort -l -r > 18S/${FILE}.18S.${TAXON}.fasta
awk "/^>/ {n++} n>1 {exit} 1" 18S/${FILE}.18S.${TAXON}.fasta > 18S/final_seqs/${FILE}.18S.FINAL.region.fasta

cat blast.${FILE}.28S.topHit.txt blast.${FILE}.28Snt.topHit.txt | grep "${TAXON}" | perl -anle 'print $F[0] . "\t" . $F[6] . "\t" . $F[7]' | sort -u > ${FILE}.28S.bed
bedtools getfasta -fi ${FILE}_28S.fasta -bed ${FILE}.28S.bed -fullHeader | seqkit sort -l -r > 28S/${FILE}.28S.${TAXON}.fasta
awk "/^>/ {n++} n>1 {exit} 1" 28S/${FILE}.28S.${TAXON}.fasta > 28S/final_seqs/${FILE}.28S.FINAL.region.fasta

conda deactivate

echo = `date` job $JOB_NAME $SGE_TASK_ID done
