# /bin/sh
#$ -S /bin/sh
#$ -q sThC.q
#$ -l mres=1G,h_data=1G,h_vmem=1G
#$ -cwd
#$ -j y
#$ -N barrnap
#$ -o barrnap_$TASK_ID.log
#$ -t 1-378 -tc 10

module load bio/blast
module load bio/seqtk
module load bio/seqkit
module load bio/hmmer
module load bio/bedtools

file=$(sed -n "${SGE_TASK_ID}p" filelist.txt | perl -anle 'print $F[0]')
taxon=$(sed -n "${SGE_TASK_ID}p"  filelist.txt | perl -anle 'print $F[1]')

mkdir ${file}
cd ${file}
barrnap --kingdom euk --threads ${NSLOTS} --outseq ${file}_18S-28S_rRNA.fasta < /scratch/nmnh_mdbc/breusingc/pisces/mitogenomes/${file}_mitofinder/${file}/${file}_link_metaspades.scafSeq
awk 'BEGIN {RS=">"} /28S_rRNA/ {printf "%s", ">"$0}' ${file}_18S-28S_rRNA.fasta > ${file}_28S_rRNA.fasta
awk 'BEGIN {RS=">"} /18S_rRNA/ {printf "%s", ">"$0}' ${file}_18S-28S_rRNA.fasta > ${file}_18S_rRNA.fasta
blastn -query ${file}_28S_rRNA.fasta -db /scratch/nmnh_mdbc/breusingc/databases/SILVA_138.1_LSURef_NR99 -out blast.${file}.28S.txt -evalue 1e-10 -max_target_seqs 1 -outfmt "6 std stitle"
cat blast.${file}.28S.txt | sort -k1,1 -k12,12nr -k11,11n | sort -u -k1,1 > blast.${file}.28S.topHit.txt
rm blast.${file}.28S.txt
blastn -query ${file}_18S_rRNA.fasta -db /scratch/nmnh_mdbc/breusingc/databases/SILVA_138.1_SSURef_NR99 -out blast.${file}.18S.txt -evalue 1e-10 -max_target_seqs 1 -outfmt "6 std stitle"
cat blast.${file}.18S.txt | sort -k1,1 -k12,12nr -k11,11n | sort -u -k1,1 > blast.${file}.18S.topHit.txt
rm blast.${file}.18S.txt
grep "${taxon}" blast.${file}.18S.topHit.txt | perl -anle 'print $F[0]' | sort -u > ${file}.18S.ids
seqtk subseq ${file}_18S_rRNA.fasta ${file}.18S.ids | seqkit sort -l -r > ${file}.18S.${taxon}.fasta
awk "/^>/ {n++} n>1 {exit} 1" ${file}.18S.${taxon}.fasta > ${file}.18S.FINAL.fasta
grep "${taxon}" blast.${file}.28S.topHit.txt | perl -anle 'print $F[0]' | sort -u > ${file}.28S.ids
seqtk subseq ${file}_28S_rRNA.fasta ${file}.28S.ids | seqkit sort -l -r > ${file}.28S.${taxon}.fasta
awk "/^>/ {n++} n>1 {exit} 1" ${file}.28S.${taxon}.fasta > ${file}.28S.FINAL.fasta

echo = `date` job $JOB_NAME $SGE_TASK_ID done

