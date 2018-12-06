#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

while (my $line = <STDIN>) {
    chomp $line;
    my @tokens = split / /, $line;
    my @zerosreplaced = map {
        my $punct = "";
        # zero starts with a punctuation
        if ($_ =~ /^(["']+)\#.*$/) {
            $punct .= $1;
            $_ =~ s/^$punct//;
            print STDERR "DBG: ".$punct."\n";
        }
        # zero ends with a punctuation
        if ($_ =~ /^\#.*?([.,;:?!"']+)$/) {
            $punct .= " $1";
            print STDERR "DBG: ".$punct."\n";
        }
        $_ =~ s/^\#.*/$punct/;
        $_
    } @tokens;
    my @zerosfiltered = grep {
        $_ !~ /^$/;
    } @zerosreplaced;
    my $i = 0;
    my $no_space_precedes = 0;
    for my $token (@zerosfiltered) {
        print STDERR "$i $no_space_precedes $token\n";
        if ($i > 0 && !$no_space_precedes && $token !~ /^ [.,;:?!"']+$/) {
            print " ";
        }
        $no_space_precedes = 0;
        if ($token =~ /^["']+/) {
            $no_space_precedes = 1;
        }
        $token =~ s/^ //;
        print $token;
        $i++;
    }
    print "\n";
}
