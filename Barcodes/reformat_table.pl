#!/usr/bin/env perl

use warnings;
use strict;

open (LIST1, $ARGV[0]) or die "Cannot open input file: $!\n";
open (LIST2, $ARGV[1]) or die "Cannot open input file: $!\n";

my %hash1;
my %hash2;
my @list1;
my @list2;
my $key;
my $value;

while (<LIST1>) {
  chomp;
  @list1 = split(/\t/, $_);
  push @{$hash1{$list1[1]}}, join("\t", @list1[0..$#list1]);
        }

while (<LIST2>) {
  chomp;
  @list2 = split(/\t/, $_);
  $hash2{$list2[0]} = $list2[3];
}

close (LIST1);
close (LIST2);

open (OUTFILE, ">$ARGV[2]") or die "Cannot open output file: $!\n";

foreach $key (sort keys(%hash1)) {
  foreach $value (sort @{$hash1{$key}}) {
    if (exists $hash2{$key}) {
    print OUTFILE "$value\t$hash2{$key}\n";
    }
  else {
    print OUTFILE "$value\tNA\n";
    }
  }
}
