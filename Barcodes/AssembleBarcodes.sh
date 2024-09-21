# /bin/sh
#$ -S /bin/sh
#$ -q sThM.q
#$ -pe mthread 16
#$ -l mres=256G,h_data=16G,h_vmem=16G,himem
#$ -l ssd_res=200G -v SSD_SAVE_MAX=0
#$ -cwd
#$ -j y
#$ -N AssembleBarcodes
#$ -o AssembleBarcodes_$TASK_ID.log
#$ -t 1-1032 -tc 10

module load bio/bbmap
module load bio/spades
module load bio/blast
module load tools/ssd

# Run this only once to prepare reference databases for BBMap
#bbmap.sh ref=/scratch/dbs/blast/bold/fasta/bold_coi_2023_05_12.fasta build=1 
#bbmap.sh ref=/scratch/nmnh_mdbc/breusingc/databases/SILVA_138.1_SSURef_NR99_tax_silva_trunc.fasta build=2 
#bbmap.sh ref=/scratch/nmnh_mdbc/breusingc/databases/SILVA_138.1_LSURef_NR99_tax_silva_trunc.fasta build=3 

FILE=$(sed -n "${SGE_TASK_ID}p" filelist.txt | perl -anle 'print $F[0]')

#Extract COI reads
bbmap.sh build=1 t=${NSLOTS} in=../${FILE}_R1_clean.fastq in2=../${FILE}_R2_clean.fastq ambiguous=best pairedonly=t outm=${FILE}_COI_#.fastq
repair.sh in1=${FILE}_COI_1.fastq in2=${FILE}_COI_2.fastq out1=${FILE}_COIfixed_1.fastq out2=${FILE}_COIfixed_2.fastq repair
mv ${FILE}_COIfixed_1.fastq ${FILE}_COI_1.fastq
mv ${FILE}_COIfixed_2.fastq ${FILE}_COI_2.fastq
metaspades.py -1 ${FILE}_COI_1.fastq -2 ${FILE}_COI_2.fastq -t ${NSLOTS} -o spades_${FILE}_COI --tmp-dir $SSD_DIR/${FILE}_COI
mv spades_${FILE}_COI/scaffolds.fasta ${FILE}_COI.fasta
rm -r spades_${FILE}_COI
blastn -query ${FILE}_COI.fasta -db /scratch/dbs/blast/bold/bold_blast_2023_05_12 -out blast.${FILE}.COI.txt -evalue 1e-10 -num_threads ${NSLOTS} -max_target_seqs 1 -outfmt 6
cat blast.${FILE}.COI.txt | sort -k1,1 -k12,12nr -k11,11n | sort -u -k1,1 > blast.${FILE}.COI.topHit.txt
perl /home/breusingc/scripts/reformat_table.pl blast.${FILE}.COI.topHit.txt /scratch/nmnh_mdbc/breusingc/databases/bold_coi_2023_05_12.txt blast.${FILE}.COI.topHit.full.txt
mv blast.${FILE}.COI.topHit.full.txt blast.${FILE}.COI.topHit.txt
rm blast.${FILE}.COI.txt
blastn -query ${FILE}_COI.fasta -db /scratch/dbs/blast/v5/mito -out blast.${FILE}.mito.txt -evalue 1e-10 -num_threads ${NSLOTS} -max_target_seqs 1 -outfmt "6 std stitle staxids"
cat blast.${FILE}.mito.txt | sort -k1,1 -k12,12nr -k11,11n | sort -u -k1,1 > blast.${FILE}.mito.topHit.txt
perl /home/breusingc/scripts/reformat_table2.pl blast.${FILE}.mito.topHit.txt /scratch/nmnh_mdbc/breusingc/databases/taxdump/taxids2lineage.txt blast.${FILE}.mito.topHit.full.txt
mv blast.${FILE}.mito.topHit.full.txt blast.${FILE}.mito.topHit.txt
rm blast.${FILE}.mito.txt

#Extract 18S reads
bbmap.sh build=2 t=${NSLOTS} in=../${FILE}_R1_clean.fastq in2=../${FILE}_R2_clean.fastq ambiguous=best pairedonly=t outm=${FILE}_18S_#.fastq
repair.sh in1=${FILE}_18S_1.fastq in2=${FILE}_18S_2.fastq out1=${FILE}_18Sfixed_1.fastq out2=${FILE}_18Sfixed_2.fastq repair
mv ${FILE}_18Sfixed_1.fastq ${FILE}_18S_1.fastq
mv ${FILE}_18Sfixed_2.fastq ${FILE}_18S_2.fastq
metaspades.py -1 ${FILE}_18S_1.fastq -2 ${FILE}_18S_2.fastq -t ${NSLOTS} -o spades_${FILE}_18S --tmp-dir $SSD_DIR/${FILE}_18S
mv spades_${FILE}_18S/scaffolds.fasta ${FILE}_18S.fasta
rm -r spades_${FILE}_18S
blastn -query ${FILE}_18S.fasta -db /scratch/nmnh_mdbc/breusingc/databases/SILVA_138.1_SSURef_NR99 -out blast.${FILE}.18S.txt -evalue 1e-10 -num_threads ${NSLOTS} -max_target_seqs 1 -outfmt "6 std stitle"
cat blast.${FILE}.18S.txt | sort -k1,1 -k12,12nr -k11,11n | sort -u -k1,1 > blast.${FILE}.18S.topHit.txt
rm blast.${FILE}.18S.txt
blastn -query ${FILE}_18S.fasta -db /scratch/dbs/blast/v5/nt -out blast.${FILE}.18Snt.txt -evalue 1e-10 -num_threads ${NSLOTS} -max_target_seqs 1 -outfmt "6 std stitle staxids"
cat blast.${FILE}.18Snt.txt | sort -k1,1 -k12,12nr -k11,11n | sort -u -k1,1 > blast.${FILE}.18Snt.topHit.txt
perl /home/breusingc/scripts/reformat_table2.pl blast.${FILE}.18Snt.topHit.txt /scratch/nmnh_mdbc/breusingc/databases/taxdump/taxids2lineage.txt blast.${FILE}.18Snt.topHit.full.txt
mv blast.${FILE}.18Snt.topHit.full.txt blast.${FILE}.18Snt.topHit.txt

#Extract 28S reads
bbmap.sh build=3 t=${NSLOTS} in=../${FILE}_R1_clean.fastq in2=../${FILE}_R2_clean.fastq ambiguous=best pairedonly=t outm=${FILE}_28S_#.fastq
repair.sh in1=${FILE}_28S_1.fastq in2=${FILE}_28S_2.fastq out1=${FILE}_28Sfixed_1.fastq out2=${FILE}_28Sfixed_2.fastq repair
mv ${FILE}_28Sfixed_1.fastq ${FILE}_28S_1.fastq
mv ${FILE}_28Sfixed_2.fastq ${FILE}_28S_2.fastq
metaspades.py -1 ${FILE}_28S_1.fastq -2 ${FILE}_28S_2.fastq -t ${NSLOTS} -o spades_${FILE}_28S --tmp-dir $SSD_DIR/${FILE}_28S
mv spades_${FILE}_28S/scaffolds.fasta ${FILE}_28S.fasta
rm -r spades_${FILE}_28S
blastn -query ${FILE}_28S.fasta -db /scratch/nmnh_mdbc/breusingc/databases/SILVA_138.1_LSURef_NR99 -out blast.${FILE}.28S.txt -evalue 1e-10 -num_threads ${NSLOTS} -max_target_seqs 1 -outfmt "6 std stitle"
cat blast.${FILE}.28S.txt | sort -k1,1 -k12,12nr -k11,11n | sort -u -k1,1 > blast.${FILE}.28S.topHit.txt
rm blast.${FILE}.28S.txt
blastn -query ${FILE}_28S.fasta -db /scratch/dbs/blast/v5/nt -out blast.${FILE}.28Snt.txt -evalue 1e-10 -num_threads ${NSLOTS} -max_target_seqs 1 -outfmt "6 std stitle staxids"
cat blast.${FILE}.28Snt.txt | sort -k1,1 -k12,12nr -k11,11n | sort -u -k1,1 > blast.${FILE}.28Snt.topHit.txt
perl /home/breusingc/scripts/reformat_table2.pl blast.${FILE}.28Snt.topHit.txt /scratch/nmnh_mdbc/breusingc/databases/taxdump/taxids2lineage.txt blast.${FILE}.28Snt.topHit.full.txt
mv blast.${FILE}.28Snt.topHit.full.txt blast.${FILE}.28Snt.topHit.txt

echo = `date` job $JOB_NAME $SGE_TASK_ID done
