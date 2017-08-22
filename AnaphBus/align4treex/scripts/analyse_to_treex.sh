#!/bin/bash

my_dir="$(dirname "$0")"

source "$my_dir/common.sh"

inpath=$1
outdir=$2
lpair=$3
tokenize=$4

# set $lpaircomma, $l1 and $l2
parse_lpair $lpair

mkdir -p $outdir

indir=${inpath#!}
indir=`dirname "$indir"`
inre="$indir/(.*)\.txt$"
outre="$outdir/"'$1.treex.gz'

reader="Read::SentencesTSV from=$inpath langs=$lpaircomma"
if [[ "$inpath" == *.treex.gz ]]; then
    reader="Read::Treex from=$inpath"
    inre="$indir/(.*)\.treex.gz$"
fi

l1_scen=`$my_dir/../scenario/$l1.lemmatize.sh $tokenize`
l2_scen=`$my_dir/../scenario/$l2.lemmatize.sh $tokenize`

run_treex -Salign \
    $reader skip_finished="{$inre}{$outre}" \
    $l1_scen \
    $l2_scen \
    Write::Treex path=$outdir
