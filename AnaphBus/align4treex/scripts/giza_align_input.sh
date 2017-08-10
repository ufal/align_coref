#!/bin/bash

my_dir="$(dirname "$0")"

source "$my_dir/common.sh"

data_forgiza=$1
extra_forgiza=$2
data_giza=$3

mkdir -p $TMP_DIR

data_size=`zcat $data_forgiza | wc -l`
all_forgiza=$TMP_DIR/all.for_giza.txt.gz
zcat $data_forgiza $extra_forgiza | gzip -c > $all_forgiza
all_giza=$TMP_DIR/all.giza.txt.gz
bin/gizawrapper.pl \
        --tempdir=$TMP_DIR \
        --bindir=$my_dir/../bin "$all_forgiza" \
        --lcol=1 --rcol=2 \
        --keep \
        --dirsym=gdfa,int,left,right,revgdfa | \
    gzip -c > $all_giza
#--continue-dir=$TMP_DIR/gizawrapKZ6X

zcat $all_giza | \
    head -n $data_size | \
    paste <( zcat $data_forgiza | cut -f1 ) - | \
    gzip -c > $data_giza