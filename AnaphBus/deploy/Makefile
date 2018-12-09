SHELL=/bin/bash

ifeq ($(LRC),1)
LRC_FLAG=-p --jobs 25
endif

TREEX=PERL5LIB=${PERL5LIB}:lib treex ${LRC_FLAG}
LANGS=en cs ru pl
#LANGS=en
#LANGS=cs

release : data
	mkdir -p $@
	cp -r data $@
	cp -r bin $@

FINAL_TREEX_FILES=../multi/en-cs-ru-pl/data/03.treex.ru-pl_align_imported/*.treex.gz

data : data/treex data/plain data/conll
	mkdir -p $@
	mkdir -p $@/conll

data/treex : 
	mkdir -p $@
	cp $(FINAL_TREEX_FILES) $@

data/plain :
	mkdir -p $@
	for i in $(LANGS); do \
		${TREEX} -L$$i Read::Treex from='!data/treex/*.treex.gz' Write::SentencesWithZeros path=$@ extension=.$$i.txt; \
	done
