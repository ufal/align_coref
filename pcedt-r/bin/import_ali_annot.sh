#!/bin/bash

src_tree_list=$1
ali_annot_file=$2
trg_tree_list=$3
aligns=${4:-"cs-en:gold;ru-cs:gold"}

trg_tree_dir=`dirname $trg_tree_list`
mkdir -p $trg_tree_dir
treex -p --jobs=50 \
	Read::Treex from=@$1 \
    Align::Annot::Load from=$ali_annot_file aligns="$aligns" \
    Write::Treex path=$trg_tree_dir storable=1
find $trg_tree_dir -name '*.streex' | xargs basename -a | sort > $trg_tree_list
