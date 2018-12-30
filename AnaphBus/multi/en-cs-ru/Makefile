
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
########### STAGE 4: TRANSFER ALIGNMENT FROM THE A-LAYER TO THE T_LAYER AND ALIGN GENERATED NODES ############
##############################################################################################################

$(OUTDIR)/04.treex.all_align_to_t/full.list : $(OUTDIR)/03.treex.cs-ru_align_imported/full.list
	$(TREEX) \
		Read::Treex from=@$< \
		Align::T::CopyAlignmentFromAlayer language=en to_language=ru del_prev_align=0 \
		Align::T::AlignGeneratedNodes language=en to_language=ru monolingual=0 \
		Align::T::CopyAlignmentFromAlayer language=cs to_language=ru del_prev_align=0 \
		Align::T::AlignGeneratedNodes language=cs to_language=ru monolingual=0 \
		Write::Treex path=$(dir $@) && \
	find $(dir $@) -name '*.treex.gz' | sed 's|.*/||' | sort > $@

##############################################################################################################
############# STAGE 5: IMPORT ALIGNMENT ANNOTATION FILES PREPARED FOR PCEDT 2.0 COREF  #######################
##############################################################################################################

ALI_ANNOT_DIR=../../align_annot

PHASE01_ALI_ANNOT=$(ALI_ANNOT_DIR)/filled/cs-en.all.align.ref.sec19_00-49.ali_annot

$(OUTDIR)/05.treex.pcedtr_gold_align_import.cs-en.all/full.list : $(OUTDIR)/04.treex.all_align_to_t/full.list
	../bin/import_ali_annot.sh $< $(PHASE01_ALI_ANNOT) $@ "cs-en:gold"

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

PHASE02_ALI_ANNOT=$(ALI_ANNOT_DIR)/filled/en.poss.align.ref.sec19_00-49.ali_annot
PHASE03_ALI_ANNOT=$(ALI_ANNOT_DIR)/filled/cs.poss.align.ref.sec19_00-49.ali_annot
PHASE04_ALI_ANNOT=$(ALI_ANNOT_DIR)/filled/ru.poss.align.ref.sec19_00-49.ali_annot

$(PHASE02_ALI_ANNOT) : LANGUAGE=en
$(PHASE03_ALI_ANNOT) : LANGUAGE=cs
$(PHASE04_ALI_ANNOT) : LANGUAGE=ru
$(PHASE02_ALI_ANNOT) $(PHASE03_ALI_ANNOT) $(PHASE04_ALI_ANNOT) : tmp/pcedtr_with_ru-ref/list
	all_langs=en,cs,ru; \
	align_langs=`echo $$all_langs | perl -ne 'chomp $$_; my @langs = split /,/, $$_; print(join ",", grep {$$_ ne "$(LANGUAGE)"} @langs);'`; \
	treex $(LRC_FLAG) \
		Read::Treex from=@$< \
		Align::Annot::Print language=$(LANGUAGE) selector=ref layers=a align_langs=$$align_langs node_types=perspron.poss only_missing_langs=0 > $@
	sed -i 's/final\.streex/streex/g' $@

# import PCEDT-R align_annot files
$(OUTDIR)/06.treex.pcedtr_gold_align_import.en.poss/full.list : $(OUTDIR)/05.treex.pcedtr_gold_align_import.cs-en.all/full.list
	../bin/import_ali_annot.sh $< $(PHASE02_ALI_ANNOT) $@ "cs-en:gold;ru-cs:gold;en-ru:gold"
$(OUTDIR)/07.treex.pcedtr_gold_align_import.cs.poss/full.list : $(OUTDIR)/06.treex.pcedtr_gold_align_import.en.poss/full.list
	../bin/import_ali_annot.sh $< $(PHASE03_ALI_ANNOT) $@ "cs-en:gold;ru-cs:gold;en-ru:gold"
$(OUTDIR)/08.treex.pcedtr_gold_align_import.ru.poss/full.list : $(OUTDIR)/07.treex.pcedtr_gold_align_import.cs.poss/full.list
	../bin/import_ali_annot.sh $< $(PHASE04_ALI_ANNOT) $@ "cs-en:gold;ru-cs:gold;en-ru:gold"

# project PCEDT-R alignment annotations to the tectogrammatical layer
$(OUTDIR)/09.treex.pcedtr_gold_align.to_ttree/full.list : $(OUTDIR)/08.treex.pcedtr_gold_align_import.ru.poss/full.list
	mkdir -p $(dir $@)
	treex $(LRC_FLAG) \
		Read::Treex from=@$< \
		Align::ProjectAlignment layer=a trg_layer=t aligns="cs-en:gold;ru-cs:gold;en-ru:gold" \
		Write::Treex path=$(dir $@) && \
	find $(dir $@) -name '*.streex' | sed 's|.*/||' | sort > $@

##############################################################################################################
### STAGE 10-12: EXTRACT AND IMPORT NEW ALIGNMENT ANNOTATION FILES FOR YET UNCOVERED NODES (CS, EN, RU)  #####
##############################################################################################################

PHASE05_ALI_ANNOT_CLEAN=$(ALI_ANNOT_DIR)/clean/05.cs.en-ru.relpron.align.ref.sec19_00-49.ali_annot
PHASE06_ALI_ANNOT_CLEAN=$(ALI_ANNOT_DIR)/clean/06.cs.en-ru.perspron.align.ref.sec19_00-49.ali_annot
PHASE07_ALI_ANNOT_CLEAN=$(ALI_ANNOT_DIR)/clean/07.cs.en-ru.perspron_unexpr.align.ref.sec19_00-49.ali_annot
PHASE08_ALI_ANNOT_CLEAN=$(ALI_ANNOT_DIR)/clean/08.cs.en-ru.cor.align.ref.sec19_00-49.ali_annot

$(PHASE05_ALI_ANNOT_CLEAN) : $(OUTDIR)/09.treex.pcedtr_gold_align.to_ttree/full.list
	../bin/prepare_clean_ali_annot.sh $< cs "" t relpron en,ru > $@
$(PHASE06_ALI_ANNOT_CLEAN) : $(OUTDIR)/09.treex.pcedtr_gold_align.to_ttree/full.list
	../bin/prepare_clean_ali_annot.sh $< cs "" t perspron en,ru > $@
$(PHASE07_ALI_ANNOT_CLEAN) : $(OUTDIR)/09.treex.pcedtr_gold_align.to_ttree/full.list
	../bin/prepare_clean_ali_annot.sh $< cs "" t perspron_unexpr en,ru > $@
$(PHASE08_ALI_ANNOT_CLEAN) : $(OUTDIR)/09.treex.pcedtr_gold_align.to_ttree/full.list
	../bin/prepare_clean_ali_annot.sh $< cs "" t cor en,ru > $@

PHASE05_ALI_ANNOT=$(ALI_ANNOT_DIR)/filled/05.cs.en-ru.relpron.align.ref.sec19_00-49.ali_annot
PHASE06_ALI_ANNOT=$(ALI_ANNOT_DIR)/filled/06.cs.en-ru.perspron.align.ref.sec19_00-49.ali_annot
PHASE07_ALI_ANNOT=$(ALI_ANNOT_DIR)/filled/07.cs.en-ru.perspron_unexpr.align.ref.sec19_00-49.ali_annot
PHASE08_ALI_ANNOT=$(ALI_ANNOT_DIR)/filled/08.cs.en-ru.cor.align.ref.sec19_00-49.ali_annot
PHASE0508_ALL_ALI_ANNOT=$(ALI_ANNOT_DIR)/filled/05-08.cs.en-ru.align.ref.sec19_00-49.ali_annot

$(OUTDIR)/10.treex.pcedtr_gold_align_import.cs/full.list : $(OUTDIR)/09.treex.pcedtr_gold_align.to_ttree/full.list
	cat $(PHASE05_ALI_ANNOT) $(PHASE06_ALI_ANNOT) $(PHASE07_ALI_ANNOT) $(PHASE08_ALI_ANNOT) > $(PHASE0508_ALL_ALI_ANNOT)
	../bin/import_ali_annot.sh $< $(PHASE0508_ALL_ALI_ANNOT) $@ "cs-en:gold;ru-cs:gold;en-ru:gold"

PHASE09_ALI_ANNOT_CLEAN=$(ALI_ANNOT_DIR)/clean/09.en.cs-ru.relpron.align.ref.sec19_00-49.ali_annot
PHASE10_ALI_ANNOT_CLEAN=$(ALI_ANNOT_DIR)/clean/10.en.cs-ru.perspron.align.ref.sec19_00-49.ali_annot
PHASE11_ALI_ANNOT_CLEAN=$(ALI_ANNOT_DIR)/clean/11.en.cs-ru.perspron_unexpr.align.ref.sec19_00-49.ali_annot
PHASE12_ALI_ANNOT_CLEAN=$(ALI_ANNOT_DIR)/clean/12.en.cs-ru.cor.align.ref.sec19_00-49.ali_annot

ali_annot_clean09-12 : $(PHASE09_ALI_ANNOT_CLEAN) $(PHASE10_ALI_ANNOT_CLEAN) $(PHASE11_ALI_ANNOT_CLEAN) $(PHASE12_ALI_ANNOT_CLEAN)

$(PHASE09_ALI_ANNOT_CLEAN) : $(OUTDIR)/10.treex.pcedtr_gold_align_import.cs/full.list
	../bin/prepare_clean_ali_annot.sh $< en "" t relpron cs,ru > $@
$(PHASE10_ALI_ANNOT_CLEAN) : $(OUTDIR)/10.treex.pcedtr_gold_align_import.cs/full.list
	../bin/prepare_clean_ali_annot.sh $< en "" t perspron cs,ru > $@
$(PHASE11_ALI_ANNOT_CLEAN) : $(OUTDIR)/10.treex.pcedtr_gold_align_import.cs/full.list
	../bin/prepare_clean_ali_annot.sh $< en "" t perspron_unexpr cs,ru > $@
$(PHASE12_ALI_ANNOT_CLEAN) : $(OUTDIR)/10.treex.pcedtr_gold_align_import.cs/full.list
	../bin/prepare_clean_ali_annot.sh $< en "" t cor cs,ru > $@

PHASE09_ALI_ANNOT=$(ALI_ANNOT_DIR)/filled/09.en.cs-ru.relpron.align.ref.sec19_00-49.ali_annot
PHASE10_ALI_ANNOT=$(ALI_ANNOT_DIR)/filled/10.en.cs-ru.perspron.align.ref.sec19_00-49.ali_annot
PHASE11_ALI_ANNOT=$(ALI_ANNOT_DIR)/filled/11.en.cs-ru.perspron_unexpr.align.ref.sec19_00-49.ali_annot
PHASE12_ALI_ANNOT=$(ALI_ANNOT_DIR)/filled/12.en.cs-ru.cor.align.ref.sec19_00-49.ali_annot
PHASE0912_ALL_ALI_ANNOT=$(ALI_ANNOT_DIR)/filled/09-12.cs.en-ru.align.ref.sec19_00-49.ali_annot

$(OUTDIR)/11.treex.pcedtr_gold_align_import.en/full.list : $(OUTDIR)/10.treex.pcedtr_gold_align_import.cs/full.list
	cat $(PHASE09_ALI_ANNOT) $(PHASE10_ALI_ANNOT) $(PHASE11_ALI_ANNOT) $(PHASE12_ALI_ANNOT) > $(PHASE0912_ALL_ALI_ANNOT)
	../bin/import_ali_annot.sh $< $(PHASE0912_ALL_ALI_ANNOT) $@ "cs-en:gold;ru-cs:gold;en-ru:gold"

PHASE13_ALI_ANNOT_CLEAN=$(ALI_ANNOT_DIR)/clean/13.ru.cs-en.relpron.align.ref.sec19_00-49.ali_annot
PHASE14_ALI_ANNOT_CLEAN=$(ALI_ANNOT_DIR)/clean/14.ru.cs-en.perspron.align.ref.sec19_00-49.ali_annot
PHASE15_ALI_ANNOT_CLEAN=$(ALI_ANNOT_DIR)/clean/15.ru.cs-en.perspron_unexpr.align.ref.sec19_00-49.ali_annot
PHASE16_ALI_ANNOT_CLEAN=$(ALI_ANNOT_DIR)/clean/16.ru.cs-en.cor.align.ref.sec19_00-49.ali_annot

ali_annot_clean13-16 : $(PHASE13_ALI_ANNOT_CLEAN) $(PHASE14_ALI_ANNOT_CLEAN) $(PHASE15_ALI_ANNOT_CLEAN) $(PHASE16_ALI_ANNOT_CLEAN)

$(PHASE13_ALI_ANNOT_CLEAN) : $(OUTDIR)/11.treex.pcedtr_gold_align_import.en/full.list
	../bin/prepare_clean_ali_annot.sh $< ru "" t relpron cs,en > $@
$(PHASE14_ALI_ANNOT_CLEAN) : $(OUTDIR)/11.treex.pcedtr_gold_align_import.en/full.list
	../bin/prepare_clean_ali_annot.sh $< ru "" t perspron cs,en > $@
$(PHASE15_ALI_ANNOT_CLEAN) : $(OUTDIR)/11.treex.pcedtr_gold_align_import.en/full.list
	../bin/prepare_clean_ali_annot.sh $< ru "" t perspron_unexpr cs,en > $@
$(PHASE16_ALI_ANNOT_CLEAN) : $(OUTDIR)/11.treex.pcedtr_gold_align_import.en/full.list
	../bin/prepare_clean_ali_annot.sh $< ru "" t cor cs,en > $@

PHASE13_ALI_ANNOT=$(ALI_ANNOT_DIR)/filled/13.ru.cs-en.relpron.align.ref.sec19_00-49.ali_annot
PHASE14_ALI_ANNOT=$(ALI_ANNOT_DIR)/filled/14.ru.cs-en.perspron.align.ref.sec19_00-49.ali_annot
PHASE16_ALI_ANNOT=$(ALI_ANNOT_DIR)/filled/16.ru.cs-en.cor.align.ref.sec19_00-49.ali_annot
PHASE1316_ALL_ALI_ANNOT=$(ALI_ANNOT_DIR)/filled/13-16.ru.cs-en.align.ref.sec19_00-49.ali_annot

$(OUTDIR)/12.treex.pcedtr_gold_align_import.ru/full.list : $(OUTDIR)/11.treex.pcedtr_gold_align_import.en/full.list
	cat $(PHASE13_ALI_ANNOT) $(PHASE14_ALI_ANNOT) $(PHASE16_ALI_ANNOT) > $(PHASE1316_ALL_ALI_ANNOT)
	../bin/import_ali_annot.sh $< $(PHASE1316_ALL_ALI_ANNOT) $@ "cs-en:gold;ru-cs:gold;en-ru:gold"
