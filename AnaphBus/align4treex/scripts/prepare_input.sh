#!/bin/bash

my_dir="$(dirname "$0")"

source "$my_dir/common.sh"

inpath=$1
outdir=$2
lpair=$3
spair=$4

tmp_outdir=$TMP_DIR/01.sents_in_align_sel
$my_dir/copy_sents_to_align_sel.sh $inpath $tmp_outdir $lpair $spair
tmp_inpath='!'$tmp_outdir'/*.treex.gz'
$my_dir/analyse_to_treex.sh $tmp_inpath $outdir $lpair
