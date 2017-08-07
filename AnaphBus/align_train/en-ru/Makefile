SHELL=/bin/bash
# copied from ~/projects/coref_projection/makefile.align_train, through ~/projects/align_coref/en_ru_align

L1=en
L2=ru
LPAIR=$(L1)_$(L2)

ALITRAIN_DIR=data/
ALITRAIN_TMP=tmp/


############################################ STAGE 1-2 TRAIN #################################################
############ PREPARE ALL TRAINING DATA FOR L1-L2 WORD ALIGNMENT MODEL ON LEMMATIZED TEXTS ####################
##############################################################################################################

ALITRAIN_IN_DIR=$(ALITRAIN_DIR)/00.train.in
ALITRAIN_SPLIT_DIR=$(ALITRAIN_DIR)/01.train.split
ALITRAIN_FOR_GIZA_DIR=$(ALITRAIN_DIR)/02.train.for_giza
ALITRAIN_IN_DATA_en_ru:=$(addprefix $(ALITRAIN_DIR)/00.train.in/,MultiUN.en-ru.txt.gz OpenSubtitles2016.en-ru.txt.gz TED2013.en-ru.txt.gz Wikipedia.en-ru.txt.gz)

merge_all : $(ALITRAIN_IN_DIR)/all_train.$(LPAIR).txt.gz
$(ALITRAIN_IN_DIR)/all_train.$(LPAIR).txt.gz : $(ALITRAIN_IN_DATA_$(LPAIR))
	zcat $^ | gzip -c > $@

filter_long_for_giza : $(ALITRAIN_IN_DIR)/all_train.$(LPAIR).filtered.txt.gz
$(ALITRAIN_IN_DIR)/all_train.$(LPAIR).filtered.txt.gz : $(ALITRAIN_IN_DIR)/all_train.$(LPAIR).txt.gz
	zcat $< | perl -ne 'my ($$s1, $$s2) = split /\t/, $$_; print $$_ if (length($$s1) < 3000 && length($$s2) < 3000);' | gzip -c > $@

data_split : $(ALITRAIN_SPLIT_DIR)/all_train.$(LPAIR).done
$(ALITRAIN_SPLIT_DIR)/all_train.$(LPAIR).done : $(ALITRAIN_IN_DIR)/all_train.$(LPAIR).filtered.txt.gz
	mkdir -p $(ALITRAIN_SPLIT_DIR)/all_train.$(LPAIR)
	( zcat $< | split -d -a 7 --additional-suffix .txt -l 2000 - $(ALITRAIN_SPLIT_DIR)/all_train.$(LPAIR)/src_ ) && \
	touch $@

for_giza_ru : $(ALITRAIN_FOR_GIZA_DIR)/all_train.en_ru.for_giza.gz
$(ALITRAIN_FOR_GIZA_DIR)/all_train.en_ru.for_giza.gz : $(ALITRAIN_SPLIT_DIR)/all_train.en_ru.done
	mkdir -p $(dir $@)
	treex -p --jobs=200 --priority=0 --queue 'troja-all.q@*' --workdir='$(ALITRAIN_TMP)/02.for_giza.runs/{NNN}-run-{XXXX}' \
		Read::SentencesTSV from='!$(basename $<)/src_*' langs=en,ru selector=src \
		Util::SetGlobal selector=src \
		scenario/en.lemmatize.scen \
		scenario/ru.lemmatize.scen \
		Write::LemmatizedBitexts selector=src language=en to_language=ru to_selector=src \
	| gzip -c > $@

############################################# STAGE 1-2 TEST #################################################
############ PREPARE ALL "TEST" DATA FOR L1-L2 WORD ALIGNMENT MODEL ON LEMMATIZED TEXTS ######################
##############################################################################################################

TEST_DATA_en_ru='/home/mnovak/projects/align_coref/AnaphBus/mono/ru/data/02.texts.checked/en/*.txt;/home/mnovak/projects/align_coref/AnaphBus/mono/ru/data/02.texts.checked/ru/*.txt'
TEST_NAME_en_ru=wsj_1900-49

for_giza_test_ru : $(ALITRAIN_FOR_GIZA_DIR)/$(TEST_NAME_en_ru).en_ru.for_giza.gz
$(ALITRAIN_FOR_GIZA_DIR)/$(TEST_NAME_en_ru).en_ru.for_giza.gz :
	mkdir -p $(dir $@)
	treex -p --jobs=10 --priority=0 --queue 'troja-all.q@*' --workdir='$(ALITRAIN_TMP)/02.for_giza.runs/{NNN}-run-{XXXX}' \
		Read::AlignedSentences en_src='!$(shell echo $(TEST_DATA_en_ru) | cut -f1 -d";")' ru_src='!$(shell echo $(TEST_DATA_en_ru) | cut -f2 -d";")' \
		Util::SetGlobal selector=src \
		scenario/en.lemmatize.scen \
		scenario/ru.lemmatize.scen \
		Write::LemmatizedBitexts selector=src language=en to_language=ru to_selector=src \
	| gzip -c > $@

############################################# STAGE 3 PREPARE ################################################
############## SAMPLE FROM TRAIN AND MERGE IT WITH TEST PORTION TO BE READY FOR GIZA #########################
##############################################################################################################

SAMPLE_SIZE=050
MAX_SENT_WORDS=100
MAX_LENGTH_RATIO=9

# prepare a sample of the data
# filter out too long sentences (>= 300 words on either language side)
sample : $(ALITRAIN_FOR_GIZA_DIR)/all_train_s$(SAMPLE_SIZE)__$(TEST_NAME_$(LPAIR)).$(LPAIR).for_giza.gz
$(ALITRAIN_FOR_GIZA_DIR)/all_train_s$(SAMPLE_SIZE)__$(TEST_NAME_$(LPAIR)).$(LPAIR).for_giza.gz : $(ALITRAIN_FOR_GIZA_DIR)/all_train.$(LPAIR).for_giza.gz $(ALITRAIN_FOR_GIZA_DIR)/$(TEST_NAME_en_ru).en_ru.for_giza.gz
	mkdir -p $(ALITRAIN_TMP)/02.for_giza.sample
	zcat $(word 1,$^) | \
		perl -e 'srand(1986); while (<>) { print $$_ if (rand(100) <= int("$(SAMPLE_SIZE)")); }' | \
		perl -ne 'chomp $$_; my ($$id, $$a, $$b) = split /\t/, $$_; my ($$lena, $$lenb) = map {scalar(split / /, $$_)} ($$a, $$b); my $$ratio = $$lena < $$lenb ? $$lenb / $$lena : $$lena / $$lenb; if ($$lena < $(MAX_SENT_WORDS) && $$lenb < $(MAX_SENT_WORDS) && $$ratio < $(MAX_LENGTH_RATIO)) { print $$_."\n"; }' | \
		gzip -c > $(ALITRAIN_TMP)/02.for_giza.sample/all_train_s$(SAMPLE_SIZE).$(LPAIR).for_giza.gz
	zcat $(ALITRAIN_TMP)/02.for_giza.sample/all_train_s$(SAMPLE_SIZE).$(LPAIR).for_giza.gz $(word 2,$^) | gzip -c > $@


#W2A::RU::Tokenize
#W2A::CS::Tokenize

############################################### STAGE 3 ######################################################
################ RUN GIZA++ TO OBTAIN WORD ALIGNMENT ON PCEDT_19 (CAN BE USED DIRECTLY) ######################
############ AS WELL AS CS-RU WORD ALIGNMENT MODEL (CAN BE USED BY MGIZA; PERFORMS WORSE) ####################
##############################################################################################################

ALITRAIN_GIZA_DIR=$(ALITRAIN_DIR)/03.giza

# --continue-dir=$(ALITRAIN_TMP)/03.giza.tempdir/gizawrapMA3g

#giza : $(ALITRAIN_GIZA_DIR)/all.$(LPAIR).giza.gz
#$(ALITRAIN_GIZA_DIR)/all.$(LPAIR).giza.gz : $(ALITRAIN_FOR_GIZA_DIR)/all.$(LPAIR).for_giza.gz
#giza : $(ALITRAIN_GIZA_DIR)/all.sample_033.$(LPAIR).giza.gz
#$(ALITRAIN_GIZA_DIR)/all.sample_033.$(LPAIR).giza.gz : $(ALITRAIN_FOR_GIZA_DIR)/all.sample_033.$(LPAIR).for_giza.gz
giza : $(ALITRAIN_GIZA_DIR)/all_train_s$(SAMPLE_SIZE)__$(TEST_NAME_$(LPAIR)).$(LPAIR).giza.gz
$(ALITRAIN_GIZA_DIR)/all_train_s$(SAMPLE_SIZE)__$(TEST_NAME_$(LPAIR)).$(LPAIR).giza.gz : $(ALITRAIN_FOR_GIZA_DIR)/all_train_s$(SAMPLE_SIZE)__$(TEST_NAME_$(LPAIR)).$(LPAIR).for_giza.gz
	mkdir -p $(dir $@)
	bin/gizawrapper.pl \
		--tempdir=$(ALITRAIN_TMP)/03.giza.tempdir \
		--bindir=$(shell pwd)/bin "$<" \
		--lcol=1 --rcol=2 \
		--keep \
		--continue-dir=$(ALITRAIN_TMP)/03.giza.tempdir/gizawrapKZ6X \
		--dirsym=gdfa,int,left,right,revgdfa \
	| paste <( zcat "$<" | cut -f1 ) - \
	| gzip > "$@"


postcat : $(ALITRAIN_GIZA_DIR)/train.$(LPAIR).postcat.gz
$(ALITRAIN_GIZA_DIR)/train.$(LPAIR).postcat.gz : $(ALITRAIN_FOR_GIZA_DIR)/train.$(LPAIR).for_giza.gz
	mkdir -p $(dir $@); \
	mkdir -p $(ALITRAIN_TMP)/03.postcat.tempdir; \


############################################### STAGE 4 ######################################################
####################### EXTRACT EN-RU WORD ALIGNMENT FOR ANAPHBUS AND PREPARE  ###############################
##############################################################################################################

extract_anaphbus_ali : $(ALITRAIN_GIZA_DIR)/wsj_1900-49.en_ru.giza.gz
$(ALITRAIN_GIZA_DIR)/wsj_1900-49.en_ru.giza.gz : $(ALITRAIN_GIZA_DIR)/all_train_wsj_1900-49.en_ru.giza.gz
	sentnum=`cat $(shell echo $(TEST_DATA_en_ru) | cut -f1 -d";") | wc -l`; \
	zcat $(word 1,$^) | tail -n $$sentnum | cut -f1,2,3,7,8 | perl -ne 'chomp $$_; my ($$id, @cols) = split /\t/, $$_; $$id =~ s{^.*/}{}; $$id =~ s{\.txt}{}; print join "\t", ($$id, @cols); print "\n";' | gzip -c > $@
