SHELL=/bin/bash

merge_all : data/for_giza/all.cs-ru.txt.gz
data/for_giza/all.cs-ru.txt.gz : data/for_giza/umc.cs-ru.txt.gz data/for_giza/open_subtitles_2012.cs-ru.txt.gz data/for_giza/news_commentary.cs-ru.txt.gz data/for_giza/pcedt_19.cs-ru.txt.gz
	zcat $^ | gzip -c > $@

data_split : data/for_giza/all.cs-ru.txt.gz
	mkdir -p data/split/all.cs-ru
	zcat $< | split -d -a 5 -l 100 - data/split/all.cs-ru/src_

for_giza : out/all.cs-ru.for_giza.gz
out/all.cs-ru.for_giza.gz :
	treex -p --jobs=50 --priority=0 --workdir='tmp/for_giza_tmp/{NNN}-run-{XXXX}' \
		Read::SentencesTSV from='!data/split/all.cs-ru/src_*' langs=cs,ru selector=src \
		Util::SetGlobal selector=src language=ru \
		W2A::TokenizeOnWhitespace \
		W2A::TagTreeTagger lemmatize=1 \
		Util::SetGlobal selector=src language=cs \
		W2A::TokenizeOnWhitespace \
		W2A::CS::TagMorphoDiTa lemmatize=1 \
		Write::LemmatizedBitexts selector=src language=cs to_language=ru to_selector=src \
	| gzip -c > $@

#W2A::RU::Tokenize
#W2A::CS::Tokenize

giza : out/all.cs-ru.giza.gz
out/all.cs-ru.giza.gz : out/all.cs-ru.for_giza.gz
	bin/gizawrapper.pl \
		--tempdir=tmp/giza_tmp \
		--bindir=$(shell pwd)/bin $< \
		--lcol=1 --rcol=2 \
		--keep \
		--dirsym=gdfa,int,left,right,revgdfa \
	| paste <(zcat $< | cut -f1 ) - \
	| gzip > $@

PCEDT_19_LIST=/home/mnovak/projects/align_resolver/data/gold_aligned.mgiza_on_czeng/full.list

pcerdt_19 : out/pcerdt_19/full.list
out/pcerdt_19/full.list : $(PCEDT_19_LIST) data/pcedt_19/all.ru.untok.txt
	mkdir -p $(dir $@) 
	treex -Ssrc -Lru \
		Read::Treex from='@$(word 1,$^)' \
		Import::Sentences from='$(word 2,$^)' \
		Write::Treex path='$(dir $@)'
	find $(dir $@) -name '*.streex' | sed 's|.*/||' | sort > $@

out/pcedt_19.cs-ru.giza.gz : out/all.cs-ru.giza.gz out/pcerdt_19/full.list
	treex \
		Read::Treex from='@out/pcerdt_19/full.list' \
		Util::Eval bundle='print $$bundle->get_document->full_filename . ".streex-" . $$bundle->id . "\n";' \
	> out/pcerdt_19.bundle.ids
	sentnum=`cat out/pcerdt_19.bundle.ids | wc -l`; \
	zcat $(word 1,$^) | tail -n $$sentnum | cut -f1 --complement | cut -f1,2,6,7 | paste out/pcerdt_19.bundle.ids - | gzip -c > $@

pcerdt_19_giza : out/pcerdt_19_giza/full.list
out/pcerdt_19_giza/full.list : out/pcerdt_19/full.list out/pcedt_19.cs-ru.giza.gz
	mkdir -p $(dir $@)
	treex -Ssrc -Lru \
		Read::Treex from='@$(word 1,$^)' \
		W2A::RU::Tokenize \
		W2A::TagTreeTagger lemmatize=1 \
		Align::A::InsertAlignmentFromFile from='$(word 2,$^)' \
			inputcols=gdfa_int_therescore_backscore \
			selector=src language=cs to_selector=src to_language=ru \
		Write::Treex path='$(dir $@)'
	find $(dir $@) -name '*.streex' | sed 's|.*/||' | sort > $@

pcerdt_19_mgiza : out/pcerdt_19_mgiza/full.list
out/pcerdt_19_mgiza/full.list : out/pcerdt_19/full.list
	mkdir -p $(dir $@) 
	treex -p --jobs 50 -Ssrc -Lru \
		Read::Treex from='@$<' \
		W2A::RU::Tokenize \
		W2A::TagTreeTagger lemmatize=1 \
		Align::A::AlignMGiza from_language=cs from_selector=src to_language=ru to_selector=src \
			dir_or_sym=intersection,grow-diag-final-and model_from_share=cs-ru cpu_cores=1 \
		Write::Treex path='$(dir $@)'
	find $(dir $@) -name '*.streex' | sed 's|.*/||' | sort > $@

ALL_LANGUAGES=cs,en,ru
LANGUAGE=en
ANNOT_LANGUAGES=$(shell perl -e 'print join ",", grep {$$_ ne "$(LANGUAGE)"} split /,/, $$ARGV[0];' $(ALL_LANGUAGES))
ALIGN_TYPES=$(shell perl -e 'my $$types = {en => {cs => "gold", ru => ".*"}, cs => {en => "gold", ru => ".*"}, ru => {cs => ".*", en => "gold"}}; print join ",", map {$$types->{"$(LANGUAGE)"}{$$_}} split /,/, "$(ANNOT_LANGUAGES)"')
FILTER=poss

print_annot_files : annot/$(LANGUAGE)_$(FILTER)/align.src.sec19_00-49.all.clean.ali_annot
annot/$(LANGUAGE)_$(FILTER)/align.src.sec19_00-49.all.clean.ali_annot : out/pcerdt_19_giza/full.list
	mkdir -p $(dir $@)
	treex -Ssrc -L$(LANGUAGE) \
		Read::Treex from='@$<' \
		Print::AlignAnnot filter=$(FILTER) layer=a annot_langs='$(ANNOT_LANGUAGES)' align_types='$(ALIGN_TYPES)' to='-' \
	> $@
