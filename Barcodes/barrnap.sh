# /bin/sh
#$ -S /bin/bash
#$ -q sThM.q
#$ -l mres=256G,h_data=16G,h_vmem=16G,himem
#$ -pe mthread 16
#$ -cwd
#$ -j y
#$ -N barrnap
#$ -o barrnap_$TASK_ID.log
#$ -t 1-1032 -tc 10

module load bio/blast
module load bio/seqtk
module load bio/seqkit

file=$(sed -n "${SGE_TASK_ID}p" filelist.txt | perl -anle 'print $F[0]')
taxon=$(sed -n "${SGE_TASK_ID}p"  filelist.txt | perl -anle 'print $F[1]')

mkdir ${file}
cd ${file}

eval "$(conda shell.bash hook)"
conda activate barrnap
barrnap --kingdom euk --threads ${NSLOTS} --outseq ${file}_18S-28S_rRNA.fasta < /scratch/nmnh_mdbc/breusingc/genohub_9869237/metagenomes/${file}_metagenome.fasta
conda deactivate

awk 'BEGIN {RS=">"} /28S_rRNA/ {printf "%s", ">"$0}' ${file}_18S-28S_rRNA.fasta > ${file}_28S_rRNA.fasta
awk 'BEGIN {RS=">"} /18S_rRNA/ {printf "%s", ">"$0}' ${file}_18S-28S_rRNA.fasta > ${file}_18S_rRNA.fasta
blastn -query ${file}_28S_rRNA.fasta -db /scratch/dbs/blast/v5/nt -out blast.${file}.28Snt.txt -evalue 1e-10 -num_threads ${NSLOTS} -max_target_seqs 50 -outfmt "6 std stitle staxids"
cat blast.${file}.28Snt.txt | sort -k1,1 -k12,12nr -k11,11n | sort -u -k1,1 > blast.${file}.28Snt.topHit.txt
perl /home/breusingc/scripts/reformat_table2.pl blast.${file}.28Snt.topHit.txt /scratch/nmnh_mdbc/breusingc/databases/taxdump/taxids2lineage.txt blast.${file}.28Snt.topHit.full.txt
grep "28S ribosomal" blast.${file}.28Snt.topHit.full.txt > blast.${file}.28Snt.topHit.txt
grep "large subunit ribosomal" blast.${file}.28Snt.topHit.full.txt | grep -v "mitochondr" >> blast.${file}.28Snt.topHit.txt
blastn -query ${file}_28S_rRNA.fasta -db /scratch/nmnh_mdbc/breusingc/databases/SILVA_138.1_LSURef_NR99 -out blast.${file}.28S.txt -evalue 1e-10 -max_target_seqs 50 -outfmt "6 std stitle"
cat blast.${file}.28S.txt | sort -k1,1 -k12,12nr -k11,11n | sort -u -k1,1 > blast.${file}.28S.topHit.txt
rm blast.${file}.28S.txt
blastn -query ${file}_18S_rRNA.fasta -db /scratch/dbs/blast/v5/nt -out blast.${file}.18Snt.txt -evalue 1e-10 -num_threads ${NSLOTS} -max_target_seqs 50 -outfmt "6 std stitle staxids"
cat blast.${file}.18Snt.txt | sort -k1,1 -k12,12nr -k11,11n | sort -u -k1,1 > blast.${file}.18Snt.topHit.txt
perl /home/breusingc/scripts/reformat_table2.pl blast.${file}.18Snt.topHit.txt /scratch/nmnh_mdbc/breusingc/databases/taxdump/taxids2lineage.txt blast.${file}.18Snt.topHit.full.txt
grep "18S ribosomal" blast.${file}.18Snt.topHit.full.txt > blast.${file}.18Snt.topHit.txt
grep "small subunit ribosomal" blast.${file}.18Snt.topHit.full.txt | grep -v "mitochondr" >> blast.${file}.18Snt.topHit.txt
blastn -query ${file}_18S_rRNA.fasta -db /scratch/nmnh_mdbc/breusingc/databases/SILVA_138.1_SSURef_NR99 -out blast.${file}.18S.txt -evalue 1e-10 -max_target_seqs 50 -outfmt "6 std stitle"
cat blast.${file}.18S.txt | sort -k1,1 -k12,12nr -k11,11n | sort -u -k1,1 > blast.${file}.18S.topHit.txt
rm blast.${file}.18S.txt
cat blast.${file}.18S.topHit.txt blast.${file}.18Snt.topHit.txt | grep "${taxon}" | perl -anle 'print $F[0]' | sort -u > ${file}.18S.ids
seqtk subseq ${file}_18S_rRNA.fasta ${file}.18S.ids | seqkit sort -l -r > ${file}.18S.${taxon}.fasta
awk "/^>/ {n++} n>1 {exit} 1" ${file}.18S.${taxon}.fasta > ${file}.18S.FINAL.fasta
cat blast.${file}.28S.topHit.txt blast.${file}.28Snt.topHit.txt | grep "${taxon}" | perl -anle 'print $F[0]' | sort -u > ${file}.28S.ids
seqtk subseq ${file}_28S_rRNA.fasta ${file}.28S.ids | seqkit sort -l -r > ${file}.28S.${taxon}.fasta
awk "/^>/ {n++} n>1 {exit} 1" ${file}.28S.${taxon}.fasta > ${file}.28S.FINAL.fasta

echo = `date` job $JOB_NAME $SGE_TASK_ID done


