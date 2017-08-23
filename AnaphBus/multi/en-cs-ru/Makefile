
OUTDIR=data

LRC_FLAG=
ifeq ($(LRC),1)
LRC_FLAG=-p --jobs 50 --qsub "-v PERL5LIB=${PWD}/lib"
endif
TREEX=PERL5LIB=${PWD}/lib:${PERL5LIB} treex $(LRC_FLAG)

##############################################################################################################
###################### STAGE 1: MERGE MONOLINGUAL PARTS TO A PARALLEL TREEX DOCUMENT #########################
##############################################################################################################

MONO_DIR=../../mono

EN_CS_MONO_LIST=$(MONO_DIR)/en-cs/data/04.tecto.after_coref_annot/full.list
RU_MONO_LIST=$(MONO_DIR)/ru/data/04.tecto.after_coref_annot/full.list

merge_parts : $(OUTDIR)/01.treex.merged_parts/full.list
$(OUTDIR)/01.treex.merged_parts/full.list : $(EN_CS_MONO_LIST) $(RU_MONO_LIST)
	mkdir -p $(dir $@)
	cat $< | while read file; do \
		for dir in $(dir $^); do \
			echo $$dir/$$file; \
		done | xargs ../bin/merge_mono.pl $(dir $@)/$$file; \
	done && \
	find $(dir $@) -name '*.treex.gz' | sed 's|.*/||' | sort > $@

##############################################################################################################
############## STAGE 2a: AN ALTERNATIVE VERSION OF IMPORT AND TRANSFORM EN-RU ALIGNMENTS #####################
##############################################################################################################

EN_RU_ALIGN=../../align_train/en-ru/data/03.giza/wsj_1900-49.en_ru.giza.gz

# the alternative version uses align4treex, however, only the pre- and post-processing
# it does not run GIZA as it was run before and the alignments for both en-ru and cs-ru data are ready
$(OUTDIR)/02a.treex.en-ru_align_imported/full.list : $(OUTDIR)/01.treex.merged_parts/full.list
	LRC=$(LRC) ../bin/import_align_alternative.sh '!'$(dir $<)'*.treex.gz' $(EN_RU_ALIGN) $(dir $@) en-ru && \
	find $(dir $@) -name '*.treex.gz' | sed 's|.*/||' | sort > $@

##############################################################################################################
############### STAGE 3: THE STANDARD VERSION OF IMPORT AND TRANSFORM CS-RU ALIGNMENTS #######################
##############################################################################################################

ALIGN4TREEX=../../align4treex/scripts/run.sh

# the alternative version uses align4treex, however, only the pre- and post-processing
# it does not run GIZA as it was run before and the alignments for both en-ru and cs-ru data are ready
$(OUTDIR)/03.treex.cs-ru_align_imported/full.list : $(OUTDIR)/02a.treex.en-ru_align_imported/full.list
	LRC=$(LRC) TMPDIR=$(PWD)/tmp EXTRA_NAME=total EXTRA_SAMPLE_PERC=80 $(ALIGN4TREEX) '!'$(dir $<)'*.treex.gz' $(dir $@) cs-ru && \
	find $(dir $@) -name '*.treex.gz' | sed 's|.*/||' | sort > $@

##############################################################################################################
##################### STAGE 4: TRANSFER ALIGNMENT FROM THE A-LAYER TO THE T_LAYER ############################
##############################################################################################################

$(OUTDIR)/04.treex.all_align_to_t/full.list : $(OUTDIR)/03.treex.cs-ru_align_imported/full.list
	$(TREEX) \
		Read::Treex from=@$< \
		Align::T::CopyAlignmentFromAlayer language=en to_language=ru del_prev_align=0 \
		Align::T::CopyAlignmentFromAlayer language=cs to_language=ru del_prev_align=0 \
		Write::Treex path=$(dir $@) && \
	find $(dir $@) -name '*.treex.gz' | sed 's|.*/||' | sort > $@

