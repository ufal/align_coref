SHELL=/bin/bash

#=========================================== VARIABLES =====================================================

#-------------------------------------------- DIRS AND PATHS -----------------------------------------

DATA_DIR = data
ORIG_LIST = $(DATA_DIR)/train_19.orig.list

#-------------------------------------------- LRC -----------------------------------------


JOBS_NUM = 10
LRC=1
ifeq (${LRC}, 1)
LRC_FLAGS = -p --qsub '-hard -l mem_free=2G -l act_mem_free=2G -l h_vmem=2G' --jobs ${JOBS_NUM}
endif

#-------------------------------------------- LANG -----------------------------------------

ALIGN_ANNOT_LANG=en
ALIGN_ANNOT_TYPE=$(ALIGN_ANNOT_LANG)_perspron

ifeq ($(ALIGN_ANNOT_LANG),en)
ALIGN_ANNOT_LANG2=cs
else
ALIGN_ANNOT_LANG2=en
endif

#======================================================================================================

annot/$(ALIGN_ANNOT_TYPE)/is_relat.%.sec19.list : $(ORIG_LIST)
	-treex $(LRC_FLAGS) -L$(ALIGN_ANNOT_LANG) -S$* \
		Read::Treex from=@$< \
		Util::Find tnode='use Treex::Tool::Coreference::NodeFilter::PersPron; Treex::Tool::Coreference::NodeFilter::PersPron::is_3rd_pers($$tnode)' \
			| sort > $@

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
ALIGN_ANNOT_LIST=annot/$(ALIGN_ANNOT_TYPE)/is_relat.ref.sec19.list

prepare_align_annot :
	-treex $(LRC_FLAGS) -L$(ALIGN_ANNOT_LANG) -Sref \
		Read::Treex from=@$(ALIGN_ANNOT_LIST) \
		My::AnnotAlignWrite align_lang=$(ALIGN_ANNOT_LANG2) to='.' substitute='{^.*/([^\/]*)}{tmp/annot/$(ALIGN_ANNOT_TYPE)/$$1}' extension='.txt'
	find tmp/annot/$(ALIGN_ANNOT_TYPE) -path "*.txt" -exec cat {} \; > tmp/annot/$(ALIGN_ANNOT_TYPE).all


#================================ IMPORTING THE MANUAL ANNOTATION BACK TO THE TREEBANK =======================

GOLD_ANNOT_FILE=annot/$(ALIGN_ANNOT_TYPE)/subset_to_remove
#GOLD_ANNOT_FILE=annot/$(ALIGN_ANNOT_TYPE)/align.ref.sec19.misko.annot

GOLD_ANNOT_TREES_DIR = $(DATA_DIR)/gold_aligned


import_align : $(ORIG_LIST)
	mkdir -p $(GOLD_ANNOT_TREES_DIR)
	-treex $(LRC_FLAGS) -L$(ALIGN_ANNOT_LANG) -Sref \
		Read::Treex from=@$< \
		My::AlignmentLoader from=$(GOLD_ANNOT_FILE) align_language=$(ALIGN_ANNOT_LANG2) \
		My::ProjectAlignment trg_selector=src \
		Write::Treex path=$(GOLD_ANNOT_TREES_DIR) storable=1

$(DATA_DIR)/gold_aligned.list : annot/$(ALIGN_ANNOT_TYPE)/is_relat.src.sec19.list
	replace=`echo $(GOLD_ANNOT_TREES_DIR) | sed 's/\//\\\\\//g'`; \
	cat $< | sed "s/^.*\//$$replace\//" | sed 's/treex\.gz/streex/g' > $@

skuska : $(DATA_DIR)/gold_aligned.list

extract_data_table : $(DATA_DIR)/gold_aligned.list
	-treex $(LRC_FLAGS) -L$(ALIGN_ANNOT_LANG) -Ssrc \
		Read::Treex from=$< \
		My::PrintAlignData align_language=$(ALIGN_ANNOT_LANG2) to='.' substitute='{^.*/([^\/]*)}{tmp/data_table/$$1}'
