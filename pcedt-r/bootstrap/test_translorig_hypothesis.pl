#!/usr/bin/env perl

use strict;
use warnings;

use Statistics::Robust::Bootstrap;

my $all;

sub hypothesis1_cs {
    my ($data) = @_;

    my @orig_data = grep {$_->[0] eq "orig"} @$data;
    my @transl_data = grep {$_->[0] eq "transl"} @$data;

    my @orig_rfl_data = grep {$_->[1] eq "rfl"} @orig_data;
    my @transl_rfl_data = grep {$_->[1] eq "transl"} @orig_data;

    my $score = (@orig_rfl_data / @orig_data) - (@transl_rfl_data / @transl_data);
    printf STDERR "%d, %d, %d, %d: %.5f\n", scalar @orig_rfl_data, scalar @orig_data, scalar @transl_rfl_data, scalar @transl_data, $score;
    
    #$score = ($cs_poss_rfl_count / $cs_poss_rfl_or_en_poss_count) - ($en_poss_rfl_count / $cs_poss_rfl_or_en_poss_count);
    #printf STDERR "%d, %d, %d: %.5f\n", $cs_poss_rfl_or_en_poss_count, $cs_poss_rfl_count, $en_poss_rfl_count, $score;

    return $score;
}

my @data = ();
while (<STDIN>) {
    chomp $_;
    my @line = split /\t/, $_;
    my $source = ($line[0] =~ /pdt30/) ? "orig" : "transl";
    my $type = $line[3] eq "RFLPOSS=1" ? "rfl" :
        $line[4] eq "POSS=1" ? "poss" : "oth";
    push @data, [ $source, $type ];
}

$all = scalar @data;

my $boot_n = 10000;
my $boot_alpha = 0.05;

hypothesis1_cs(\@data);
#hypothesis2_cs(\@data);

#my ($low, $high);
#($low, $high) = Statistics::Robust::Bootstrap::onesample(\@data, \&hypothesis1_cs, $boot_alpha, $boot_n);
#printf "( %.4f, %.4f )\n", $low, $high;
