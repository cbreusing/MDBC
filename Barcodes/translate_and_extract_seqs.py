#! /usr/bin/env python3

from Bio.Seq import Seq
from Bio import SeqIO
from Bio.SeqRecord import SeqRecord
import argparse

parser = argparse.ArgumentParser(description="Find the best translation for a single nucleotide sequence and extract the corresponding amino acid and CDS sequences.")
parser.add_argument("filename", type=str, help="The path to the input FASTA file containing one sequence entry.")
parser.add_argument("-t", "--table", type=int, help="The codon table in NCBI number code.")
parser.add_argument("-p", "--protein", type=str, help="The path to the output amino acid FASTA file.")
parser.add_argument("-o", "--output", type=str, help="The path to the output CDS FASTA file.")

args = parser.parse_args()

dna = SeqIO.read(args.filename, "fasta")
dna_rc = dna.reverse_complement()
codon_table = args.table

aa = []
ind = []
for i in range(0, 3):
  prots = [dna.seq[i:len(dna.seq)].translate(table=codon_table), dna_rc.seq[i:len(dna_rc.seq)].translate(table=codon_table)]
  for prot in prots:
    max_prot = max(prot.split("*"), key=len)
    start_index = prot.find(max_prot) * 3 + i
    stop_index = len(max_prot) * 3 + start_index
    aa.append(max_prot)
    ind.append([start_index, stop_index])

final_aa = max(aa, key=len)
final_ind = ind[aa.index(final_aa)]

if aa.index(final_aa) % 2 == 0:
  final_dna = dna.seq[final_ind[0]:final_ind[1]]
else:
  final_dna = dna_rc.seq[final_ind[0]:final_ind[1]]

aa_record = SeqRecord(
    Seq(final_aa),
    id=dna.id,
    name="",
    description="",)

dna_record = SeqRecord(
    Seq(final_dna),
    id=dna.id,
    name="",
    description="",)

SeqIO.write(aa_record, args.protein, "fasta")
SeqIO.write(dna_record, args.output, "fasta")