#!/usr/bin/env perl

use strict;
use warnings;

binmode STDOUT, ":utf8";

my $for_giza_path = $ARGV[0];
my $giza_path = $ARGV[1];

open my $for_giza_fh, "<:utf8", $for_giza_path;
open my $giza_fh, "<:utf8", $giza_path;

while (my $fg_line = <$for_giza_fh>) {
    chomp $fg_line;
    my ($fg_id, $en_sent, $ru_sent) = split /\t/, $fg_line;
    my @en_words = split / /, $en_sent;
    my @ru_words = split / /, $ru_sent;
    my $g_line = <$giza_fh>;
    chomp $g_line;
    my ($g_id, $gdfa, @rest) = split /\t/, $g_line;
    my @aligns = map { [ split /-/, $_ ]} (split / /, $gdfa);

    foreach my $align (@aligns) {
        printf "%s\t%s\n", $en_words[$align->[0]], $ru_words[$align->[1]];
    }

}
