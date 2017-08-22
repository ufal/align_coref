#!/usr/bin/env bats

setup() {
    EXTRADIR=$BATS_TEST_DIRNAME/data/extra
    
    lpair=en-cs
    split_size=5
    max_tokens=17
    sample_perc=50
    extra_name=test
}

@test "creating sample datasets" {
    rm -rf $EXTRADIR
    mkdir -p $EXTRADIR
    mkdir -p $EXTRADIR/00.in

    echo "This is just a test.	Toto je pouze zkouška." >> $EXTRADIR/00.in/1.txt
    gzip $EXTRADIR/00.in/1.txt
    echo "John loves Mary.	Jan miluje Marii." >> $EXTRADIR/00.in/2.txt
    echo "But she doesn't love him.	Ale ona jeho nemiluje." >> $EXTRADIR/00.in/2.txt
    echo "That's really true!	Je to fakt pravda." >> $EXTRADIR/00.in/2.txt
    gzip $EXTRADIR/00.in/2.txt
    echo "It has never been easy to have a rational conversation about the value of gold.	Vést racionální rozhovor o hodnotě zlata nikdy nebylo snadné." >> $EXTRADIR/00.in/3.txt
    echo "Wouldn’t you know it?	A co se nestalo?" >> $EXTRADIR/00.in/3.txt
    echo "Since their articles appeared, the price of gold has moved up still further.	Od zveřejnění jejich článků se cena zlata vyšplhala ještě výše, a nedávno dokonce dosáhla rekordních 1300 dolarů." >> $EXTRADIR/00.in/3.txt
    gzip $EXTRADIR/00.in/3.txt
    ls $EXTRADIR/00.in | grep -v list > $EXTRADIR/00.in/$extra_name.list

    [ -e $EXTRADIR/00.in/1.txt.gz ]
    [ -e $EXTRADIR/00.in/2.txt.gz ]
    [ -e $EXTRADIR/00.in/3.txt.gz ]
    lines=`cat $EXTRADIR/00.in/$extra_name.list | wc -l`
    [ "$lines" -eq 3 ]
}

@test "merging sample datasets" {
    echo run make -f scripts/makefile.extra_data merge EXTRA_DIR=$EXTRADIR LPAIR=$lpair SPLIT_SIZE=$split_size MAX_TOKENS=$max_tokens SAMPLE_PERC=$sample_perc EXTRA_NAME=$extra_name >&2
    run make -f scripts/makefile.extra_data merge EXTRA_DIR=$EXTRADIR LPAIR=$lpair SPLIT_SIZE=$split_size MAX_TOKENS=$max_tokens SAMPLE_PERC=$sample_perc EXTRA_NAME=$extra_name
    [ "$status" -eq 0 ]
    [ -e $EXTRADIR/01.merged/$extra_name.en-cs.txt.gz ]
    lines=`zcat $EXTRADIR/01.merged/$extra_name.en-cs.txt.gz | wc -l`
    [ "$lines" -eq 7 ]
}

@test "splitting merged datasets" {
    echo run make -f scripts/makefile.extra_data data_split EXTRA_DIR=$EXTRADIR LPAIR=$lpair SPLIT_SIZE=$split_size MAX_TOKENS=$max_tokens SAMPLE_PERC=$sample_perc EXTRA_NAME=$extra_name >&2
    run make -f scripts/makefile.extra_data data_split EXTRA_DIR=$EXTRADIR LPAIR=$lpair SPLIT_SIZE=$split_size MAX_TOKENS=$max_tokens SAMPLE_PERC=$sample_perc EXTRA_NAME=$extra_name
    [ "$status" -eq 0 ]
    [ -e $EXTRADIR/02.split/$extra_name.$lpair.done ]
    lines=`find $EXTRADIR/02.split/$extra_name.$lpair.files -name 'part.*.txt' | wc -l`
    [ "$lines" -eq 2 ]
}

@test "analysing splits with default tokenization (on whitespaces)" {
    rm -rf $EXTRADIR/03.analysed
    echo run make -f scripts/makefile.extra_data analysed EXTRA_DIR=$EXTRADIR LPAIR=$lpair SPLIT_SIZE=$split_size MAX_TOKENS=$max_tokens SAMPLE_PERC=$sample_perc EXTRA_NAME=$extra_name >&2
    run make -f scripts/makefile.extra_data analysed EXTRA_DIR=$EXTRADIR LPAIR=$lpair SPLIT_SIZE=$split_size MAX_TOKENS=$max_tokens SAMPLE_PERC=$sample_perc EXTRA_NAME=$extra_name
    [ "$status" -eq 0 ]
    [ -e $EXTRADIR/03.analysed/$extra_name.$lpair.done ]
    lines=`find $EXTRADIR/03.analysed/$extra_name.$lpair.files -name 'part.*.treex.gz' | wc -l`
    [ "$lines" -eq 2 ]
    lemmas=`zcat $EXTRADIR/03.analysed/$extra_name.$lpair.files/*.treex.gz | grep "<lemma>" | wc -l`
    [ "$lemmas" -eq 93 ]
}
    
@test "analysing splits with language-specific tokenization" {
    rm -rf $EXTRADIR/03.analysed
    echo run make -f scripts/makefile.extra_data analysed EXTRA_DIR=$EXTRADIR LPAIR=$lpair SPLIT_SIZE=$split_size MAX_TOKENS=$max_tokens SAMPLE_PERC=$sample_perc TOKENIZE= EXTRA_NAME=$extra_name >&2
    run make -f scripts/makefile.extra_data analysed EXTRA_DIR=$EXTRADIR LPAIR=$lpair SPLIT_SIZE=$split_size MAX_TOKENS=$max_tokens SAMPLE_PERC=$sample_perc TOKENIZE= EXTRA_NAME=$extra_name
    [ "$status" -eq 0 ]
    [ -e $EXTRADIR/03.analysed/$extra_name.$lpair.done ]
    lines=`find $EXTRADIR/03.analysed/$extra_name.$lpair.files -name 'part.*.treex.gz' | wc -l`
    [ "$lines" -eq 2 ]
    lemmas=`zcat $EXTRADIR/03.analysed/$extra_name.$lpair.files/part.*.treex.gz | grep "<lemma>" | wc -l`
    [ "$lemmas" -eq 112 ]
}

@test "extracting lemmas for GIZA" {
    echo run make -f scripts/makefile.extra_data for_giza EXTRA_DIR=$EXTRADIR LPAIR=$lpair SPLIT_SIZE=$split_size MAX_TOKENS=$max_tokens SAMPLE_PERC=$sample_perc EXTRA_NAME=$extra_name >&2
    run make -f scripts/makefile.extra_data for_giza EXTRA_DIR=$EXTRADIR LPAIR=$lpair SPLIT_SIZE=$split_size MAX_TOKENS=$max_tokens SAMPLE_PERC=$sample_perc EXTRA_NAME=$extra_name >&2
    [ "$status" -eq 0 ]
    [ -e $EXTRADIR/04.for_giza/$extra_name.$lpair.for_giza.full.gz ]
    lines=`zcat $EXTRADIR/04.for_giza/$extra_name.$lpair.for_giza.full.gz | wc -l`
    [ "$lines" -eq 6 ]
    [ -e "$EXTRADIR/04.for_giza/$extra_name.$lpair.for_giza.gz" ]
    lines=`zcat $EXTRADIR/04.for_giza/$extra_name.$lpair.for_giza.gz | wc -l`
    [ "$lines" -eq 3 ]
}
