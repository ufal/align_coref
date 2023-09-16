#!/bin/bash

my_dir="$(dirname "$0")"

source "$my_dir/common.sh"

inpath=$1
outfile=$2
lpair=$3
id=${4:-noid}
max_tokens=${5:-0}

# set $lpaircomma, $l1 and $l2
parse_lpair_spair $lpair

run_dir=$RUN_DIR/for_giza.$id.files

mkdir -p $(dirname $outfile)
mkdir -p $run_dir

indir=${inpath#!}
indir=`dirname "$indir"`
inre="$indir/(.*)\.treex.gz$"
outre="$run_dir/"'$1.txt'

run_treex \
    Read::Treex from=$inpath skip_finished="{$inre}{$outre}" \
    Write::LemmatizedBitexts path=$run_dir extension=.txt selector=$aligns1 language=$l1 to_language=$l2 to_selector=$aligns2 max_tokens=$max_tokens && \
find $run_dir -name '*.txt' | sort | xargs cat | gzip -c > $outfile
