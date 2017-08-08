#!/bin/bash

my_dir="$(dirname "$0")"

source "$my_dir/common.sh"

inpath=$1
outdir=$2
lpair=$3

mkdir -p $outdir

# set $lpaircomma, $l1 and $l2
parse_lpair $lpair

run_treex -Salign \
    Read::SentencesTSV from=$inpath langs=$lpaircomma \
    scenario/$l1.lemmatize.scen \
    scenario/$l2.lemmatize.scen \
    Write::Treex path=$outdir
