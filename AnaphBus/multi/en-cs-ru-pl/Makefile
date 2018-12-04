
OUTDIR=data

LRC_FLAG=
ifeq ($(LRC),1)
LRC_FLAG=-p --jobs 50 --qsub "-v PERL5LIB=${PWD}/lib"
endif
TREEX=PERL5LIB=${PWD}/lib:${PERL5LIB} treex $(LRC_FLAG)

##############################################################################################################
###################### STAGE 1: MERGE EN-CS-RU MULTI PART WITH A PL MONOLINGUAL PART #########################
##############################################################################################################

MONO_DIR=../../mono

######## versions to make an illustrating figure for the LREC/CRAC paper #######
#EN_CS_RU_MULTI_LIST=../en-cs-ru/data/04.treex.all_align_to_t/for_LREC_2018.list
#PL_MONO_LIST=$(MONO_DIR)/pl/data/02b.annot_sample_by_Anja/for_LREC_2018.list
#
#merge_parts : $(OUTDIR)/01a.treex.merged_parts/for_LREC_2018.list
#$(OUTDIR)/01a.treex.merged_parts/for_LREC_2018.list : $(EN_CS_RU_MULTI_LIST) $(PL_MONO_LIST)

EN_CS_RU_MULTI_LIST=../en-cs-ru/data/10.treex.pcedtr_gold_align_import.cs/full.list
PL_MONO_LIST=$(MONO_DIR)/pl/data/02.tecto.after_coref_annot/full.list

merge_parts : $(OUTDIR)/01.treex.merged_parts/full.list
$(OUTDIR)/01.treex.merged_parts/full.list : $(EN_CS_RU_MULTI_LIST) $(PL_MONO_LIST)
	mkdir -p $(dir $@)
	cat $< | while read file; do \
		for dir in $(dir $^); do \
			echo $$dir/$$file; \
		done | xargs ../bin/merge_mono.pl $(dir $@)/$$file; \
	done && \
	find $(dir $@) -name '*.treex.gz' | sed 's|.*/||' | sort > $@

##############################################################################################################
################## STAGE 2-4: IMPORT AND TRANSFORM EN-PL, RU-PL, CS-PL ALIGNMENTS ############################
##############################################################################################################

ALIGN4TREEX=../../align4treex/scripts/run.sh

# use align4treex to train and import alignments
# this stage takse very long
#	LRC=$(LRC) RUN_DIR=/home/mnovak/projects/align_coref/AnaphBus/multi/en-cs-ru-pl/tmp/align4treex/007_2018-05-23_23-35-09_gRJks EXTRA_NAME=all EXTRA_SAMPLE_PERC=30 $(ALIGN4TREEX) '!'$(dir $<)'*.treex.gz' $(dir $@) en-pl &&
$(OUTDIR)/02.treex.en-pl_align_imported/full.list : $(OUTDIR)/01.treex.merged_parts/full.list
	LRC=$(LRC) TMPDIR=$(PWD)/tmp EXTRA_NAME=all EXTRA_SAMPLE_PERC=30 $(ALIGN4TREEX) '!'$(dir $<)'*.treex.gz' $(dir $@) en-pl && \
	find $(dir $@) -name '*.treex.gz' | sed 's|.*/||' | sort > $@

$(OUTDIR)/03.treex.ru-pl_align_imported/full.list : $(OUTDIR)/02.treex.en-pl_align_imported/full.list
	LRC=$(LRC) TMPDIR=$(PWD)/tmp EXTRA_NAME=all EXTRA_SAMPLE_PERC=80 $(ALIGN4TREEX) '!'$(dir $<)'*.treex.gz' $(dir $@) ru-pl && \
	find $(dir $@) -name '*.treex.gz' | sed 's|.*/||' | sort > $@

$(OUTDIR)/04.treex.cs-pl_align_imported/full.list : $(OUTDIR)/03.treex.ru-pl_align_imported/full.list
	LRC=$(LRC) TMPDIR=$(PWD)/tmp EXTRA_NAME=all EXTRA_SAMPLE_PERC=40 $(ALIGN4TREEX) '!'$(dir $<)'*.treex.gz' $(dir $@) cs-pl && \
	find $(dir $@) -name '*.treex.gz' | sed 's|.*/||' | sort > $@
