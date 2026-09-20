# /bin/sh
#$ -S /bin/bash
#$ -q sThM.q
#$ -l mres=50G,h_data=50G,h_vmem=50G,himem
#$ -cwd
#$ -j y
#$ -N GetFinalScaffolds
#$ -o GetFinalScaffolds_$TASK_ID.log
#$ -t 1-188 -tc 10

module load bio/bedtools
module load bio/seqkit
module load bio/seqtk

FILE=$(sed -n "${SGE_TASK_ID}p" files.list | perl -anle 'print $F[0]')
TAXON=$(sed -n "${SGE_TASK_ID}p" files.list | perl -anle 'print $F[1]')
TABLE=$(sed -n "${SGE_TASK_ID}p" files.list | perl -anle 'print $F[2]')

eval "$(conda shell.bash hook)"
conda activate vsearch

cd COI
cat blast.${FILE}.mito.topHit.txt blast.${FILE}.COI.topHit.txt | grep "${TAXON}" | perl -anle 'print $F[0]' | sort -u > ${FILE}.COI.ids
seqtk subseq ${FILE}_COI.fasta ${FILE}.COI.ids | seqkit sort -l -r > ${FILE}.COI.${TAXON}.fasta
awk "/^>/ {n++} n>1 {exit} 1" ${FILE}.COI.${TAXON}.fasta > final_seqs/${FILE}.COI.FINAL.fasta
vsearch --orient final_seqs/${FILE}.COI.FINAL.fasta --db /scratch/nmnh_mdbc/breusingc/databases/BOLD_COI.27-Feb-2026.fasta --fastaout final_seqs/${FILE}.COI.FINAL.oriented.fasta --notmatched final_seqs/${FILE}.COI.FINAL.nomatch.fasta --notrunclabels
cat final_seqs/${FILE}.COI.FINAL.nomatch.fasta >> final_seqs/${FILE}.COI.FINAL.oriented.fasta
mv final_seqs/${FILE}.COI.FINAL.oriented.fasta final_seqs/${FILE}.COI.FINAL.fasta
rm final_seqs/${FILE}.COI.FINAL.nomatch.fasta
rm final_seqs/${FILE}.COI.FINAL.oriented.fasta
sed -i "s/>.*/>${FILE}/g" final_seqs/${FILE}.COI.FINAL.fasta
conda deactivate

conda activate biocode
python /home/breusingc/scripts/translate_and_extract_seqs.py final_seqs/${FILE}.COI.FINAL.fasta -t ${TABLE} -o final_seqs/${FILE}.COI.FINAL.fna -p final_seqs/${FILE}.COI.FINAL.faa  
conda deactivate

cd ../18S
cat blast.${FILE}.18S.topHit.txt blast.${FILE}.18Snt.topHit.txt | grep "${TAXON}" | perl -anle 'print $F[0] . "\t" . $F[6] . "\t" . $F[7]' | sort -u > ${FILE}.18S.bed
bedtools getfasta -fi ${FILE}_18S.fasta -bed ${FILE}.18S.bed -fullHeader | seqkit sort -l -r > ${FILE}.18S.${TAXON}.fasta
awk "/^>/ {n++} n>1 {exit} 1" ${FILE}.18S.${TAXON}.fasta > ${FILE}.18S.FINAL.region.fasta

cd ../28S
cat blast.${FILE}.28S.topHit.txt blast.${FILE}.28Snt.topHit.txt | grep "${TAXON}" | perl -anle 'print $F[0] . "\t" . $F[6] . "\t" . $F[7]' | sort -u > ${FILE}.28S.bed
bedtools getfasta -fi ${FILE}_28S.fasta -bed ${FILE}.28S.bed -fullHeader | seqkit sort -l -r > ${FILE}.28S.${TAXON}.fasta
awk "/^>/ {n++} n>1 {exit} 1" ${FILE}.28S.${TAXON}.fasta > ${FILE}.28S.FINAL.region.fasta

conda deactivate

echo = `date` job $JOB_NAME $SGE_TASK_ID done

