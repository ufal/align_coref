#!/bin/bash

my_dir="$(dirname "$0")"

source "$my_dir/common.sh"

mkdir -p $RUN_DIR

if [ "$#" -eq 3 ]; then

    data_forgiza=$1
    extra_forgiza=$2
    data_giza=$3

    mkdir -p $(dirname $data_giza)

    data_size=`zcat $data_forgiza | wc -l`
    all_forgiza=$RUN_DIR/all.for_giza.txt.gz
    zcat $data_forgiza $extra_forgiza | gzip -c > $all_forgiza
    all_giza=$RUN_DIR/all.giza.txt.gz
else
    all_forgiza=$1
    all_giza=$2
fi

$my_dir/../bin/gizawrapper.pl \
        --tempdir=$RUN_DIR \
        --bindir=$my_dir/../bin "$all_forgiza" \
        --lcol=1 --rcol=2 \
        --keep \
        --dirsym=gdfa,int,left,right,revgdfa | \
    gzip -c > $all_giza
#--continue-dir=$RUN_DIR/gizawrapKZ6X

if [ -n "$data_giza" ]; then
    zcat $all_giza | \
        head -n $data_size | \
        paste <( zcat $data_forgiza | cut -f1 ) - | \
        gzip -c > $data_giza
fi
