#!/bin/bash

inpath=$1
data_giza=$2
outdir=$3
lpair=$4

export RUN_DIR=tmp/import_align_alternative/$lpair
mkdir -p $RUN_DIR

align4treex="/home/mnovak/projects/align_coref/AnaphBus/align4treex/scripts"

$align4treex/prepare_input.sh $inpath $RUN_DIR/prepared_input $lpair

zcat $data_giza | \
    perl -ne 'chomp $_; my ($id, @cols) = split /\t/, $_; $id =~ s{-s}{.treex.gz-s}; $id = $ENV{RUN_DIR}."/prepared_input/".$id; print join "\t", ($id, @cols); print "\n";' | \
    gzip -c > $RUN_DIR/data_giza.txt.gz

$align4treex/finalize_input.sh '!'$RUN_DIR/prepared_input/'*.treex.gz' $RUN_DIR/data_giza.txt.gz $outdir $lpair
