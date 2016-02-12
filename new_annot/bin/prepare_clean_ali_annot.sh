#!/bin/bash

src_tree_list=$1
language=$2
selector=$3
layers=$4
node_types=$5
align_langs=$6

treex -p --jobs=50 -L$language -S$selector \
    Read::Treex from=@$src_tree_list \
	Align::Annot::Print layers=$layers align_langs=$align_langs node_types=$node_types
