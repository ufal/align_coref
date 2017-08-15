#!/bin/bash

my_dir="$(dirname "$0")"

source "$my_dir/common.sh"

inpath=$1
outdir=$2
lpair=$3

# set $lpaircomma, $l1 and $l2
parse_lpair $lpair

mkdir -p $outdir

reader="Read::SentencesTSV from=$inpath langs=$lpaircomma"
if [[ "$inpath" == *.treex.gz ]]; then
    reader="Read::Treex from=$inpath"
fi

run_treex -Salign \
    $reader \
    $my_dir/../scenario/$l1.lemmatize.scen \
    $my_dir/../scenario/$l2.lemmatize.scen \
    Write::Treex path=$outdir
