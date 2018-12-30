#!/bin/bash

function run_treex {
    if [ ${LRC:-0} -eq 1 ]; then
        mkdir -p $RUN_DIR/treex_runs
        lrc_flag="-p --jobs 50 --priority=0 --workdir=$RUN_DIR/treex_runs/{NNN}-run-{XXXX}"
    fi
    treex $lrc_flag "$@"
}

function parse_lpair {
    lpair=$1
    lpaircomma=`echo $lpair | sed 's/[-]/,/g'`
    l1=`echo $lpair | cut -f1 -d'-'`
    l2=`echo $lpair | cut -f2 -d'-'`
}

function parse_spair {
    spair=$1
    s1=`echo $spair | cut -f1 -d'-'`
    s2=`echo $spair | cut -f2 -d'-'`
}
