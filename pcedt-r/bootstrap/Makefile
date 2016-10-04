############ CALCULATE NUMBER OF REFL_POSS AND POSS IN CZECH ORIGINAL AND TRANSLATED TEXTS AND COMPARE ###################

cs.rfl_poss.transl.data :
	treex -p --jobs=200 -Lcs \
	Read::Treex from='!/net/data/pcedt2.0/data/*/*.treex.gz' \
	Util::Eval anode='use Treex::Tool::Coreference::NodeFilter::PersPron; my $$refl_poss = Treex::Tool::Coreference::NodeFilter::PersPron::is_3rd_pers($$anode, {reflexive => '1', possessive => '1'}); my $$poss = Treex::Tool::Coreference::NodeFilter::PersPron::is_3rd_pers($$anode, {reflexive => '-1', possessive => '1'}); print join "\t", ($$anode->get_address, $$anode->lemma, $$anode->form, "RFLPOSS=".($$refl_poss // 0), "POSS=".($$poss // 0)); print "\n";' \
	> $@

cs.rfl_poss.orig.data :
	treex -p --jobs=200 -Lcs \
	Read::PDT from='!/net/data/pdt30/data/tamw/*/*.t.gz' schema_dir=$(TMT_ROOT)/treex/lib/Treex/Block/Read/PDT_schema \
	Util::Eval anode='use Treex::Tool::Coreference::NodeFilter::PersPron; my $$refl_poss = Treex::Tool::Coreference::NodeFilter::PersPron::is_3rd_pers($$anode, {reflexive => '1', possessive => '1'}); my $$poss = Treex::Tool::Coreference::NodeFilter::PersPron::is_3rd_pers($$anode, {reflexive => '-1', possessive => '1'}); print join "\t", ($$anode->get_address, $$anode->lemma, $$anode->form, "RFLPOSS=".($$refl_poss // 0), "POSS=".($$poss // 0)); print "\n";' \
	> $@
