####### This Makefile has been moved from ~/projects/align_coref/pcedt-r  on 3th August 2017 #########
####### Look up the original directory in the bash-history file for its usage. #######################

OUTDIR=data

TREEX=PERL5LIB=${PWD}/lib:${PERL5LIB} treex --qsub "-v PERL5LIB=${PWD}/lib"

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
# set Interset feats, which were lost after transformation to PDT style
after_coref_annot : $(OUTDIR)/04.tecto.after_coref_annot/full.list
$(OUTDIR)/04.tecto.after_coref_annot/full.list :
	$(TREEX) -p -Lru \
		Read::PDT from='!$(dir $@)/*.t.gz' schema_dir='../common/schema' \
		Util::Eval anode='$$anode->wild->{"lemma.orig"} = $$anode->lemma;' \
		W2A::UDPipe tokenize=0 tag=1 parse=0 model_alias="ru_synt_2.0" \
		Util::Eval anode='use Lingua::Interset qw(decode); my $$tag = join "\t", map {$$anode->$$_} qw/conll_cpos conll_feat/; my $$iset = decode("mul::uposf", $$tag); $$anode->set_iset($$iset);' \
		Util::Eval anode='$$anode->set_lemma(delete $$anode->wild->{"lemma.orig"})' \
		Write::Treex path='$(dir $@)' && \
	find $(dir $@) -name '*.treex.gz' | sed 's|.*/||' | sort > $@

##############################################################################################################
#################### STAGE 5: CHECK IF EVERY A-NODE HAS ITS T-NODE CORRESPONDENCE ############################
##############################################################################################################

check_anode_to_tnode : $(OUTDIR)/05.list.anode_vs_tnode/anode_list.tsv
check_tnode_to_anode : $(OUTDIR)/05.list.anode_vs_tnode/tnode_list.tsv
$(OUTDIR)/05.list.anode_vs_tnode/anode_list.tsv : $(OUTDIR)/04.tecto.after_coref_annot/full.list
	mkdir -p $(dir $@)
	$(TREEX) -Lru \
		Read::Treex from='@$<' \
		Util::Eval anode='my $$tlex = join " ", map {$$_->id} $$anode->get_referencing_nodes("a/lex.rf"); my $$taux = join " ", map {$$_->id} $$anode->get_referencing_nodes("a/aux.rf"); print join "\t", ("A=".$$anode->get_address, "TL=".$$tlex, "TA=".$$taux, "Z=".($$anode->tag =~ /^Z/ ? 1 : 0)); print "\n";' \
	> $@
$(OUTDIR)/05.list.anode_vs_tnode/tnode_list.tsv : $(OUTDIR)/04.tecto.after_coref_annot/full.list
	mkdir -p $(dir $@)
	$(TREEX) -Lru \
		Read::Treex from='@$<' \
		Util::Eval tnode='my $$alex = join " ", map {$$_->id} $$tnode->get_lex_anode(); my $$aaux = join " ", map {$$_->id} $$tnode->get_aux_anodes(); print join "\t", ("T=".$$tnode->get_address, "AL=".$$alex, "AA=".$$aaux, "IG=".($$tnode->is_generated ? 1 : 0), "TL=".$$tnode->t_lemma); print "\n";' \
	> $@
print_anode_to_tnode_annot : $(OUTDIR)/05.list.anode_vs_tnode/anode.atref_annot
$(OUTDIR)/05.list.anode_vs_tnode/anode.atref_annot : $(OUTDIR)/04.tecto.after_coref_annot/full.list
	mkdir -p $(dir $@)
	$(TREEX) -Lru \
		Read::Treex from='@$<' \
		AnaphBus::PrintNoTToA \
	> $@



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
