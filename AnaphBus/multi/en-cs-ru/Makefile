
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

##############################################################################################################
############# STAGE 5: IMPORT ALIGNMENT ANNOTATION FILES PREPARED FOR PCEDT 2.0 COREF  #######################
##############################################################################################################

ALI_ANNOT_DIR=../../align_annot

PHASE1_ALI_ANNOT=$(ALI_ANNOT_DIR)/filled/cs-en.all.align.ref.sec19_00-49.ali_annot

$(OUTDIR)/05.treex.pcedtr_gold_align_import.cs-en.all/full.list : $(OUTDIR)/04.treex.all_align_to_t/full.list
	../bin/import_ali_annot.sh $< $(PHASE1_ALI_ANNOT) $@ "cs-en:gold"

##############################################################################################################
################# STAGE 6-9: IMPORT ALIGNMENT ANNOTATION FILES PREPARED FOR PCEDT-R  ###########################
##############################################################################################################

# The released PCEDT-R does not contain align_info wild attributes. We need to use the intermediate files 
# from which the PCEDT-R release was generated -> PCEDT-R intermediate data.
# Intermediate data have no "ru_ref" zone and all alignment covering Russian lies in the "src" zone => it aligns Russian
# words with those from the automatically analyzed trees - the tokenization differs. To rectify this we have to:
# 1) create Russian "ref" zone just by copying its "src" and project all gold aligns to the "ref".
# 		Analysis must be run to get the PDT form of pos tags for the NodeType filter to work.
# 2) extract ali_annot files annotated fo PCEDT-R from the "ref" zone

PCEDTR_INTER_DATA=/lnet/tspec/tmp/mnovak/tmp/pcedt-r/05.ru-with-ru.poss.import/list

tmp/pcedtr_with_ru-ref/list : $(PCEDTR_INTER_DATA)
	mkdir -p $(dir $@)
	treex $(LRC_FLAG) -Lru -Sref \
		Read::Treex from=@$< \
		A2A::CopyAtree source_selector=src align=1 \
		Scen::Analysis::RU tokenized=1 tecto=none \
		Align::ProjectAlignment layer=a selector=src trg_selector=ref aligns="cs-en:gold;ru-cs:gold;en-ru:gold" \
		Write::Treex path=$(dir $@) && \
	find $(dir $@) -name '*.streex' | sed 's|.*/||' | sort > $@

PHASE2_ALI_ANNOT=$(ALI_ANNOT_DIR)/filled/en.poss.align.ref.sec19_00-49.ali_annot
PHASE3_ALI_ANNOT=$(ALI_ANNOT_DIR)/filled/cs.poss.align.ref.sec19_00-49.ali_annot
PHASE4_ALI_ANNOT=$(ALI_ANNOT_DIR)/filled/ru.poss.align.ref.sec19_00-49.ali_annot

$(PHASE2_ALI_ANNOT) : LANGUAGE=en
$(PHASE3_ALI_ANNOT) : LANGUAGE=cs
$(PHASE4_ALI_ANNOT) : LANGUAGE=ru
$(PHASE2_ALI_ANNOT) $(PHASE3_ALI_ANNOT) $(PHASE4_ALI_ANNOT) : tmp/pcedtr_with_ru-ref/list
	all_langs=en,cs,ru; \
	align_langs=`echo $$all_langs | perl -ne 'chomp $$_; my @langs = split /,/, $$_; print(join ",", grep {$$_ ne "$(LANGUAGE)"} @langs);'`; \
	treex $(LRC_FLAG) \
		Read::Treex from=@$< \
		Align::Annot::Print language=$(LANGUAGE) selector=ref layers=a align_langs=$$align_langs node_types=perspron.poss only_missing_langs=0 > $@
	sed -i 's/final\.streex/streex/g' $@

# import PCEDT-R align_annot files
$(OUTDIR)/06.treex.pcedtr_gold_align_import.en.poss/full.list : $(OUTDIR)/05.treex.pcedtr_gold_align_import.cs-en.all/full.list
	../bin/import_ali_annot.sh $< $(PHASE2_ALI_ANNOT) $@ "cs-en:gold;ru-cs:gold;en-ru:gold"
$(OUTDIR)/07.treex.pcedtr_gold_align_import.cs.poss/full.list : $(OUTDIR)/06.treex.pcedtr_gold_align_import.en.poss/full.list
	../bin/import_ali_annot.sh $< $(PHASE3_ALI_ANNOT) $@ "cs-en:gold;ru-cs:gold;en-ru:gold"
$(OUTDIR)/08.treex.pcedtr_gold_align_import.ru.poss/full.list : $(OUTDIR)/07.treex.pcedtr_gold_align_import.cs.poss/full.list
	../bin/import_ali_annot.sh $< $(PHASE4_ALI_ANNOT) $@ "cs-en:gold;ru-cs:gold;en-ru:gold"

# project PCEDT-R alignment annotations to the tectogrammatical layer
$(OUTDIR)/09.treex.pcedtr_gold_align.to_ttree/full.list : $(OUTDIR)/08.treex.pcedtr_gold_align_import.ru.poss/full.list
	mkdir -p $(dir $@)
	treex $(LRC_FLAG) \
		Read::Treex from=@$< \
		Align::ProjectAlignment layer=a trg_layer=t aligns="cs-en:gold;ru-cs:gold;en-ru:gold" \
		Write::Treex path=$(dir $@) && \
	find $(dir $@) -name '*.streex' | sed 's|.*/||' | sort > $@
