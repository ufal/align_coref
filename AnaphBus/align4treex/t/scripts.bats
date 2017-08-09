#!/usr/bin/env bats

@test "analysing sample en-cs text" {
    indir=$BATS_TEST_DIRNAME/data/analyse.en-cs
    outdir=$BATS_TEST_DIRNAME/data/analyse.en-cs
    rm -rf $indir $outdir
    mkdir -p $indir $outdir 
    
    echo "This is just a test.	Toto je pouze zkouška." > $indir/1.txt
    echo "John loves Mary.	Jan miluje Marii." > $indir/2.txt
    
    inpath='!'$indir'/*.txt'
    
    run scripts/analyse_to_treex.sh $inpath $outdir en-cs
    [ "$status" -eq 0 ]

    [ -e $outdir/1.treex.gz ]
    lemmas=`zcat $outdir/1.treex.gz | grep "<lemma>" | wc -l`
    [ "$lemmas" -eq 11 ]
    
    [ -e $outdir/2.treex.gz ]
    lemmas=`zcat $outdir/2.treex.gz | grep "<lemma>" | wc -l`
    [ "$lemmas" -eq 8 ]
}

@test "extracting lemmatized bitext for en-cs document" {
    indir=$BATS_TEST_DIRNAME/data/analyse.en-cs
    outdir=$BATS_TEST_DIRNAME/data/extract_for_giza.en-cs

    rm -rf $outdir
    mkdir -p $outdir

    inpath='!'$indir'/*.treex.gz'

    run scripts/print_lemmatized_bitext.sh $inpath $outdir/for_giza.gz en-cs 4
    [ -e $outdir/for_giza.gz ]
    lines=`zcat $outdir/for_giza.gz | wc -l`
    [ "$lines" -eq 1 ]
    tokens=`zcat $outdir/for_giza.gz | cut -f2,3 | wc -w`
    [ "$tokens" -eq 8 ]
}