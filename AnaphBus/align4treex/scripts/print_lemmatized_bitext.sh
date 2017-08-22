#!/bin/bash

my_dir="$(dirname "$0")"

source "$my_dir/common.sh"

inpath=$1
outfile=$2
lpair=$3
max_tokens=${4:-0}

# set $lpaircomma, $l1 and $l2
parse_lpair $lpair

mkdir -p $(dirname $outfile)
mkdir -p $RUN_DIR/for_giza.files

indir=${inpath#!}
indir=`dirname "$indir"`
inre="$indir/(.*)\.treex.gz$"
outre="$RUN_DIR/for_giza.files/"'$1.txt'

run_treex \
    Read::Treex from=$inpath skip_finished="{$inre}{$outre}" \
    Write::LemmatizedBitexts path=$RUN_DIR/for_giza.files extension=.txt selector=align language=$l1 to_language=$l2 to_selector=align max_tokens=$max_tokens
find $RUN_DIR/for_giza.files -name '*.txt' | sort | xargs cat | gzip -c > $outfile
