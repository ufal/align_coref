#!/usr/bin/env perl

use strict;
use warnings;
use Data::Printer;

sub rw_header {
    my ($out_fh, @in_fhs) = @_;

    for (my $i = 0; $i < @in_fhs; $i++) {
        my $in_fh = $in_fhs[$i];
        while (my $line = <$in_fh>) {
            print {$out_fh} $line if (!$i);
            last if ($line =~ /^\s*<bundles>\s*$/);
        }
    }
}

sub rw_bundles {
    my ($out_fh, @in_fhs) = @_;

    my $bundles_finished = 0;
    while (!$bundles_finished) {

        for (my $i = 0; $i < @in_fhs; $i++) {
            my $in_fh = $in_fhs[$i];

            my $bundles_in_file_finished = 0;

            while (my $line = <$in_fh>) {
                print {$out_fh} $line if (!$i);
                last if ($line =~ /^\s*<zones>\s*$/);
                if ($line =~ /^\s*<\/bundles>\s*$/) {
                    $bundles_in_file_finished = 1;
                    last;
                }
            }
            
            if (!$bundles_in_file_finished) {
                while (my $line = <$in_fh>) {
                    if ($line =~ /^\s*<\/zones>\s*$/) {
                        print {$out_fh} $line if ($i == $#in_fhs);
                        last;
                    }
                    print {$out_fh} $line;
                }
            }
            else {
                $bundles_finished = 1 if ($i == $#in_fhs);
            }
        }
    }
}

sub rw_footer {
    my ($out_fh, @in_fhs) = @_;
    for (my $i = 0; $i < @in_fhs; $i++) {
        my $in_fh = $in_fhs[$i];
        while (my $line = <$in_fh>) {
            print {$out_fh} $line if (!$i);
        }
    }
}

my $out_file = shift @ARGV;
my @in_files = @ARGV;

open my $out_fh, ">:gzip:utf8", $out_file;
my @in_fhs = map { open my $fh, "<:gzip:utf8", $_; $fh } @in_files;

rw_header($out_fh, @in_fhs);
rw_bundles($out_fh, @in_fhs);
rw_footer($out_fh, @in_fhs);

close $_ for (@in_fhs);
