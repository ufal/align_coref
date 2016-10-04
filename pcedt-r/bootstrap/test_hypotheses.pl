#!/usr/bin/env perl

use strict;
use warnings;

use Statistics::Robust::Bootstrap;

sub hypothesis1_cs {
    my ($data) = @_;

    my $all_count = scalar @$data;
    my $cs_poss_rfl_or_en_poss_count = grep {$_->[0] =~ /CS:(<POSS>|<RFL>)/ || $_->[1] =~ /EN:(<POSS>|<RFL>)/} @$data;
    my $cs_poss_rfl_count = grep {$_->[0] =~ /CS:(<POSS>|<RFL>)/} @$data;
    my $en_poss_rfl_count = grep {$_->[1] =~ /EN:(<POSS>|<RFL>)/} @$data;

    my $score = ($cs_poss_rfl_count / $all_count) - ($en_poss_rfl_count / $all_count);
    #printf STDERR "%d, %d, %d: %.5f\n", $all_count, $cs_poss_rfl_count, $en_poss_rfl_count, $score;
    
    #$score = ($cs_poss_rfl_count / $cs_poss_rfl_or_en_poss_count) - ($en_poss_rfl_count / $cs_poss_rfl_or_en_poss_count);
    #printf STDERR "%d, %d, %d: %.5f\n", $cs_poss_rfl_or_en_poss_count, $cs_poss_rfl_count, $en_poss_rfl_count, $score;

    return $score;
}

sub hypothesis1_ru {
    my ($data) = @_;

    my $all_count = scalar @$data;
    my $ru_poss_rfl_count = grep {$_->[2] =~ /RU:(<POSS>|<RFL>)/} @$data;
    my $en_poss_rfl_count = grep {$_->[1] =~ /EN:(<POSS>|<RFL>)/} @$data;

    my $score = ($ru_poss_rfl_count / $all_count) - ($en_poss_rfl_count / $all_count);

    return $score;
}

sub hypothesis2_cs {
    my ($data) = @_;

    my @en_poss = grep {$_->[1] =~ /EN:(<POSS>|<RFL>)/} @$data;
    my @en_poss_cs_poss_rfl = grep {$_->[0] =~ /CS:(<POSS>|<RFL>)/} @en_poss;

    my @cs_poss_rfl = grep {$_->[0] =~ /CS:(<POSS>|<RFL>)/} @$data;
    my @cs_poss_rfl_en_poss = grep {$_->[1] =~ /EN:(<POSS>|<RFL>)/} @cs_poss_rfl;

    my $score = (scalar @en_poss_cs_poss_rfl / scalar @en_poss) - (scalar @cs_poss_rfl_en_poss / scalar @cs_poss_rfl);
    #printf STDERR "%d, %d, %d, %d: %.5f\n", scalar @en_poss_cs_poss_rfl, scalar @en_poss, scalar @cs_poss_rfl_en_poss, scalar @cs_poss_rfl, $score;
    return $score;
}

my @data = ();
while (<STDIN>) {
    chomp $_;
    my @line = split /\t/, $_;
    push @data, [ $line[2], $line[6], $line[10] ];
}

my $boot_n = 10000;
my $boot_alpha = 0.05;

#hypothesis1_cs(\@data);
#hypothesis2_cs(\@data);

my ($low, $high);
($low, $high) = Statistics::Robust::Bootstrap::onesample(\@data, \&hypothesis1_cs, $boot_alpha, $boot_n);
printf "( %.4f, %.4f )\n", $low, $high;
($low, $high) = Statistics::Robust::Bootstrap::onesample(\@data, \&hypothesis1_ru, $boot_alpha, $boot_n);
printf "( %.4f, %.4f )\n", $low, $high;
($low, $high) = Statistics::Robust::Bootstrap::onesample(\@data, \&hypothesis2_cs, $boot_alpha, $boot_n);
printf "( %.4f, %.4f )\n", $low, $high;
