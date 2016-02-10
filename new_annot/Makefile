PCERDT_19_ORIG=../ru_cs_align/out/pcerdt_19_giza/full.list

PHASE1_ALI_ANNOT=cs-en.all.align.ref.sec19_00-49.ali_annot
PHASE2_ALI_ANNOT=en.poss.align.src.sec19_00-49.ali_annot
PHASE30_ALI_ANNOT_CLEAN=cs.poss.align.src.sec19_00-49.clean.ali_annot
PHASE31_ALI_ANNOT_CLEAN=ru.poss.align.src.sec19_00-49.clean.ali_annot

../tmp/testing_import_ali_annot/01.cs-en.all.import/list : $(PCERDT_19_ORIG)
	bin/import_ali_annot.sh $< $(PHASE1_ALI_ANNOT) $@ "cs-en:gold"

project_cs-en : ../tmp/testing_import_ali_annot/02.cs-en.all.project/list
../tmp/testing_import_ali_annot/02.cs-en.all.project/list : ../tmp/testing_import_ali_annot/01.cs-en.all.import/list
	mkdir -p $(dir $@)
	treex -p --jobs 50 \
		Read::Treex from=@$< \
		Align::ProjectAlignment layer=t selector=ref trg_selector=src aligns="cs-en:gold" \
		Align::ProjectAlignment layer=t selector=src trg_layer=a aligns="cs-en:gold" \
		Write::Treex path=$(dir $@) storable=1
	find $(dir $@) -name '*.streex' |  xargs basename -a | sort > $@

import_en-with-ru_poss : ../tmp/testing_import_ali_annot/03.en-with-ru.poss.import/list
../tmp/testing_import_ali_annot/03.en-with-ru.poss.import/list : ../tmp/testing_import_ali_annot/02.cs-en.all.project/list
	bin/import_ali_annot.sh $< $(PHASE2_ALI_ANNOT) $@ "cs-en:gold;ru-cs:gold;en-ru:gold"


ali_annot.cs_poss : $(PHASE30_ALI_ANNOT_CLEAN)
$(PHASE30_ALI_ANNOT_CLEAN) : ../tmp/testing_import_ali_annot/03.en-with-ru.poss.import/list
	treex \
		Read::Treex from=@$< \
		Align::Annot::Print::A language=cs selector=src align_langs="en,ru" node_types="perspron.poss" \
		> $@
