#!/bin/bash

# ./coverage.sh <coref_file> <align_annot_file> <expr_type>
# ./covergae.sh en.coref_nodes.ref.sec19_00-49 en_perspron/align.ref.sec19_00-49.all.ali_annot en_perspron
coref_file=$1
align_annot_file=$2
expr_type=$3


function perc {
    perl -e 'my ($a, $b) = @ARGV; printf "%.2f%% (%d/%d)\n", $a / $b * 100, $a, $b;' $1 $2
}

tmp_dir=/COMP.TMP/coref_align_coverage
mkdir $tmp_dir

cat $coref_file | cut -f1,5 | sed 's/\/.*\///g' | sed 's/treex\.gz/streex/' | sort -k2,2 > $tmp_dir/coref.ids
cat $align_annot_file |  sed -n '1~7p' | sed 's/^.*\///g' | sort > $tmp_dir/sel.ids
join -1 2 $tmp_dir/coref.ids $tmp_dir/sel.ids > $tmp_dir/both.ids

sel_count=`cat $tmp_dir/sel.ids | wc -l`
coref_count=`cat $tmp_dir/coref.ids | wc -l`
type_count=`cat $tmp_dir/coref.ids | grep "^$expr_type	" | wc -l`
both_count=`cat $tmp_dir/both.ids | wc -l`

#echo -n "Selected: "
#echo $sel_count
#echo -n "Coreferential: "
#echo $coref_count
#echo -n "Coreferential of \"$expr_type\" type: "
#echo $type_count
#echo -n "Coreferential and selected: "
#echo $both_count

echo -n "Coreferential out of selected: "
perc $both_count $sel_count
echo -n "Coverage of all coreferential: "
perc $both_count $coref_count
echo -n "Coverage of coreferential of \"$expr_type\" type: "
perc $both_count $type_count

rm -rf $tmp_dir
