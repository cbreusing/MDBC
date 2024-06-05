# /bin/sh
#$ -S /bin/sh
#$ -q sThC.q
#$ -pe mthread 24
#$ -l mres=96G,h_data=4G,h_vmem=4G
#$ -cwd
#$ -j y
#$ -N AssembleBarcodes
#$ -o AssembleBarcodes_$TASK_ID.log
#$ -t 1-378 -tc 10

module load bio/bbmap
module load bio/spades
module load bio/blast

# Run this only once to prepare reference databases for BBMap
#bbmap.sh ref=/scratch/dbs/blast/bold/fasta/bold_coi_2023_05_12.fasta build=1 
#bbmap.sh ref=/scratch/nmnh_mdbc/breusingc/databases/SILVA_138.1_SSURef_NR99_tax_silva_trunc.fasta build=2 
#bbmap.sh ref=/scratch/nmnh_mdbc/breusingc/databases/SILVA_138.1_LSURef_NR99_tax_silva_trunc.fasta build=3 

FILE=$(sed -n "${SGE_TASK_ID}p" filelist.txt | perl -anle 'print $F[0]')

#Extract COI reads
bbmap.sh build=1 t=${NSLOTS} in=${FILE}_R1_clean.fastq in2=${FILE}_R2_clean.fastq ambiguous=best pairedonly=t outm=${FILE}_COI_#.fastq
metaspades.py -1 ${FILE}_COI_1.fastq -2 ${FILE}_COI_2.fastq -t ${NSLOTS} -o spades_${FILE}_COI
blastn -query spades_${FILE}_COI/scaffolds.fasta -db /scratch/dbs/blast/bold/bold_blast_2023_05_12 -out blast.${FILE}.COI.txt -evalue 1e-10 -num_threads ${NSLOTS} -max_target_seqs 1 -outfmt 6
cat blast.${FILE}.COI.txt | sort -k1,1 -k12,12nr -k11,11n | sort -u -k1,1 > blast.${FILE}.COI.topHit.txt
perl /home/breusingc/scripts/reformat_table.pl blast.${FILE}.COI.topHit.txt /scratch/nmnh_mdbc/breusingc/databases/bold_coi_2023_05_12.txt blast.${FILE}.COI.topHit.full.txt
rm blast.${FILE}.COI.txt
rm blast.${FILE}.COI.topHit.txt
blastn -query spades_${FILE}_COI/scaffolds.fasta -db /scratch/dbs/blast/v5/mito -out blast.${FILE}.mito.txt -evalue 1e-10 -num_threads ${NSLOTS} -max_target_seqs 1 -outfmt "6 std stitle staxids"
cat blast.${FILE}.mito.txt | sort -k1,1 -k12,12nr -k11,11n | sort -u -k1,1 > blast.${FILE}.mito.topHit.txt
perl /home/breusingc/scripts/reformat_table2.pl blast.${FILE}.mito.topHit.txt /scratch/nmnh_mdbc/breusingc/databases/taxdump/taxids2lineage.txt blast.${FILE}.mito.topHit.full.txt
rm blast.${FILE}.mito.txt
rm blast.${FILE}.mito.topHit.txt

#Extract 18S reads
bbmap.sh build=2 t=${NSLOTS} in=${FILE}_R1_clean.fastq in2=${FILE}_R2_clean.fastq ambiguous=best pairedonly=t outm=${FILE}_18S_#.fastq
metaspades.py -1 ${FILE}_18S_1.fastq -2 ${FILE}_18S_2.fastq -t ${NSLOTS} -o spades_${FILE}_18S
blastn -query spades_${FILE}_18S/scaffolds.fasta -db /scratch/nmnh_mdbc/breusingc/databases/SILVA_138.1_SSURef_NR99 -out blast.${FILE}.18S.txt -evalue 1e-10 -num_threads ${NSLOTS} -max_target_seqs 1 -outfmt "6 std stitle"
cat blast.${FILE}.18S.txt | sort -k1,1 -k12,12nr -k11,11n | sort -u -k1,1 > blast.${FILE}.18S.topHit.txt
rm blast.${FILE}.18S.txt

#Extract 28S reads
bbmap.sh build=3 t=${NSLOTS} in=${FILE}_R1_clean.fastq in2=${FILE}_R2_clean.fastq ambiguous=best pairedonly=t outm=${FILE}_28S_#.fastq
metaspades.py -1 ${FILE}_28S_1.fastq -2 ${FILE}_28S_2.fastq -t ${NSLOTS} -o spades_${FILE}_28S
blastn -query spades_${FILE}_28S/scaffolds.fasta -db /scratch/nmnh_mdbc/breusingc/databases/SILVA_138.1_LSURef_NR99 -out blast.${FILE}.28S.txt -evalue 1e-10 -num_threads ${NSLOTS} -max_target_seqs 1 -outfmt "6 std stitle"
cat blast.${FILE}.28S.txt | sort -k1,1 -k12,12nr -k11,11n | sort -u -k1,1 > blast.${FILE}.28S.topHit.txt
rm blast.${FILE}.28S.txt
