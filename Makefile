SHELL=/bin/bash

DATA_SET = train
DATA_ID = pcedt

DATA_VERSION := $(shell cat data/analysed/$(DATA_ID)/$(DATA_SET)/last_id 2> /dev/null || echo 0000)
DATA_DIR=data/analysed/$(DATA_ID)/$(DATA_SET)/$(DATA_VERSION)

JOBS_NUM = 50

ifeq (${DATA_SET}, train)
JOBS_NUM = 100
endif

LRC=1
ifeq (${LRC}, 1)
LRC_FLAGS = -p --qsub '-hard -l mem_free=8G -l act_mem_free=8G -l h_vmem=8G' --jobs ${JOBS_NUM}
endif

#=========================================== VARIABLES =====================================================

ALIGN_ANNOT_LANG=en
ALIGN_ANNOT_TYPE=$(ALIGN_ANNOT_LANG)_perspron

ifeq ($(ALIGN_ANNOT_LANG),en)
ALIGN_ANNOT_LANG2=cs
else
ALIGN_ANNOT_LANG2=en
endif

#=================================== PREPARE DATA FOR MANUAL ANNOTATION ==================================

add_robust_ali :
	-treex $(LRC_FLAGS) -Sref \
		Read::Treex from=@$(DATA_DIR)/list \
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
GOLD_ANNOT_TREES_DIR=tmp/annot/$(ALIGN_ANNOT_TYPE)/trees_manual_annot

import_align :
	-treex $(LRC_FLAGS) -L$(ALIGN_ANNOT_LANG) -Sref \
		Read::Treex from=@$(DATA_DIR)/list \
		My::AlignmentLoader from=$(GOLD_ANNOT_FILE) align_language=$(ALIGN_ANNOT_LANG2) \
		My::ProjectAlignment trg_selector=src \
		Write::Treex path=$(GOLD_ANNOT_TREES_DIR)
