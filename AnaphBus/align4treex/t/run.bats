#!/usr/bin/env bats

@test "prepare data from input files" {
    #skip
    infile=$BATS_TEST_DIRNAME/test.treex.gz
    outdir=$BATS_TEST_DIRNAME/data/prepare_input.en-cs

    rm -rf $outdir
    mkdir -p $outdir

    [ -e $infile ]
    lines=`zcat $infile | grep '<zone.*selector="align"' | wc -l`
    [ "$lines" -eq 0 ]
    en_tokens=`zcat $infile | \
        perl -ne 'BEGIN { $ok = 0; } if ($_ =~ /<zone.*language="en"/) { $ok = 1; } if ($_ =~ /<\/zone>/) { $ok = 0; } if ($ok) {print $_;}' | \
        grep "<afun>" | wc -l`
    [ "$en_tokens" -eq 37 ]

    inpath='!'$infile

    export TMP_DIR=$outdir
    run scripts/prepare_input.sh $inpath $outdir en-cs
    [ "$status" -eq 0 ]
    [ -e $outdir/test.treex.gz ]
    in_sents=`zcat $infile | grep '<zones>' | wc -l`
    out_sents=`zcat $outdir/test.treex.gz | grep '<zones>' | wc -l`
    [ "$out_sents" -eq "$in_sents" ]
    en_tokens=`zcat $outdir/test.treex.gz | \
        perl -ne 'BEGIN { $ok = 0; } if ($_ =~ /<zone.*language="en".*selector="align"/) { $ok = 1; } if ($_ =~ /<\/zone>/) { $ok = 0; } if ($ok) {print $_;}' | \
        grep "<tag>" | wc -l`
    # +1 token, since "Co." is automatically tokenized as "Co" and "."
    [ "$en_tokens" -eq 38 ]
}

@test "find word alignment by GIZA for the input file ready for GIZA" {
    in_forgiza=$BATS_TEST_DIRNAME/test.for_giza.txt.gz
    extra_forgiza=$BATS_TEST_DIRNAME/extra.for_giza.txt.gz
    out_giza=$BATS_TEST_DIRNAME/data/giza_align_input.en-cs/test.giza.txt.gz

    export TMP_DIR=$(dirname $out_giza)
    echo run scripts/giza_align_input.sh $in_forgiza $extra_forgiza $out_giza >&2
    run scripts/giza_align_input.sh $in_forgiza $extra_forgiza $out_giza
    [ "$status" -eq 0 ]
    [ -e $out_giza ]
    in_lines=`zcat $in_forgiza | wc -l`
    out_lines=`zcat $out_giza | wc -l`
    [ $in_lines -eq $out_lines ]
}

@test "all" {
    skip
}
