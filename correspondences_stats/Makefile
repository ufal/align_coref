LRC_FLAG=-p --jobs=100 
TREEX=PERL5LIB=$$PERL5LIB:/home/mnovak/projects/align_coref/AnaphBus/multi/lib treex $(LRC_FLAG)

#DATA=${CZENG_COREF_DIR}/data/en/analysed/czeng_0/train/0001/list
## run this before printing a summary if the abovemention dataset is used
#Align::T::Supervised::Resolver language=en,cs align_trg_lang=en node_types=all_anaph model_path='/lnet/tspec/tmp/mnovak/tmp/align_resolver/ml/007_run_2017-12-01_16-58-14_27251.en_all_anaph_on_src_0033/001.6db8382fb6.featset/014.6bcae.mlmethod/model/train.en.src.all_anaph.pcedt_19.vw.ranking.model,/lnet/tspec/tmp/mnovak/tmp/align_resolver/ml/008_run_2017-12-01_16-58-59_27424.cs_all_anaph_on_src_0033/001.6db8382fb6.featset/009.ad5ba.mlmethod/model/train.cs.src.all_anaph.pcedt_19.vw.ranking.model'
## or without this block to fill in summaries.orig

LANGUAGE=en
ALI_LANGUAGE=cs
SELECTOR=src
ALIGN_TYPE='.*'

#DATA_ID=czeng.sec0
DATA_ID=czeng.train
#DATA_ID=pcedt_bi.full
#DATA_ID=pcedt_bi.train_00-18
#DATA_ID=pcedt_bi.dev
#DATA_ID=pcedt_bi.wsj1900-49
#DATA_ID=pcedt_bi.wsj1900-49.gold
ifeq ($(DATA_ID),czeng.sec0)
DATA=/home/mnovak/projects/coref_bitext/data/analysed/czeng/sec0/0033/list
else
ifeq ($(DATA_ID),czeng.train)
DATA=/home/mnovak/projects/coref_bitext/data/analysed/czeng/train/0033.coref_cross_cs-158_en-054/list
else
ifeq ($(DATA_ID),pcedt_bi.full)
DATA=${CZENG_COREF_DIR}/data/en/analysed/pcedt_bi/full/0033.ref-ali-sup.src-ali-sup/list
else
ifeq ($(DATA_ID),pcedt_bi.full.gold)
DATA=${CZENG_COREF_DIR}/data/en/analysed/pcedt_bi/full/0033.ref-ali-sup.src-ali-sup/list
SELECTOR="ref"
PREPROC_BLOCKS=A2N::EN::NameTag language=en selector=ref A2N::EN::DistinguishPersonalNames language=en selector=ref A2N::CS::NameTag language=cs selector=ref A2N::CS::NormalizeNames language=cs selector=ref A2T::CS::SetGrammatemes language=cs selector=ref
else
ifeq ($(DATA_ID),pcedt_bi.train_00-18)
DATA=${CZENG_COREF_DIR}/data/en/analysed/pcedt_bi/train_00-18/0033/list
else
ifeq ($(DATA_ID),pcedt_bi.dev)
DATA=${CZENG_COREF_DIR}/data/en/analysed/pcedt_bi/dev/0033/list
else
ifeq ($(DATA_ID),pcedt_bi.wsj1900-49)
DATA=${CZENG_COREF_DIR}/data/en/analysed/pcedt_bi/wsj1900-49/0033/list
else
ifeq ($(DATA_ID),pcedt_bi.wsj1900-49.gold)
DATA=/home/mnovak/projects/align_coref/AnaphBus/multi/en-cs-ru/data/05.treex.pcedtr_gold_align_import.cs-en.all/full.list
SELECTOR=""
ALIGN_TYPE='gold'
PREPROC_BLOCKS=A2N::EN::NameTag language=en A2N::EN::DistinguishPersonalNames language=en A2N::CS::NameTag language=cs A2N::CS::NormalizeNames language=cs A2T::CS::SetGrammatemes language=cs
endif
endif
endif
endif
endif
endif
endif
endif

ifneq (,$(findstring gold,$(DATA_ID)))

endif

DATA_DIR=data/$(DATA_ID)
TMP_DIR=tmp/$(DATA_ID)

ID=08

summary : $(DATA)
	rm -rf $(TMP_DIR)/*
	mkdir -p $(TMP_DIR)
	mkdir -p $(DATA_DIR)
	$(TREEX) \
		Read::Treex from=@$< \
		$(PREPROC_BLOCKS) \
		AnaphBus::CrossLingStats language=$(LANGUAGE) selector=$(SELECTOR) align_lang=$(ALI_LANGUAGE) align_type=$(ALIGN_TYPE) path=$(TMP_DIR)
	find $(TMP_DIR) | xargs cat | gzip -c > $(DATA_DIR)/$(LANGUAGE).sup.summary.$(ID).txt.gz
