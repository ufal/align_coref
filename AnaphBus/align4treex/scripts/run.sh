#!/bin/bash

my_dir="$(dirname "$0")"

source "$my_dir/common.sh"

inpath=$1
outdir=$2
lpair=$3
spair=$4

echo "Running word alignment on given data..." >&2

# SET WORKING DIRECTORIES

if [ -z "$RUN_DIR" ]; then
    runs_dir=${TMPDIR:-/tmp}/align4treex
    date=`date +%Y-%m-%d_%H-%M-%S`
    iter=`perl -e '$m=0; for(<$ARGV[0]/*>){/\/(\d+)_/ and $1 > $m and $m=$1;} printf "%03d", $m+1;' $runs_dir`
    pattern=$iter'_'$date'_XXXXX'
    mkdir -p $runs_dir
    export RUN_DIR=`mktemp -d --tmpdir=$runs_dir $pattern`
    echo "Working directory: $RUN_DIR" >&2
fi
if [ -z "$EXTRA_DIR" ]; then
    export EXTRA_DIR=$my_dir/../extra/$lpair
    echo "Extra data directory: $EXTRA_DIR" >&2
fi

# PREPARE EXTRA DATA

extra_params="LPAIR=$lpair"
extra_params+=" EXTRA_DIR=$EXTRA_DIR"
if [ -n "$EXTRA_SPLIT_SIZE" ]; then
    extra_params+=" SPLIT_SIZE=$EXTRA_SPLIT_SIZE"
fi
if [ -n "$EXTRA_MAX_TOKENS" ]; then
    extra_params+=" MAX_TOKENS=$EXTRA_MAX_TOKENS"
fi
if [ -n "$EXTRA_SAMPLE_PERC" ]; then
    extra_params+=" SAMPLE_PERC=$EXTRA_SAMPLE_PERC"
fi
make -f $my_dir/makefile.extra_data for_giza $extra_params
extra_forgiza=`make -s -f $my_dir/makefile.extra_data path_for_giza $extra_params`

# PREPARE INPUT

prepared_data_dir=$RUN_DIR/02.analysed
$my_dir/prepare_input.sh $inpath $prepared_data_dir $lpair $spair 

prepared_data_path='!'$prepared_data_dir'/*.treex.gz'
data_forgiza=$RUN_DIR/03.for_giza/data.txt.gz
$my_dir/print_lemmatized_bitext.sh $prepared_data_path $data_forgiza $lpair $MAX_TOKENS

# RUN GIZA

data_giza=$RUN_DIR/04.giza/data.txt.gz
$my_dir/giza_align_input.sh $data_forgiza $extra_forgiza $data_giza

# IMPORT ALIGNMENTS AND FINALIZE

$my_dir/finalize_input.sh $prepared_data_path $data_giza $outdir $lpair $spair
