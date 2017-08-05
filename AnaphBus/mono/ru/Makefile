####### This Makefile has been moved from ~/projects/align_coref/pcedt-r  on 3th August 2017 #########
####### Look up the original directory in the bash-history file for its usage. #######################

OUTDIR=data

##############################################################################################################
################### STAGE 3: CREATE AUTOMATIC RUSSIAN TECTO TREES FOR MANUAL ANNOTATION ######################
##############################################################################################################

# RUN RUSSIAN UDPipe AND A2T ANALYSIS ON RUSSIAN PART OF PCEDT-R  
# This block deletes Russian morpho annotation created so far, as no syntactic parser is compatible with it 

#!!!!! To get high-quality Russian trees, switch Treex repo to the 'hamledt.ud2_to_prague' branch !!!!!
# The only available Russian UDPipe model was trained by me (see the targets below), however its quality was poor
# In 2017, Milan released his own "baseline", but still relatively hig-quality model for Russian.
# This is, however, trained on UDPipe version 2.
# Think about merging 'hamledt.ud2_to_prague' branch to the master


before_coref_annot : $(OUTDIR)/03.tecto.before_coref_annot/full.list
$(OUTDIR)/03.tecto.before_coref_annot/full.list : $(OUTDIR)/02.texts.checked/ru/list
	mkdir -p $(dir $@)
	treex -Lru \
		Read::Sentences from='@$<' \
		Scen::Analysis::RU unknown_afun_to_atr=0 default_functor='' \
		Write::TextModeTrees \
		Write::Treex storable=1 path='$(dir $@)' \
		Write::PDT version=3.0 path='$(dir $@)'
	find $(dir $@) -name '*.t.gz' | sed 's|.*/||' | sort > $(dir $@)/full.t.list
	find $(dir $@) -name '*.streex' | sed 's|.*/||' | sort > $@


##############################################################################################################
################ STAGE 4: MANUAL ANNOTATION OF COREFERENCE AND COREFERENCE-DRIVEN TECTO ######################
##############################################################################################################

# done by Anja on PDT-like t-trees only
# !!!!! links between t-nodes and a-nodes may be unresolved !!!!!!

# transform the PDT-like documents to Treex documents
after_coref_annot : $(OUTDIR)/04.tecto.after_coref_annot/full.list
$(OUTDIR)/04.tecto.after_coref_annot/full.list :
	treex -p -Lru \
		Read::PDT from='!$(dir $@)/*.t.gz' schema_dir='../common/schema' \
		Write::Treex path='$(dir $@)' && \
	find $(dir $@) -name '*.treex.gz' | sed 's|.*/||' | sort > $@


#=============================================================================================================
#=============================================================================================================
#====================================== STUFF NO LONGER USED =================================================
#=============================================================================================================
#=============================================================================================================


##############################################################################################################
############################ TRAIN UDPipe ON RUSSIAN PRAGUE-STYLE HAMLEDT   ##################################
######### NONE OF THE CURRENT SOLUTIONS FOR TAGGING AND PARSING IN TREEX ARE MUTUALLY COMPATIBLE #############
##############################################################################################################

# Prerequisities:
# * Russian model for Malt Parser was trained with the version 1.5 => check if the version is not newer and change it in a reversed way as it was done in commit "3080b9ea5d12" (see GitHub/treex)

HAMLEDT_RU_TREEX_DIR=/ha/projects/tectomt_shared/data/resources/hamledt/ru/treex/01
UDPIPE_TRAIN_TMP_DIR=/net/cluster/TMP/mnovak/ru_cs_prons/ru_udpipe_train_tmp

udpipe_ru_train_to_conll : $(UDPIPE_TRAIN_TMP_DIR)/hamledt_conllu/train.conll
udpipe_ru_dev_to_conll : $(UDPIPE_TRAIN_TMP_DIR)/hamledt_conllu/dev.conll
$(UDPIPE_TRAIN_TMP_DIR)/hamledt_conllu/%.conll : $(HAMLEDT_RU_TREEX_DIR)/%
	mkdir -p $(dir $@)/$*
	treex -p --jobs=100 -Lru \
		Read::Treex from='!$</*.treex.gz' \
		Write::CoNLLX pos_attribute='tag' deprel_attribute='deprel' is_member_within_afun=1 path='$(dir $@)/$*'
	cat $(dir $@)/$*/*.conll > $@

UDPIPE=/net/projects/udpipe/bin/udpipe-1.0.0-bin/bin-linux64/udpipe

$(UDPIPE_TRAIN_TMP_DIR)/ru.hamledt.prague.model : $(UDPIPE_TRAIN_TMP_DIR)/hamledt_conllu/train.conll $(UDPIPE_TRAIN_TMP_DIR)/hamledt_conllu/dev.conll
	$(UDPIPE) --train $@ --heldout=$(word 2,$^) $(word 1,$^)
