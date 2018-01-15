LRC_FLAG=-p --jobs=100 
TREEX=PERL5LIB=$$PERL5LIB:/home/mnovak/projects/align_coref/AnaphBus/multi/lib treex $(LRC_FLAG)

#DATA=${CZENG_COREF_DIR}/data/en/analysed/czeng_0/train/0001/list
## run this before printing a summary if the abovemention dataset is used
#Align::T::Supervised::Resolver language=en,cs align_trg_lang=en node_types=all_anaph model_path='/lnet/tspec/tmp/mnovak/tmp/align_resolver/ml/007_run_2017-12-01_16-58-14_27251.en_all_anaph_on_src_0033/001.6db8382fb6.featset/014.6bcae.mlmethod/model/train.en.src.all_anaph.pcedt_19.vw.ranking.model,/lnet/tspec/tmp/mnovak/tmp/align_resolver/ml/008_run_2017-12-01_16-58-59_27424.cs_all_anaph_on_src_0033/001.6db8382fb6.featset/009.ad5ba.mlmethod/model/train.cs.src.all_anaph.pcedt_19.vw.ranking.model'
## or without this block to fill in summaries.orig

DATA=/home/mnovak/projects/coref_bitext/data/analysed/czeng/sec0/0033/list

LANGUAGE=en
ALI_LANGUAGE=cs

summary : $(DATA)
	rm -rf summaries/*
	rm -rf data/*
	$(TREEX) \
		Read::Treex from=@$< \
		AnaphBus::CrossLingStats language=$(LANGUAGE) selector=src align_lang=$(ALI_LANGUAGE) align_type='.*' path=summaries
	find summaries | xargs cat | gzip -c > $(LANGUAGE).sup.summary.$(ID).txt.gz
