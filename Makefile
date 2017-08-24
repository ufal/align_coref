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
LRC_FLAGS = -p --priority "-1" -m 10g --jobs ${JOBS}
#LRC_FLAGS = -p --priority "-1" --qsub '-hard -l mem_free=2G -l act_mem_free=2G -l h_vmem=2G' --jobs ${JOBS}
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
#ALIGN_TYPE=mgiza_on_czeng
# version 0026.no_coref_supervised_align of pcedt_bi
ALIGN_TYPE=0026.no_coref_supervised_align

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

##########################################################################################
################################# ALIGNMENT RESOLUTION  ##################################
##########################################################################################

ANAPH_TYPE=all_anaph
SELECTOR=ref

# old trees
#EVAL_GOLD_ANNOT_TREES_DIR=$(GOLD_ANNOT_TREES_DIR)
# new trees with extended #Cors
EVAL_GOLD_ANNOT_TREES_DIR=${COREF_BITEXT_DIR}/data/analysed/pcedt/wsj1900-49/0026.no_coref_supervised_align
REF_EVAL_DIR=$(GOLD_ANNOT_TREES_DIR)

###################### ORIGINAL AND RULE-BASED ALIGNMENT #####################

baseline_src_% : $(EVAL_GOLD_ANNOT_TREES_DIR)/%.list
	rm -rf tmp/baseline/$*.$(ALIGN_ANNOT_LANG).src.$(ANAPH_TYPE)
	mkdir -p tmp/baseline/$*.$(ALIGN_ANNOT_LANG).src.$(ANAPH_TYPE)
	-treex $(LRC_FLAGS) -L$(ALIGN_ANNOT_LANG) -Ssrc \
		Read::Treex from=@$< \
		Align::T::Eval align_reltypes='!gold,!coref_gold,!supervised,!coref_supervised,!robust,.*' align_language=$(ALIGN_ANNOT_LANG2) node_types=$(ANAPH_TYPE) to='.' substitute='{^.*/([^\/]*)}{tmp/baseline/$*.$(ALIGN_ANNOT_LANG).src.$(ANAPH_TYPE)/$$1}' && \
	find tmp/baseline/$*.$(ALIGN_ANNOT_LANG).src.$(ANAPH_TYPE) -name "wsj_19*" | sort | xargs cat | $(ML_FRAMEWORK_DIR)/scripts/eval.pl --acc --prf

baseline_ref_% : $(REF_EVAL_DIR)/%.list
	rm -rf tmp/baseline/$*.$(ALIGN_ANNOT_LANG).ref.$(ANAPH_TYPE)
	mkdir -p tmp/baseline/$*.$(ALIGN_ANNOT_LANG).ref.$(ANAPH_TYPE)
	-treex $(LRC_FLAGS) -L$(ALIGN_ANNOT_LANG) -Sref \
		Read::Treex from=@$< \
		Align::T::Eval align_reltypes='!gold,!coref_gold,!supervised,!coref_supervised,!robust,.*' align_language=$(ALIGN_ANNOT_LANG2) node_types=$(ANAPH_TYPE) to='.' substitute='{^.*/([^\/]*)}{tmp/baseline/$*.$(ALIGN_ANNOT_LANG).ref.$(ANAPH_TYPE)/$$1}' && \
	find tmp/baseline/$*.$(ALIGN_ANNOT_LANG).ref.$(ANAPH_TYPE) -name "wsj_19*" | sort | xargs cat | $(ML_FRAMEWORK_DIR)/scripts/eval.pl --acc --prf

rule-based_% : $(EVAL_GOLD_ANNOT_TREES_DIR)/%.list
	rm -rf tmp/rule-based/$*.$(ALIGN_ANNOT_LANG).$(SELECTOR).$(ANAPH_TYPE)
	mkdir -p tmp/rule-based/$*.$(ALIGN_ANNOT_LANG).$(SELECTOR).$(ANAPH_TYPE)
	-treex $(LRC_FLAGS) -L$(ALIGN_ANNOT_LANG) -S$(SELECTOR) \
		Read::Treex from=@$< \
		My::AddRobustAlignment::CsRelpron remove_original=1 language=cs \
		My::AddRobustAlignment::EnPerspron remove_original=1 language=en \
		Align::T::Eval align_reltypes='!gold,!supervised,robust,.*' align_language=$(ALIGN_ANNOT_LANG2) node_types=$(ANAPH_TYPE) to='.' substitute='{^.*/([^\/]*)}{tmp/rule-based/$*.$(ALIGN_ANNOT_LANG).$(SELECTOR).$(ANAPH_TYPE)/$$1}' && \
	find tmp/rule-based/$*.$(ALIGN_ANNOT_LANG).$(SELECTOR).$(ANAPH_TYPE) -name "wsj_19*" | sort | xargs cat | $(ML_FRAMEWORK_DIR)/scripts/eval.pl --acc --prf

######################## DATA TABLE EXTRACTION ###############################

FULL_DATA=$(DATA_DIR)/full.$(ALIGN_ANNOT_LANG).$(SELECTOR).$(ANAPH_TYPE).pcedt_19.table
TRAIN_DATA=$(DATA_DIR)/train.$(ALIGN_ANNOT_LANG).$(SELECTOR).$(ANAPH_TYPE).pcedt_19.table
DEV_DATA=$(DATA_DIR)/dev.$(ALIGN_ANNOT_LANG).$(SELECTOR).$(ANAPH_TYPE).pcedt_19.table
EVAL_DATA=$(DATA_DIR)/eval.$(ALIGN_ANNOT_LANG).$(SELECTOR).$(ANAPH_TYPE).pcedt_19.table

extract_data_table : $(FULL_DATA) $(TRAIN_DATA) $(DEV_DATA) $(EVAL_DATA)
#extract_data_table : $(FULL_DATA)

$(DATA_DIR)/%.$(ALIGN_ANNOT_LANG).$(SELECTOR).$(ANAPH_TYPE).pcedt_19.table : $(EVAL_GOLD_ANNOT_TREES_DIR)/%.list
	mkdir -p tmp/data_table/$*.$(ALIGN_ANNOT_LANG).$(SELECTOR).$(ANAPH_TYPE).pcedt_19/trees
	mkdir -p tmp/data_table/$*.$(ALIGN_ANNOT_LANG).$(SELECTOR).$(ANAPH_TYPE).pcedt_19/tables
	-treex $(LRC_FLAGS) -L$(ALIGN_ANNOT_LANG) -S$(SELECTOR) \
		Read::Treex from=@$< \
		Align::ProjectAlignment layer=t selector=ref trg_selector=$(SELECTOR) aligns="$(ALIGN_ANNOT_LANG)-$(ALIGN_ANNOT_LANG2):coref_gold,gold" \
		Write::Treex path=tmp/data_table/$*.$(ALIGN_ANNOT_LANG).$(SELECTOR).$(ANAPH_TYPE).pcedt_19/trees \
		Align::T::Supervised::PrintData align_language=$(ALIGN_ANNOT_LANG2) node_types=$(ANAPH_TYPE) to='.' substitute='{^.*/([^\/]*)}{tmp/data_table/$*.$(ALIGN_ANNOT_LANG).$(SELECTOR).$(ANAPH_TYPE).pcedt_19/tables/$$1}'
	find tmp/data_table/$*.$(ALIGN_ANNOT_LANG).$(SELECTOR).$(ANAPH_TYPE).pcedt_19/tables -name "wsj_19*" | sort | xargs cat | gzip -c > $(DATA_DIR)/$*.$(ALIGN_ANNOT_LANG).$(SELECTOR).$(ANAPH_TYPE).pcedt_19.$(ALIGN_TYPE).table
	ln -s $*.$(ALIGN_ANNOT_LANG).$(SELECTOR).$(ANAPH_TYPE).pcedt_19.$(ALIGN_TYPE).table $(DATA_DIR)/$*.$(ALIGN_ANNOT_LANG).$(SELECTOR).$(ANAPH_TYPE).pcedt_19.table


############################## USING ML FRAMEWORK ###########################

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

#RUNS_DIR=tmp/ml/$(ALIGN_ANNOT_ID)
#FEATSET_LIST=conf/$(ALIGN_ANNOT_ID).feat.list
#
#self_training :
#	$(MAKE) -C $(ML_FRAMEWORK) self_training \
#        RANKING=1 \
#        DATA_SOURCE=pcedt_19 \
#        DATA_DIR=$(PWD)/$(DATA_DIR) \
#        RUNS_DIR=$(PWD)/tmp/testing_self_training \
#        FEATSET_LIST=$(PWD)/$(FEATSET_LIST) \
#		ML_METHOD=vw.ranking \
#		ML_PARAMS="mc --loss_function logistic --passes 10" \
#		FEAT_LIST="__SELF__,n1_functor,n2_functor"

			#make baseline_full SELECTOR=ref ANAPH_TYPE=$$node_type ALIGN_ANNOT_LANG=$$lang D="$$lang $$node_type on ref - for LREC abstract";
			#make rule-based_full SELECTOR=ref ANAPH_TYPE=$$node_type ALIGN_ANNOT_LANG=$$lang D="$$lang $$node_type on ref - for LREC abstract";
test_all:
	for lang in en cs; do \
		for node_type in perspron relpron zero all_anaph; do \
			make extract_data_table SELECTOR=ref ANAPH_TYPE=$$node_type ALIGN_ANNOT_LANG=$$lang D="$$lang $$node_type on ref - for LREC abstract"; \
			make cross_valid SELECTOR=ref ANAPH_TYPE=$$node_type ALIGN_ANNOT_LANG=$$lang D="$$lang $$node_type on ref - for LREC abstract"; \
		done; \
	done


##################### DIAGNOSTICS ##########################################

show_errors : tmp/show_errors/full.$(ALIGN_ANNOT_LANG).$(SELECTOR).$(ANAPH_TYPE).err
	less -SR $<

tmp/show_errors/%.$(ALIGN_ANNOT_LANG).$(SELECTOR).$(ANAPH_TYPE).err : $(GOLD_ANNOT_TREES_DIR)/%.list
	-treex $(LRC_FLAGS) -e DEBUG -L$(ALIGN_ANNOT_LANG) -S$(SELECTOR) \
		Read::Treex from=@$< \
		Util::SetGlobal align_language=en node_types=relpron \
		Align::T::Supervised::Resolver language=en,cs align_trg_lang=en delete_orig_align=0 \
		Align::T::Compare language=$(ALIGN_ANNOT_LANG) pred_align_type='supervised' > $@

####################################################################################################
########################### DOCUMENT-BASED 10-FOLD CROSS-VALIDATION ################################
######### TO OBTAIN UNBIASED ANNOTATION OF SUPERVISED ALIGNMENT ON THE WSJ_1900-49 DATA ############
####################################################################################################

DOC_CROSS_VAL_DIR=$(DATA_DIR)/docbased_crossval/$(ALIGN_ANNOT_LANG).$(SELECTOR)

################# TRAIN: CREATE 10 DATA FOLDS, TRAIN AND EVAL MODELS ON THEM ###############

# !!! uncomment the following line, if you want to train a "ref" model
#EVAL_GOLD_ANNOT_TREES_DIR=$(GOLD_ANNOT_TREES_DIR)

$(DOC_CROSS_VAL_DIR)/%/done :
	mkdir -p $(dir $@)
	mkdir -p $(dir $@)/tmp/data.parts
	mkdir -p $(dir $@)/trees
	cat $(EVAL_GOLD_ANNOT_TREES_DIR)/full.list | grep 'wsj_19.$*' | sed 's#^#$(realpath $(EVAL_GOLD_ANNOT_TREES_DIR))/#' > $(dir $@)/test.list && \
	cat $(EVAL_GOLD_ANNOT_TREES_DIR)/full.list | grep -v 'wsj_19.$*' | sed 's#^#$(realpath $(EVAL_GOLD_ANNOT_TREES_DIR))/#' > $(dir $@)/train.list && \
	for l in $(dir $@)/test.list $(dir $@)/train.list; do \
		data=$${l%.list}.data; \
		treex $(LRC_FLAGS) -L$(ALIGN_ANNOT_LANG) -S$(SELECTOR) \
			Read::Treex from=@$$l \
			Align::ProjectAlignment layer=t selector=ref trg_selector=$(SELECTOR) aligns="$(ALIGN_ANNOT_LANG)-$(ALIGN_ANNOT_LANG2):coref_gold,gold" \
			Write::Treex path=$(dir $@)/trees \
			Align::T::Supervised::PrintData align_language=$(ALIGN_ANNOT_LANG2) node_types=$(ANAPH_TYPE) | \
		gzip -c > $$data; \
	done && \
	touch $@

$(DOC_CROSS_VAL_DIR)/%/ml.done : $(DOC_CROSS_VAL_DIR)/%/done
	$(ML_FRAMEWORK_DIR)/run.sh -f conf/params.ini \
        EXPERIMENT_TYPE=train_test \
        DATA_LIST="TRAIN_DATA DEV_DATA" \
        TRAIN_DATA=$(dir $@)/train.data \
        DEV_DATA=$(dir $@)/test.data \
        FEATSET_LIST=conf/featset.list \
        ML_METHOD_LIST=conf/ml_method.list \
        LRC=$(LRC) \
        TMP_DIR=$(dir $@)/tmp/ml \
        D="crossval models for wsj1900-49" && \
	touch $@

$(DATA_DIR)/docbased_crossval/%/all.done :
	lang=`echo "$*" | cut -f1 -d'.'`; \
	sel=`echo "$*" | cut -f2 -d'.'`; \
	mkdir -p $(dir $@); \
	for i in `seq 0 9`; do \
		echo "Running model training on fold no. $$i..." >&2; \
		$(MAKE) $(dir $@)$$i/ml.done ALIGN_ANNOT_LANG=$$lang SELECTOR=$$sel LRC=$(LRC) > $(dir $@)/run.$$i.log 2>&1 & \
		sleep 10; \
	done
	while [ `ls $(dir $@)/*/ml.done | wc -w` -lt 10 ]; do \
		sleep 10; \
	done

################# RESOLVE USING MODELS TRAINED ON 10 DATA FOLDS AND EVALUATE ####################
######## see $COREF_BITEXT_DIR/makefile.wsj1900-49.data_gener how the data was created ##########

#SRC_SUPERVISED_TO_EVAL_DIR=${COREF_BITEXT_DIR}/data/analysed/pcedt/wsj1900-49/0025.retrained_supervised_align.resolve_fixed_1
SRC_SUPERVISED_TO_EVAL_DIR=${COREF_BITEXT_DIR}/data/analysed/pcedt/wsj1900-49/0026

supervised_src_% : $(SRC_SUPERVISED_TO_EVAL_DIR)/%.list
	rm -rf tmp/supervised/$*.$(ALIGN_ANNOT_LANG).src.$(ANAPH_TYPE)
	mkdir -p tmp/supervised/$*.$(ALIGN_ANNOT_LANG).src.$(ANAPH_TYPE)
	treex $(LRC_FLAGS) -L$(ALIGN_ANNOT_LANG) -Ssrc \
		Read::Treex from=@$< \
		Align::T::Eval align_language=$(ALIGN_ANNOT_LANG2) align_reltypes='supervised,coref_supervised' node_types=$(ANAPH_TYPE) to='.' substitute='{^.*/([^\/]*)}{tmp/supervised/$*.$(ALIGN_ANNOT_LANG).src.$(ANAPH_TYPE)/$$1}' && \
	find tmp/supervised/$*.$(ALIGN_ANNOT_LANG).src.$(ANAPH_TYPE) -name "wsj_19*" | sort | xargs cat | $(ML_FRAMEWORK_DIR)/scripts/eval.pl --acc --prf

supervised_ref_% : $(REF_EVAL_DIR)/%.list
	rm -rf tmp/supervised/$*.$(ALIGN_ANNOT_LANG).ref.$(ANAPH_TYPE)
	mkdir -p tmp/supervised/$*.$(ALIGN_ANNOT_LANG).ref.$(ANAPH_TYPE)
	for i in `seq 0 9`; do \
		en_model=`cat ~/projects/align_coref/data/docbased_crossval/en.ref/$$i/tmp/ml/*/best_acc.model | tail -n1 | cut -f2`; \
		cs_model=`cat ~/projects/align_coref/data/docbased_crossval/cs.ref/$$i/tmp/ml/*/best_acc.model | tail -n1 | cut -f2`; \
		cat $< | grep "wsj_19.$$i" | sed 's#^#$(realpath $(REF_EVAL_DIR))/#' > tmp/supervised/$*.$(ALIGN_ANNOT_LANG).ref.$(ANAPH_TYPE)/part$$i.list; \
		treex $(LRC_FLAGS) -L$(ALIGN_ANNOT_LANG) -Sref \
			Read::Treex from=@tmp/supervised/$*.$(ALIGN_ANNOT_LANG).ref.$(ANAPH_TYPE)/part$$i.list \
			Align::T::Supervised::Resolver language=en,cs align_trg_lang=en model_path="$$en_model,$$cs_model" node_types=all_anaph \
			Write::Treex path=tmp/supervised/$*.$(ALIGN_ANNOT_LANG).ref.$(ANAPH_TYPE) \
			Align::T::Eval align_language=$(ALIGN_ANNOT_LANG2) align_reltypes='supervised,coref_supervised' node_types=$(ANAPH_TYPE) to='.' substitute='{^.*/([^\/]*)}{tmp/supervised/$*.$(ALIGN_ANNOT_LANG).ref.$(ANAPH_TYPE)/$$1.txt}' \
		> tmp/supervised/$*.$(ALIGN_ANNOT_LANG).ref.$(ANAPH_TYPE)/log.wsj1900-49.pcedt.data_gener.$$i 2>&1 && \
		touch tmp/supervised/$*.$(ALIGN_ANNOT_LANG).ref.$(ANAPH_TYPE)/done.wsj1900-49.pcedt.data_gener.$$i & \
	done
	while [ `ls tmp/supervised/$*.$(ALIGN_ANNOT_LANG).ref.$(ANAPH_TYPE)/done.wsj1900-49.pcedt.data_gener.* | wc -w` -lt 10 ]; do \
		sleep 10; \
	done
	rm tmp/supervised/$*.$(ALIGN_ANNOT_LANG).ref.$(ANAPH_TYPE)/done.wsj1900-49.pcedt.data_gener.*
	find tmp/supervised/$*.$(ALIGN_ANNOT_LANG).ref.$(ANAPH_TYPE) -name "wsj_19*.txt" | sort | xargs cat | $(ML_FRAMEWORK_DIR)/scripts/eval.pl --acc --prf
