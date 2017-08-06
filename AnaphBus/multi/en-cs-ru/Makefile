
OUTDIR=data

TREEX=PERL5LIB=${PWD}/lib:${PERL5LIB} treex --qsub "-v PERL5LIB=${PWD}/lib"

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
