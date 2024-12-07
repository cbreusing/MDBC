#! /usr/bin/env perl

use strict;
use warnings;

open (FILE, $ARGV[0]) or die "Cannot open input file: $!\n";
<FILE>;

my @array = ();
my @attr = ();
my $file = $ARGV[0];
my $name = $file =~ s/.merged.gff/.1/r;

print ">$name\n";

while (my $line = <FILE>) {
 if ($line !~ /^#/) {
  @array = split(/\t/, $line);
  @attr = split(/;/, $array[8]);
  unless ($line =~ /Partial/) {
    if ($line =~ /\t-\t/) {
    print "$array[4]\t$array[3]\t$array[2]\n";
    }
    else {
    print "$array[3]\t$array[4]\t$array[2]\n";
    }
  } 
  elsif ($line =~ /5' Partial/) {
    if ($line =~ /\t-\t/) {
    print "<$array[4]\t$array[3]\t$array[2]\n";
    }
    else {
    print "<$array[3]\t$array[4]\t$array[2]\n";
    }
  }
  elsif ($line =~ /3' Partial/) {
    if ($line =~ /\t-\t/) {
    print "$array[4]\t>$array[3]\t$array[2]\n";
    }
    else {
    print "$array[3]\t>$array[4]\t$array[2]\n";
    }
  }
     foreach (@attr) {
     if ($_ !~ /ID/ && $_ !~ /Parent/) {
     $_ =~ s/=/\t/g;
     $_ =~ s/Name/gene/g;
     $_ =~ s/ gene//g;
     print "\t\t\t$_\n";
     }
   }
 }
}

close (FILE);
