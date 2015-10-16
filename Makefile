SHELL=/bin/bash

#=========================================== VARIABLES =====================================================

#-------------------------------------------- DIRS AND PATHS -----------------------------------------

DATA_DIR = data
#ORIG_LIST = $(DATA_DIR)/train_19.orig.list
# just a hlaf so far
ORIG_LIST = $(DATA_DIR)/train_19_00-49.orig.list

#-------------------------------------------- LRC -----------------------------------------


JOBS = 100
LRC=1
ifeq (${LRC}, 1)
LRC_FLAGS = -p --priority "-1" --qsub '-hard -l mem_free=2G -l act_mem_free=2G -l h_vmem=2G' --jobs ${JOBS}
endif

#-------------------------------------------- LANG -----------------------------------------

ALIGN_ANNOT_LANG=en
ALIGN_ANNOT_TYPE=perspron
ALIGN_ANNOT_ID=$(ALIGN_ANNOT_LANG)_$(ALIGN_ANNOT_TYPE)

ifeq ($(ALIGN_ANNOT_LANG),en)
ALIGN_ANNOT_LANG2=cs
else
ALIGN_ANNOT_LANG2=en
endif

##########################################################################################
################################# ALIGNMENT ANNOTATION ###################################
##########################################################################################

create_list : annot/$(ALIGN_ANNOT_ID)/is_relat.ref.sec19.list

#annot/$(ALIGN_ANNOT_ID)/is_relat.%.sec19.list : $(ORIG_LIST)
#annot/$(ALIGN_ANNOT_ID)/is_relat.%.sec19.list : tmp/robust_ali/list
annot/$(ALIGN_ANNOT_ID)/is_relat.%.sec19.list : data/gold_aligned.mgiza_on_czeng/list
	mkdir -p annot/$(ALIGN_ANNOT_ID)
	-treex $(LRC_FLAGS) -L$(ALIGN_ANNOT_LANG) -S$* \
		Read::Treex from=@$< \
		My::CorefExprAddresses ignore_align_type=gold anaphor_type=$(ALIGN_ANNOT_TYPE) \
			| sort > $@
		#My::CorefExprAddresses anaphor_type=$(ALIGN_ANNOT_TYPE) \

#=================================== PREPARE DATA FOR MANUAL ANNOTATION ==================================

add_robust_ali : $(ORIG_LIST)
	-treex $(LRC_FLAGS) -Sref \
		Read::Treex from=@$< \
		Util::SetGlobal language=cs \
		Project::Attributes layer=t alignment_type=monolingual alignment_direction=trg2src attributes=gram/indeftype \
		My::AddRobustAlignment::CsRelpron \
		Util::SetGlobal language=en \
		My::AddRobustAlignment::EnPerspron \
		Write::Treex storable=1 to='.' substitute='{^.*/([^\/]*)}{tmp/robust_ali/$$1}'
	find tmp/robust_ali -path "*.streex" | sort | sed 's/^.*\///' > tmp/robust_ali/list

#ALIGN_ANNOT_LIST=cs_relpron.is_relat.ref.shuffled.1-200.list
#ALIGN_ANNOT_LIST=annot/$(ALIGN_ANNOT_ID)/is_relat.ref.sec19.list
ALIGN_ANNOT_LIST=annot/$(ALIGN_ANNOT_ID)/is_relat.ref.sec19_00-49.list

#prepare_align_annot : annot/$(ALIGN_ANNOT_ID)/is_relat.ref.sec19.list
prepare_align_annot : $(ALIGN_ANNOT_LIST)
	-treex $(LRC_FLAGS) -L$(ALIGN_ANNOT_LANG) -Sref \
		Read::Treex from=@$< \
		My::AnnotAlignWrite align_lang=$(ALIGN_ANNOT_LANG2) to='.' substitute='{^.*/([^\/]*)}{tmp/annot/$(ALIGN_ANNOT_ID)/$$1}' extension='.txt'
	find tmp/annot/$(ALIGN_ANNOT_ID) -path "*.txt" | sort | xargs cat > tmp/annot/$(ALIGN_ANNOT_ID).all


# unrevised annotation are labelled with a '+' symbol prepended to an address
# prints out addresses in ALIGN_ANNOT_LANG2 language
# to make this work at first lines 98-103 in My::AlignmentLoader must be commented out
revise_annot :
	cat $(GOLD_ANNOT_FILE) | grep -A6 "^+" | grep -v "^--" | sed 's/^+//' > plus.instances
	treex -p --jobs 20 -L$(ALIGN_ANNOT_LANG) -Sref \
		Read::Treex from=@$(ORIG_LIST) \
		My::AlignmentLoader from=plus.instances align_language=$(ALIGN_ANNOT_LANG2) > out
	cat out | cut -d' ' -f2 > addr

#================================ IMPORTING THE MANUAL ANNOTATION BACK TO THE TREEBANK =======================

# check ORIG_LIST for a version of the data
# v0001
#ALIGN_TYPE=giza_on_train-pcedt
# v0002
#ALIGN_TYPE=giza_on_train-pcedt.no_left_right_revgdfa
# v0003
ALIGN_TYPE=mgiza_on_czeng

GOLD_ANNOT_FILE_EN=annot/en.all.align.ref.sec19_00-49.ali_annot
GOLD_ANNOT_FILE_CS=annot/cs.all.align.ref.sec19_00-49.ali_annot
#GOLD_ANNOT_FILE=annot/$(ALIGN_ANNOT_ID)/align.ref.sec19.misko.annot

GOLD_ANNOT_TREES_DIR = $(DATA_DIR)/gold_aligned.$(ALIGN_TYPE)
GOLD_ANNOT_LIST = $(DATA_DIR)/gold_aligned.$(ALIGN_TYPE).so_far_annot.list

#GOLD_ANNOT_LIST = $(DATA_DIR)/gold_aligned.list


import_align : $(ORIG_LIST)
	mkdir -p $(GOLD_ANNOT_TREES_DIR)
	-treex $(LRC_FLAGS) -Sref \
		Read::Treex from=@$< \
		Util::SetGlobal language=en \
		My::AlignmentLoader from=$(GOLD_ANNOT_FILE_EN) align_language=cs \
		My::ProjectAlignment trg_selector=src \
		Util::SetGlobal language=cs \
		My::AlignmentLoader from=$(GOLD_ANNOT_FILE_CS) align_language=en \
		My::ProjectAlignment trg_selector=src \
		Write::Treex path=$(GOLD_ANNOT_TREES_DIR) storable=1

$(DATA_DIR)/gold_aligned.list : annot/$(ALIGN_ANNOT_ID)/is_relat.src.sec19.list
	replace=`echo $(GOLD_ANNOT_TREES_DIR) | sed 's/^$(DATA_DIR)\///' | sed 's/\//\\\\\//g'`; \
	cat $< | sed "s/^.*\//$$replace\//" | sed 's/treex\.gz/streex/g' > $@

skuska : $(DATA_DIR)/gold_aligned.list

#================================ PRINTING SUMMARY TABLE =======================

ALL_TYPES=perspron perspron_unexpr relpron cor

ALIGN_ANNOT_LIST_ALL=annot/$(ALIGN_ANNOT_ID)/is_relat.ref.sec19_00-49.all.list

summary_for_type : $(ALIGN_ANNOT_LIST_ALL)
	-treex $(LRC_FLAGS) -L$(ALIGN_ANNOT_LANG) -Sref \
		Read::Treex from=@$< \
		My::BitextCorefSummary align_lang=$(ALIGN_ANNOT_LANG2) to='.' substitute='{^.*/([^\/]*)}{tmp/summaries/$(ALIGN_ANNOT_ID)/$$1}' extension='.txt'
	find tmp/summaries/$(ALIGN_ANNOT_ID) -path "*.txt" | sort | xargs cat > tmp/summaries/$(ALIGN_ANNOT_ID).all

SUMMARY_FILE=annot/$(ALIGN_ANNOT_LANG).all.align.ref.sec19_00-49.summary
summary :
	for type in $(ALL_TYPES); do \
		make summary_for_type ALIGN_ANNOT_LANG=$(ALIGN_ANNOT_LANG) ALIGN_ANNOT_TYPE=$$type; \
	done
	find tmp/summaries -path "*/$(ALIGN_ANNOT_LANG)_*.all" | sort | xargs cat > $(SUMMARY_FILE)

#================= EVALUATING THE ALIGNMENT - ROBUST and ORIGINAL  =======================

## > evaluation of the original PCEDT alignment
#ALIGN_ORIGIN=orig
#ALIGN_RELTYPES=!gold,!robust,!supervised,.*
## > evaluation of the rule-based (robust) heuristics 
ALIGN_ORIGIN=robust
ALIGN_RELTYPES=!gold,!supervised,robust,.*
##		> lines 36-40 in AddRobustAlignment.pm must be uncommented: removing the original alignment for nodes targeted by robust
## > to evaluate only on subclasses focused by AddRobustAlignment
##		> in My::AlignmentEval, filter out all instances that have undefined wild->{align_robust_err}

tmp/trees.for_eval.$(ALIGN_ORIGIN)/list : $(GOLD_ANNOT_TREES_DIR)/list
	mkdir -p $(dir $@)
	treex $(LRC_FLAGS) -Sref \
		Read::Treex from=@$< \
		Util::SetGlobal language=cs \
		Project::Attributes layer=t alignment_type=monolingual alignment_direction=trg2src attributes=gram/indeftype \
		My::AddRobustAlignment::CsRelpron \
		Util::SetGlobal language=en \
		My::AddRobustAlignment::EnPerspron \
		Write::Treex storable=1 to='.' substitute='{^.*/([^\/]*)}{$(dir $@)/$$1}'
	find $(dir $@) -path "*.streex" | sort | sed 's/^.*\///' > $@

eval_for_type : $(ALIGN_ANNOT_LIST_ALL) tmp/trees.for_eval.$(ALIGN_ORIGIN)/list
	mkdir -p tmp/align_eval
	cat $< | sed 's|^.*/|$(PWD)/tmp/trees.for_eval.$(ALIGN_ORIGIN)/|' > tmp/align_eval/$(ALIGN_ANNOT_ID).input.list
	treex $(LRC_FLAGS) -L$(ALIGN_ANNOT_LANG) -Sref \
		Read::Treex from=@tmp/align_eval/$(ALIGN_ANNOT_ID).input.list \
		My::AlignmentEval align_language=$(ALIGN_ANNOT_LANG2) align_reltypes='$(ALIGN_RELTYPES)' to='.' substitute='{^.*/([^\/]*)}{tmp/align_eval/$(ALIGN_ANNOT_ID).$(ALIGN_ORIGIN)/$$1}' extension='.txt'
	find tmp/align_eval/$(ALIGN_ANNOT_ID).$(ALIGN_ORIGIN) -path "*.txt" | sort | xargs cat > tmp/align_eval/$(ALIGN_ANNOT_ID).$(ALIGN_ORIGIN).all

eval :
	for type in $(ALL_TYPES); do \
		make eval_for_type ALIGN_ANNOT_LANG=$(ALIGN_ANNOT_LANG) ALIGN_ANNOT_TYPE=$$type; \
	done

##########################################################################################
############################## ALIGNMENT SUPERVISED PREDICTION ###########################
##########################################################################################

ANAPH_TYPE=all
SELECTOR=ref

FULL_DATA=$(DATA_DIR)/full.$(SELECTOR).$(ANAPH_TYPE).pcedt_19.table
TRAIN_DATA=$(DATA_DIR)/train.$(SELECTOR).$(ANAPH_TYPE).pcedt_19.table
DEV_DATA=$(DATA_DIR)/dev.$(SELECTOR).$(ANAPH_TYPE).pcedt_19.table
EVAL_DATA=$(DATA_DIR)/eval.$(SELECTOR).$(ANAPH_TYPE).pcedt_19.table

#extract_data_table : $(FULL_DATA) $(TRAIN_DATA) $(DEV_DATA) $(EVAL_DATA)
extract_data_table : $(FULL_DATA)

$(DATA_DIR)/%.$(SELECTOR).$(ANAPH_TYPE).pcedt_19.table : $(GOLD_ANNOT_TREES_DIR)/%.list
	mkdir -p tmp/data_table/$*.$(SELECTOR).$(ANAPH_TYPE).pcedt_19
	-treex $(LRC_FLAGS) -L$(ALIGN_ANNOT_LANG) -S$(SELECTOR) \
		Read::Treex from=@$< \
		My::PrintAlignData align_language=$(ALIGN_ANNOT_LANG2) anaph_type=$(ANAPH_TYPE) to='.' substitute='{^.*/([^\/]*)}{tmp/data_table/$*.$(SELECTOR).$(ANAPH_TYPE).pcedt_19/$$1}'
	find tmp/data_table/$*.$(SELECTOR).$(ANAPH_TYPE).pcedt_19 -name "wsj_19*" | sort | xargs cat | gzip -c > $(DATA_DIR)/$*.$(SELECTOR).$(ANAPH_TYPE).pcedt_19.$(ALIGN_TYPE).table
	ln -s $*.$(SELECTOR).$(ANAPH_TYPE).pcedt_19.$(ALIGN_TYPE).table $(DATA_DIR)/$*.$(SELECTOR).$(ANAPH_TYPE).pcedt_19.table


############################## USING ML FRAMEWORK ###########################

ML_FRAMEWORK=/home/mnovak/projects/ml_framework
RUNS_DIR=tmp/ml/$(ALIGN_ANNOT_ID)
FEATSET_LIST=conf/$(ALIGN_ANNOT_ID).feat.list
STATS_FILE=$(ALIGN_ANNOT_ID).ml.results

baseline_% : $(GOLD_ANNOT_TREES_DIR)/%.list
	mkdir -p tmp/baseline_$*
	-treex $(LRC_FLAGS) -L$(ALIGN_ANNOT_LANG) -S$(SELECTOR) \
		Read::Treex from=@$< \
		My::AlignmentEval align_language=$(ALIGN_ANNOT_LANG2) anaph_type=$(ANAPH_TYPE) to='.' substitute='{^.*/([^\/]*)}{tmp/baseline_$*/$$1}'
	find tmp/baseline_$* -name "wsj_19*" | sort | xargs cat | $(ML_FRAMEWORK_DIR)/scripts/results_to_triples.pl --ranking | $(ML_FRAMEWORK)/scripts/eval.pl --acc --prf

TRAIN_TEST_DATA_LIST=TRAIN_DATA DEV_DATA EVAL_DATA

train_test :
	$(ML_FRAMEWORK_DIR)/run.sh -f conf/params.ini \
        EXPERIMENT_TYPE=train_test \
        DATA_LIST="$(TRAIN_TEST_DATA_LIST)" \
        TRAIN_DATA=$(TRAIN_DATA) \
        DEV_DATA=$(DEV_DATA) \
        EVAL_DATA=$(EVAL_DATA) \
        FEATSET_LIST=conf/featset.list \
        ML_METHOD_LIST=conf/ml_method.list \
        LRC=$(LRC) \
        TMP_DIR=tmp/ml \
        D="$(D)"

CROSS_VALID_DATA_LIST=FULL_DATA

cross_valid :
	$(ML_FRAMEWORK_DIR)/run.sh -f conf/params.ini \
        EXPERIMENT_TYPE=cross-validation \
		CROSS_VALID_N=10 \
        DATA_LIST="$(CROSS_VALID_DATA_LIST)" \
        FULL_DATA=$(FULL_DATA) \
        FEATSET_LIST=conf/featset.list \
        ML_METHOD_LIST=conf/ml_method.list \
        LRC=$(LRC) \
        TMP_DIR=tmp/ml \
        D="$(D)"

self_training :
	$(MAKE) -C $(ML_FRAMEWORK) self_training \
        RANKING=1 \
        DATA_SOURCE=pcedt_19 \
        DATA_DIR=$(PWD)/$(DATA_DIR) \
        RUNS_DIR=$(PWD)/tmp/testing_self_training \
        FEATSET_LIST=$(PWD)/$(FEATSET_LIST) \
		ML_METHOD=vw.ranking \
		ML_PARAMS="mc --loss_function logistic --passes 10" \
		FEAT_LIST="__SELF__,n1_functor,n2_functor"

##################### DIAGNOSTICS ##########################################

RESULT_FILE=tmp/ml/en_perspron/tte_feats_2014-03-06_22-50-55/75c76c8175/result/train.pcedt_19.in.vw.ranking.8411a.res

error_list : errors.ml.$(ALIGN_ANNOT_ID).list
errors.ml.$(ALIGN_ANNOT_ID).list :
	cat $(RESULT_FILE) | grep "^[^0]" | sed 's/\.0\+//' | sed 's/-1//' > tmp/results.tmp
	cat $(GOLD_ANNOT_LIST) | sed 's/^/data\//' | \
		perl -e 'my @l = <STDIN>; my $$a = []; push @$$a, [] foreach (0..9); for (my $$i=0; $$i < @l; $$i++) { push @{$$a->[$$i % 10]}, $$l[$$i]; } foreach (0..9) { print join "", @{$$a->[$$_]};	}' > tmp/addresses.tmp
	paste tmp/results.tmp tmp/addresses.tmp | perl -pe 'chmod $$_; my @a = split /\s+/, $$_; $$_ = ($$a[0] eq $$a[1]) ? "" : "$$_";' > errors.ml.$(ALIGN_ANNOT_ID).res
	cut -f2 errors.ml.$(ALIGN_ANNOT_ID).res > $@
	rm tmp/results.tmp tmp/addresses.tmp

