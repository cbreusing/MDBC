# /bin/sh
#$ -S /bin/sh
#$ -q sThC.q
#$ -l mres=2G,h_data=2G,h_vmem=2G
#$ -cwd
#$ -j y
#$ -N GetFinalScaffolds
#$ -o GetFinalScaffolds.log

module load bio/bedtools
module load bio/seqkit

LINE=1

while [ ${LINE} -le 4 ]
do
FILE=$(sed -n "${LINE}p" filelist.txt | perl -anle 'print $F[0]')
TAXON=$(sed -n "${LINE}p" filelist.txt | perl -anle 'print $F[1]')

cat blast.${FILE}.mito.topHit.full.txt blast.${FILE}.COI.topHit.full.txt | grep "${TAXON}" | perl -anle 'print $F[0] . "\t" . $F[6] . "\t" . $F[7]' | sort -u > ${FILE}.COI.bed
bedtools getfasta -fi spades_${FILE}_COI/scaffolds.fasta -bed ${FILE}.COI.bed -fullHeader | seqkit sort -l -r > COI/${FILE}.COI.${TAXON}.fasta
awk "/^>/ {n++} n>1 {exit} 1" COI/${FILE}.COI.${TAXON}.fasta > COI/final_seqs/${FILE}.COI.FINAL.region.fasta

grep "${TAXON}" blast.${FILE}.18S.topHit.txt | perl -anle 'print $F[0] . "\t" . $F[6] . "\t" . $F[7]' | sort -u > ${FILE}.18S.bed
bedtools getfasta -fi spades_${FILE}_18S/scaffolds.fasta -bed ${FILE}.18S.bed -fullHeader | seqkit sort -l -r > 18S/${FILE}.18S.${TAXON}.fasta
awk "/^>/ {n++} n>1 {exit} 1" 18S/${FILE}.18S.${TAXON}.fasta > 18S/final_seqs/${FILE}.18S.FINAL.region.fasta

grep "${TAXON}" blast.${FILE}.28S.topHit.txt | perl -anle 'print $F[0] . "\t" . $F[6] . "\t" . $F[7]' | sort -u > ${FILE}.28S.bed
bedtools getfasta -fi spades_${FILE}_28S/scaffolds.fasta -bed ${FILE}.28S.bed -fullHeader | seqkit sort -l -r > 28S/${FILE}.28S.${TAXON}.fasta
awk "/^>/ {n++} n>1 {exit} 1" 28S/${FILE}.28S.${TAXON}.fasta > 28S/final_seqs/${FILE}.28S.FINAL.region.fasta

LINE=$(( ${LINE} + 1 ))
done

mv blast*txt barcode_blast_results/.
