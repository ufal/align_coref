#!/bin/bash

my_dir="$(dirname "$0")"

source "$my_dir/common.sh"

treex_path=$1
align_path=$2
outdir=$3
lpair=$4
spair=$5

# set $lpaircomma, $l1 and $l2
parse_lpair $lpair
parse_spair $spair

run_treex \
    Read::Treex from=$treex_path \
    Align::A::InsertAlignmentFromFile language=$l1 selector=align to_language=$l2 to_selector=align \
        from=$align_path inputcols=gdfa_int_therescore_backscore \
    Align::A::MonolingualGreedy language=$l1 selector=align to_language=$l1 to_selector=$s1 \
    Align::A::MonolingualGreedy language=$l2 selector=align to_language=$l2 to_selector=$s2 \
    Align::ProjectAlignment layer=a selector=align trg_selector=$s1 aligns="$l1-$l2:.*" \
    Util::Eval bundle='$bundle->remove_zone("'$l1'", "align");' \
    Util::Eval bundle='$bundle->remove_zone("'$l2'", "align");' \
    Write::Treex path=$outdir
