# /bin/sh
#$ -S /bin/sh
#$ -q sThC.q
#$ -l mres=2G,h_data=2G,h_vmem=2G
#$ -cwd
#$ -j y
#$ -N GetrRNAConsensus
#$ -o GetrRNAConsensus.log

module load bio/seqkit

for FILE in `cat filelist.txt`
do
cat /scratch/nmnh_mdbc/breusingc/pisces/18S/final_seqs/${FILE}.18S.FINAL.region.fasta /scratch/nmnh_mdbc/breusingc/pisces/barrnap/${FILE}/${FILE}.18S.FINAL.fasta | seqkit sort -l -r | awk "/^>/ {n++} n>1 {exit} 1" > ${FILE}.18S.FINAL.consensus.fasta
sed -i "s/>.*/>${FILE} 18S rRNA/g" ${FILE}.18S.FINAL.consensus.fasta
cat /scratch/nmnh_mdbc/breusingc/pisces/28S/final_seqs/${FILE}.28S.FINAL.region.fasta /scratch/nmnh_mdbc/breusingc/pisces/barrnap/${FILE}/${FILE}.28S.FINAL.fasta | seqkit sort -l -r | awk "/^>/ {n++} n>1 {exit} 1" > ${FILE}.28S.FINAL.consensus.fasta
sed -i "s/>.*/>${FILE} 28S rRNA/g" ${FILE}.28S.FINAL.consensus.fasta
done
