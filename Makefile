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

#======================================================================================================

create_list : annot/$(ALIGN_ANNOT_ID)/is_relat.ref.sec19.list

#annot/$(ALIGN_ANNOT_ID)/is_relat.%.sec19.list : $(ORIG_LIST)
#annot/$(ALIGN_ANNOT_ID)/is_relat.%.sec19.list : tmp/robust_ali/list
annot/$(ALIGN_ANNOT_ID)/is_relat.%.sec19.list : data/gold_aligned.mgiza_on_czeng/list
	mkdir -p annot/$(ALIGN_ANNOT_ID)
	-treex $(LRC_FLAGS) -L$(ALIGN_ANNOT_LANG) -S$* \
		My::CorefExprAddresses ignore_align_type=gold anaphor_type=$(ALIGN_ANNOT_TYPE) \
		Read::Treex from=@$< \
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

ALL_EN_TYPES=perspron perspron_unexpr relpron cor
ALL_CS_TYPES=perspron perspron_unexpr relpron cor

ALIGN_ANNOT_LIST_ALL=annot/$(ALIGN_ANNOT_ID)/is_relat.ref.sec19_00-49.all.list

summary_for_type : $(ALIGN_ANNOT_LIST_ALL)
	-treex $(LRC_FLAGS) -L$(ALIGN_ANNOT_LANG) -Sref \
		Read::Treex from=@$< \
		My::BitextCorefSummary align_lang=$(ALIGN_ANNOT_LANG2) to='.' substitute='{^.*/([^\/]*)}{tmp/summaries/$(ALIGN_ANNOT_ID)/$$1}' extension='.txt'
	find tmp/summaries/$(ALIGN_ANNOT_ID) -path "*.txt" | sort | xargs cat > tmp/summaries/$(ALIGN_ANNOT_ID).all
		
summary :
	for type in $(ALL_EN_TYPES); do \
		make summary_for_type ALIGN_ANNOT_LANG=en ALIGN_ANNOT_TYPE=$$type; \
	done


extract_data_table : $(DATA_DIR)/train.pcedt_19.table
$(DATA_DIR)/train.pcedt_19.table : $(GOLD_ANNOT_LIST)
	-treex $(LRC_FLAGS) -L$(ALIGN_ANNOT_LANG) -Ssrc \
		Read::Treex from=@$< \
		My::PrintAlignData align_language=$(ALIGN_ANNOT_LANG2) to='.' substitute='{^.*/([^\/]*)}{tmp/data_table/$$1}'
	find tmp/data_table -name "wsj_19*" | sort | xargs cat | gzip -c > $(DATA_DIR)/train.pcedt_19.$(ALIGN_TYPE).table
	ln -s train.pcedt_19.$(ALIGN_TYPE).table $(DATA_DIR)/train.pcedt_19.table


############################## USING ML FRAMEWORK ###########################

ML_FRAMEWORK=/home/mnovak/projects/ml_framework
RUNS_DIR=tmp/ml/$(ALIGN_ANNOT_ID)
FEATSET_LIST=conf/$(ALIGN_ANNOT_ID).feat.list
STATS_FILE=$(ALIGN_ANNOT_ID).ml.results

baseline_eval : $(GOLD_ANNOT_LIST)
	-treex $(LRC_FLAGS) -L$(ALIGN_ANNOT_LANG) -Ssrc \
		Read::Treex from=@$< \
		My::AlignmentEval align_language=$(ALIGN_ANNOT_LANG2) to='.' substitute='{^.*/([^\/]*)}{tmp/baseline_eval/$$1}'
	find tmp/baseline_eval -name "wsj_19*" | sort | xargs cat | $(ML_FRAMEWORK)/scripts/eval.pl --acc --prf

tte_feats :
	$(MAKE) -C $(ML_FRAMEWORK) tte_feats \
        RANKING=1 \
		CROSS_VALID_N=10 \
        DATA_SOURCE=pcedt_19 \
        DATA_DIR=$(PWD)/$(DATA_DIR) \
        RUNS_DIR=$(PWD)/$(RUNS_DIR) \
        FEATSET_LIST=$(PWD)/$(FEATSET_LIST) \
        STATS_FILE=$(PWD)/$(STATS_FILE)

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

