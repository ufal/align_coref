#######################################################################
###################### POLISH TRANSLATIONS ############################
############ received from Maciej Ogrodniczuk on 14.11.2017 ###########
####### hopefully, this is the last version of the translations #######
## number of lines did not match - due to one-sentence-per-line rule ##
######### I changed it back, even though it looks more awful ##########
##### This change affects 15 sentences (some split, some joined) ######
#######################################################################
PL_TRANSL=data/00.translated/full.list

#######################################################################
################# STAGE 1: analyse the data automatically ######################
#######################################################################

# Variants 01.?a and 01.?b may exist.
# "a" on the second position means that it was parsed to UD1 style.
# "b" on the second position means that it was parsed to UD2 style.
# No second position means UD2 style (default).

data/01.analysed_for_annot.ud2/full.list : $(PL_TRANSL)
	mkdir -p $(dir $@)
	treex -Lpl \
		Read::Sentences from='@$<' \
		Scen::Analysis::PL \
		Write::TextModeTrees \
		Write::Treex storable=1 path='$(dir $@)' \
		Write::PDT version=3.0 path='$(dir $@)'
	find $(dir $@) -name '*.t.gz' | sed 's|.*/||' | sort > $(dir $@)/full.t.list
	find $(dir $@) -name '*.streex' | sed 's|.*/||' | sort > $@

##############################################################################################################
################ STAGE 2: MANUAL ANNOTATION OF COREFERENCE AND COREFERENCE-DRIVEN TECTO ######################
##############################################################################################################

# done by Maciej and his colleagues on PDT-like t-trees only
# sent to us 4.2.2018
# !!!!! links between t-nodes and a-nodes may be unresolved !!!!!!

# transform the PDT-like documents to Treex documents
# set Interset feats, which were lost after transformation to PDT style
# !!! switch the Treex branch to hamledt.ud2_to_prague before processing
after_coref_annot : data/02.tecto.after_coref_annot/full.list
data/02.tecto.after_coref_annot/full.list :
	treex -p -Lpl \
		Read::PDT from='!$(dir $@)/*.t.gz' schema_dir='../common/schema' \
		Util::Eval anode='$$anode->wild->{"lemma.orig"} = $$anode->lemma;' \
		W2A::UDPipe tokenize=0 tag=1 parse=0 model_alias="pl_2.0" \
		Util::Eval anode='use Lingua::Interset qw(decode); my $$tag = join "\t", map {$$anode->$$_} qw/conll_cpos conll_feat/; my $$iset = decode("mul::uposf", $$tag); $$anode->set_iset($$iset);' \
		Util::Eval anode='$$anode->set_lemma(delete $$anode->wild->{"lemma.orig"})' \
		Write::Treex path='$(dir $@)' && \
	find $(dir $@) -name '*.treex.gz' | sed 's|.*/||' | sort > $@


#################################################################### THE OLD STUFF ############################################################################


#######################################################################
##################### ORIGINAL POLISH TRANSLATIONS ####################
########## received from Maciej Ogrodniczuk on 22th June 2017 #########
# all joined in a single file => must be split using the EN original ##
#######################################################################
PL_ORIG_JOINED=data/00a.translated_joint/polish.txt
EN_ORIG_JOINED=data/00a.translated_joint/english.txt

data/00a.translated_joint/polish.utf8.txt : $(PL_ORIG_JOINED)
	iconv -f CP1250 -t UTF-8 < $< > $@

#########################################################################
# The split could not be made autoamtically as it contained superfluous #
# newlines. Moreover, it contained multiple typographical inconsistecies#
# and issues collected in data/00a.translated_joint/NOTES.txt which I   # 
# reported to Maciej by email from 3.7.2017. The data split by the 		#
# following script have been sent to him as well.						#
#########################################################################
data/00a.translated_joint/polish.utf8.split.done : data/00a.translated_joint/polish.utf8.txt
	cat $< | \
		perl -e 'my $$name = "wsj_19%02d.txt"; my $$i = 0; open my $$fh, ">", sprintf($$name, $$i); while (<>) { chomp $$_; if ($$_ =~ /^\s*$$/) { close $$fh; $$i++; open $$fh, ">", sprintf($$name, $$i); } else { print {$$fh} $$_."\n"; }} close $$fh;' \
	&& touch $@

data/01a.analysed_for_annot_sample_by_Anja/list : data/00a.translated_joint/polish.utf8.split.done
	mkdir -p $(dir $@)
	treex -Lpl \
		Read::Sentences from='!$(dir $<)/wsj_1903.txt' \
		Scen::Analysis::PL \
		Write::TextModeTrees \
		Write::Treex storable=1 path='$(dir $@)' \
		Write::PDT version=3.0 path='$(dir $@)'
	find $(dir $@) -name '*.t.gz' | sed 's|.*/||' | sort > $(dir $@)/full.t.list
	find $(dir $@) -name '*.streex' | sed 's|.*/||' | sort > $@

#########################################################################
# The Polish translation have been re-translated. However, as Maciej    #
# reports in his email from 7.9.2017: "Slightly improved, although I am #
# not really happy with the translation. It's clearly machine-powered   #
# which may make it easier to align but it does not read very well (in  #
# places)."                                                             #
# We should reconsider translating the portion to Polish again.         #
#########################################################################
# data/00b.carelessly_retranslated/done : data/00a.translated_joint/polish.utf8.txt
	# manual work

#########################################################################
# Analysis run for the LREC extended abstract to generate a figure of 	#
# a sample sentence from wsj_1903 in all 4 languages aligned.			#
#########################################################################
data/01b.analysed_for_annot_sample_by_Anja/list : data/00b.carelessly_retranslated/done
	mkdir -p $(dir $@)
	treex -Lpl \
		Read::Sentences from='!$(dir $<)/wsj_1903.txt' \
		Scen::Analysis::PL \
		Write::TextModeTrees \
		Write::Treex storable=1 path='$(dir $@)' \
		Write::PDT version=3.0 path='$(dir $@)'
	find $(dir $@) -name '*.t.gz' | sed 's|.*/||' | sort > $(dir $@)/full.t.list
	find $(dir $@) -name '*.streex' | sed 's|.*/||' | sort > $@

#########################################################################
# Do manual annotation and post-editing of a sample document.		 	#
#########################################################################
# data/02b.annot_sample_by_Anja/for_LREC_2018.list : data/01b.analysed_for_annot_sample_by_Anja/list

# Transform the PDT-like documents to Treex documents					#
data/02b.annot_sample_by_Anja/for_LREC_2018.list :
	treex -Lpl \
		Read::PDT from='!$(dir $@)/*.t.gz' schema_dir='../common/schema' \
		Write::Treex path='$(dir $@)' && \
	find $(dir $@) -name '*.treex.gz' | sed 's|.*/||' | sort > $@

#######################################################################
###### received from Maciej Ogrodniczuk on 8.9.2017 and 12.9.2017 #####
# everything in the format as requested - utf-8 sent-per-line in docs #
#######################################################################
# data/00c.translated_next/full.list
	# manual work

data/01c.analysed_for_annot/full.list : data/00c.translated_next/full.list
	mkdir -p $(dir $@)
	treex -Lpl \
		Read::Sentences from='@$<' \
		Scen::Analysis::PL \
		Write::TextModeTrees \
		Write::Treex storable=1 path='$(dir $@)' \
		Write::PDT version=3.0 path='$(dir $@)'
	find $(dir $@) -name '*.t.gz' | sed 's|.*/||' | sort > $(dir $@)/full.t.list
	find $(dir $@) -name '*.streex' | sed 's|.*/||' | sort > $@
