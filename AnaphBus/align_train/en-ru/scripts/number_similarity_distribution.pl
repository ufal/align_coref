#!/usr/bin/env perl

use strict;
use warnings;
use Text::Levenshtein qw(distance);

my $i = 0;
while (<STDIN>) {
    chomp $_;
    my ($id, @cols) = split /\t/, $_;
    foreach my $col (@cols) {
        $col =~ s/\D+/ /g;
    }
    my $str = join "\t", @cols;
    if ($str =~ /\S/) {
        printf "%d\t%d\n", $i, distance(@cols);
    }
    $i++;
}
