#!/bin/bash

function run_treex {
    if [ ${LRC:-0} -eq 1 ]; then
        mkdir -p $RUN_DIR/treex_runs
        lrc_flag="-p --jobs 50 --priority=0 --mem=10g --workdir=$RUN_DIR/treex_runs/{NNN}-run-{XXXX}"
    fi
    treex $lrc_flag "$@"
}

function parse_lpair {
    lpair=$1
    lpaircomma=`echo $lpair | perl -ne '@p = split /-/, $_; print join ",", map {$_ =~ s/_/-/; $_} @p'`
    l1=`echo $lpaircomma | cut -f1 -d',' | cut -f1 -d'-'`
    l2=`echo $lpaircomma | cut -f2 -d',' | cut -f1 -d'-'`
    s1=align_`echo $lpaircomma | cut -f1 -d',' | perl -ne '@c = split /-/, $_, 2; if (@c < 2) { print "";} else { print $c[1];}'`
    s2=align_`echo $lpaircomma | cut -f2 -d',' | perl -ne '@c = split /-/, $_, 2; if (@c < 2) { print "";} else { print $c[1];}'`
    lpaircomma=$l1"-"$s1","$l2"-"$s2
}

function parse_spair {
    spair=$1
    s1=`echo $spair | cut -f1 -d'-'`
    s2=`echo $spair | cut -f2 -d'-'`
}

function parse_lpair_spair {
    lpair=$1
    spair=$2
    if [ -z "$spair" ]; then
        l1=`echo $lpair | cut -f1 -d'-' | perl -ne '@p = split /_/, $_, 2; print $p[0];'`
        l2=`echo $lpair | cut -f2 -d'-' | perl -ne '@p = split /_/, $_, 2; print $p[0];'`
        s1=`echo $lpair | cut -f1 -d'-' | perl -ne '@c = split /_/, $_, 2; if (@c < 2) { print "";} else { print $c[1];}'`
        s2=`echo $lpair | cut -f2 -d'-' | perl -ne '@c = split /_/, $_, 2; if (@c < 2) { print "";} else { print $c[1];}'`
        aligns1=align$s1
        aligns2=align$s2
        lpaircomma=$l1"-"$aligns1","$l2"-"$aligns2
    else
        l1=`echo $lpair | cut -f1 -d'-' | perl -ne '@p = split /_/, $_, 2; print $p[0];'`
        l2=`echo $lpair | cut -f2 -d'-' | perl -ne '@p = split /_/, $_, 2; print $p[0];'`
        s1=`echo $spair | cut -f1 -d'-' | perl -ne '@p = split /_/, $_, 2; print $p[0];'`
        s2=`echo $spair | cut -f2 -d'-' | perl -ne '@p = split /_/, $_, 2; print $p[0];'`
        aligns1=align$s1
        aligns2=align$s2
        lpaircomma=$l1"-"$aligns1","$l2"-"$aligns2
    fi
}
