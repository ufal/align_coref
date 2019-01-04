SHELL=/bin/bash

ifeq ($(LRC),1)
LRC_FLAG=-p --jobs 25
endif

TREEX=PERL5LIB=${PERL5LIB}:lib treex ${LRC_FLAG}
#-e DEBUG
LANGS=en cs ru pl
#LANGS=pl
#LANGS=cs

release : data
	mkdir -p $@
	cp -r data $@
	cp -r bin $@

FINAL_TREEX_FILES=../multi/en-cs-ru-pl/data/05.treex.pl_align_to_t/*.treex.gz

data : data/treex data/plain data/conll
	mkdir -p $@
	mkdir -p $@/conll

#cp $(FINAL_TREEX_FILES) $@
data/treex : 
	mkdir -p $@
	$(TREEX) \
		Read::Treex from='!$(FINAL_TREEX_FILES)' \
		PAWS::FinalizeAlign \
		PAWS::UnifyAlignDirection language=en to_lang=cs \
		PAWS::UnifyAlignDirection language=en to_lang=ru \
		PAWS::UnifyAlignDirection language=en to_lang=pl \
		PAWS::UnifyAlignDirection language=cs to_lang=ru \
		PAWS::UnifyAlignDirection language=cs to_lang=pl \
		PAWS::UnifyAlignDirection language=ru to_lang=pl \
		Util::Eval anode='$$anode->set_wild();' \
		Util::Eval tnode='$$tnode->set_wild();' \
		Write::Treex storable=0 path=$@

data/plain_zero :
	mkdir -p $@
	for i in $(LANGS); do \
		${TREEX} -L$$i \
			Read::Treex from='!data/treex/*.treex.gz' \
			Write::SentencesWithZeros path=$@ extension=.$$i.txt; \
	done

data/plain : data/plain_zero
	mkdir -p $@
	for i in $</*.txt; do \
		f=$${i#$</}; \
		echo "Removing zeros from $$f"; \
		bin/strip_restored_zeros.pl < $$i > $@/$$f; \
	done

data/conll_zero :
	mkdir -p $@
	for i in $(LANGS); do \
		${TREEX} -L$$i \
			Read::Treex from='!data/treex/*.treex.gz' \
			A2T::SetDocOrds layer=a \
			A2T::SetDocOrds layer=t \
			A2A::ConvertTags input_driver=en::penn \
			Coref::MarkMentionsForScorer layer=a auto_alayer=1 only_heads=0 \
			Coref::MarkMentionsForScorer layer=t only_heads=1 \
			Write::SemEval2010 layer=a include_zeros=1 path=$@ extension=.$$i.conll; \
	done

data/conll : data/conll_zero
	mkdir -p $@
	for i in $</*.conll; do \
		f=$${i#$</}; \
		echo "Removing zeros from $$f"; \
		cat $$i | grep -Pv '^\d+-\d' > $@/$$f; \
	done

##################################################################################################################################
############################### FINALIZE THE REST: SCHEMA FILES, TECHNICAL REPORT ################################################
##################################################################################################################################

finalize : schema pack

schema : $(TREEX_DIR)/Core/share/tred_extension/treex/resources/treex*.xml
	mkdir -p release/resources
	cp $^ release/resources

pack :
	cp README.md LICENSE.txt release
	cp -r data release/data
	cp -r doc release/doc
	mv release paws
	zip -r paws.zip paws
	rm -rf paws
