#!/bin/bash

my_dir="$(dirname "$0")"

source "$my_dir/common.sh"

inpath=$1
outdir=$2
lpair=$3
spair=$4

# set $lpaircomma, $l1 and $l2
parse_lpair $lpair
parse_spair $spair

mkdir -p $outdir

run_treex -Salign \
    Read::Treex from=$inpath \
    W2W::CopySentence language=$l1 selector=align source_language=$l1 source_selector=$s1 \
    W2W::CopySentence language=$l2 selector=align source_language=$l2 source_selector=$s2 \
    Write::Treex path=$outdir
