PCERDT_19_ORIG=../ru_cs_align/out/pcerdt_19_giza/full.list

PHASE1_ALI_ANNOT=ali_annot/filled/cs-en.all.align.ref.sec19_00-49.ali_annot
PHASE2_ALI_ANNOT=ali_annot/filled/en.poss.align.src.sec19_00-49.ali_annot
PHASE3_ALI_ANNOT=ali_annot/filled/cs.poss.align.src.sec19_00-49.ali_annot
PHASE4_ALI_ANNOT=ali_annot/filled/ru.poss.align.src.sec19_00-49.ali_annot

PHASE2_ALI_ANNOT_CLEAN=ali_annot/clean/en.poss.align.src.sec19_00-49.ali_annot
PHASE3_ALI_ANNOT_CLEAN=ali_annot/clean/cs.poss.align.src.sec19_00-49.ali_annot
PHASE4_ALI_ANNOT_CLEAN=ali_annot/clean/ru.poss.align.src.sec19_00-49.ali_annot

####################################################################################################################
#############################################       PHASE 1      ###################################################
############ take PCERDT files (GIZA annotation on src only) and import CS-EN gold alignments ######################
####################################################################################################################


../tmp/testing_import_ali_annot/01.cs-en.all.import/list : $(PCERDT_19_ORIG)
	bin/import_ali_annot.sh $< $(PHASE1_ALI_ANNOT) $@ "cs-en:gold"

####################################################################################################################
#############################################       PHASE 2      ###################################################
################ project all gold alignments from "ref" to "src" and from "t" to "a"  ##############################
####################################################################################################################

project_cs-en : ../tmp/testing_import_ali_annot/02.cs-en.all.project/list
../tmp/testing_import_ali_annot/02.cs-en.all.project/list : ../tmp/testing_import_ali_annot/01.cs-en.all.import/list
	mkdir -p $(dir $@)
	treex -p --jobs 50 \
		Read::Treex from=@$< \
		Align::ProjectAlignment layer=a selector=ref trg_selector=src aligns="cs-en:gold" \
		Align::ProjectAlignment layer=t selector=ref trg_selector=src aligns="cs-en:gold" \
		Align::ProjectAlignment layer=t selector=src trg_layer=a aligns="cs-en:gold" \
		Write::Treex path=$(dir $@) storable=1
	find $(dir $@) -name '*.streex' |  xargs basename -a | sort > $@

####################################################################################################################
#############################################       PHASE 3      ###################################################
###################### EN-CS-RU gold alignments annotation for English possessive pronouns #########################
####################################################################################################################

# the original version of generating ali_annot file for en_poss can be found in ../ru_cs_align
ali_annot.en_poss : $(PHASE2_ALI_ANNOT_CLEAN)
$(PHASE2_ALI_ANNOT_CLEAN) : ../tmp/testing_import_ali_annot/02.cs-en.all.project/list
	bin/prepare_clean_ali_annot.sh $< en src a perspron.poss cs,ru > $@

import_en-with-ru_poss : ../tmp/testing_import_ali_annot/03.en-with-ru.poss.import/list
../tmp/testing_import_ali_annot/03.en-with-ru.poss.import/list : ../tmp/testing_import_ali_annot/02.cs-en.all.project/list
	bin/import_ali_annot.sh $< $(PHASE2_ALI_ANNOT) $@ "cs-en:gold;ru-cs:gold;en-ru:gold"

summary/en_poss : ../tmp/testing_import_ali_annot/03.en-with-ru.poss.import/list
	bin/print_summary.sh $< en src a perspron.poss cs,ru > $@

####################################################################################################################
#############################################       PHASE 4      ###################################################
####################### EN-CS-RU gold alignments annotation for Czech possessive pronouns ##########################
####################################################################################################################

ali_annot.cs_poss : $(PHASE3_ALI_ANNOT_CLEAN)
$(PHASE3_ALI_ANNOT_CLEAN) : ../tmp/testing_import_ali_annot/03.en-with-ru.poss.import/list
	bin/prepare_clean_ali_annot.sh $< cs src a perspron.poss en,ru > $@

import_cs-with-ru_poss : ../tmp/testing_import_ali_annot/04.cs-with-ru.poss.import/list
../tmp/testing_import_ali_annot/04.cs-with-ru.poss.import/list : ../tmp/testing_import_ali_annot/03.en-with-ru.poss.import/list
	bin/import_ali_annot.sh $< $(PHASE3_ALI_ANNOT) $@ "cs-en:gold;ru-cs:gold;en-ru:gold"

summary/cs_poss : ../tmp/testing_import_ali_annot/04.cs-with-ru.poss.import/list
	bin/print_summary.sh $< cs src a perspron.poss en,ru > $@

####################################################################################################################
#############################################       PHASE 5      ###################################################
###################### EN-CS-RU gold alignments annotation for Russian possessive pronouns #########################
####################################################################################################################

ali_annot.ru_poss : $(PHASE4_ALI_ANNOT_CLEAN)
$(PHASE4_ALI_ANNOT_CLEAN) : ../tmp/testing_import_ali_annot/04.cs-with-ru.poss.import/list
	bin/prepare_clean_ali_annot.sh $< ru src a perspron.poss en,cs > $@

import_ru-with-ru_poss : ../tmp/testing_import_ali_annot/05.ru-with-ru.poss.import/list
../tmp/testing_import_ali_annot/05.ru-with-ru.poss.import/list : ../tmp/testing_import_ali_annot/04.cs-with-ru.poss.import/list
	bin/import_ali_annot.sh $< $(PHASE4_ALI_ANNOT) $@ "cs-en:gold;ru-cs:gold;en-ru:gold"

summary/ru_poss : ../tmp/testing_import_ali_annot/05.ru-with-ru.poss.import/list
	bin/print_summary.sh $< ru src a perspron.poss en,cs > $@
