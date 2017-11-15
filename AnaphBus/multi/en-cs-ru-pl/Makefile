
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

EN_CS_RU_MULTI_LIST=../en-cs-ru/data/04.treex.all_align_to_t/for_LREC_2018.list
PL_MONO_LIST=$(MONO_DIR)/pl/data/02b.annot_sample_by_Anja/for_LREC_2018.list

merge_parts : $(OUTDIR)/01.treex.merged_parts/for_LREC_2018.list
$(OUTDIR)/01.treex.merged_parts/for_LREC_2018.list : $(EN_CS_RU_MULTI_LIST) $(PL_MONO_LIST)
	mkdir -p $(dir $@)
	cat $< | while read file; do \
		for dir in $(dir $^); do \
			echo $$dir/$$file; \
		done | xargs ../bin/merge_mono.pl $(dir $@)/$$file; \
	done && \
	find $(dir $@) -name '*.treex.gz' | sed 's|.*/||' | sort > $@
