#!/bin/bash

my_dir="$(dirname "$0")"

source "$my_dir/common.sh"

inpath=$1
outfile=$2
lpair=$3
max_tokens=${4:-0}

# set $lpaircomma, $l1 and $l2
parse_lpair $lpair

run_treex \
    Read::Treex from=$inpath \
    Write::LemmatizedBitexts selector=align language=$l1 to_language=$l2 to_selector=align max_tokens=$max_tokens | \
gzip -c > $outfile
