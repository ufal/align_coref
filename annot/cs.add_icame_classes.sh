sed -i 's|^[^/]*||' cs.all.align.ref.sec19_00-49.summary

sed -i 's/^\([^c].*cs_perspron	.*sv.*the	.*\)$/cs_refl_poss-en_the	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_perspron	.*the	.*\)$/cs_poss-en_the	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_perspron	.*sel.*\)$/cs_refl-en_refl	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_perspron	.*en_cor.*\)$/cs_pers-en_zero	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_perspron	.*en_perspron_unexpr.*\)$/cs_pers-en_zero	\1/' cs.all.align.ref.sec19_00-49.summary
#vim cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_perspron	.*sv.*undef.*0 .*\)$/cs_refl_poss-en_no_ali	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_perspron	.*sv.*undef.*\)$/cs_refl_poss-en_other	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_perspron	.*sv.*\)$/cs_refl_poss-en_poss	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_perspron	.*se.*their.*\)$/cs_refl-en_poss	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_perspron	.*se.*con.*\)$/cs_refl-en_other	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_perspron	.*se.*PersPron.*\)$/cs_refl-en_pers	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_perspron	.*se.*\)$/cs_refl-en_no_ali	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_perspron	.*jeho.*them.*\)$/cs_poss-en_pers	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_perspron	.*jeho.*they.*\)$/cs_poss-en_pers	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_perspron	.*jeho.*it	.*\)$/cs_poss-en_pers	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_perspron	.*jeho.*its.*\)$/cs_poss-en_poss	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_perspron	.*jeho.*his.*\)$/cs_poss-en_poss	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_perspron	.*jeho.*their.*\)$/cs_poss-en_poss	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_perspron	.*jeho.*her.*\)$/cs_poss-en_poss	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_perspron	.*jeho.*	undef.*\)$/cs_poss-en_no_ali	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_perspron	.*jeho.*	undef.*\)$/cs_poss-en_other	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_perspron	.*jeho.*\)$/cs_poss-en_other	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_perspron	.*her.*\)$/cs_pers-en_poss	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_perspron	.*its.*\)$/cs_pers-en_poss	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_perspron	.*the.*\)$/cs_pers-en_pers	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_perspron	.*it	.*\)$/cs_pers-en_pers	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_perspron	.*he.*\)$/cs_pers-en_pers	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_perspron	.*him.*\)$/cs_pers-en_pers	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_perspron	.*dis.*\)$/cs_pers-en_other	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_perspron	.*mar.*\)$/cs_pers-en_other	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_perspron	.*\)$/cs_pers-en_no_ali	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_relpron	.*W[PRD].*FUSED.*\)$/cs_inter_fused-en_wh_word	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_relpron	.*FUSED.*\)$/cs_inter_fused-en_no_ali_other	\1/' cs.all.align.ref.sec19_00-49.summary
#vim cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_relpron	.*ANTE V.*\)$/cs_coz-en_no_ali_vp_modif	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_relpron	.*což.*ANTE N.*\)$/cs_coz-en_no_ali_np_modif	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_relpron	.*což.*APPOS.*\)$/cs_coz-en_appos	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_relpron	.*což.*OK\)$/cs_coz-en_wh_word	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_relpron	.*což.*\)$/cs_coz-en_zero	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_relpron	.*that.*\)$/cs_other_relat-en_that	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_relpron	.*ANTE N.*\)$/cs_other_relat-en_no_ali_np_modif	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_relpron	.*W[PRD].*\)$/cs_other_relat-en_wh_word	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_relpron	.*OK APPOS.*\)$/cs_other_relat-en_appos	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_relpron	.*PersPron.*\)$/cs_other_relat-en_pers	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_relpron	.*ALIGN=0.*\)$/cs_other_relat-en_no_ali_other	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_relpron	.*\)$/cs_other_relat-en_zero	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_cor	.*OK pers1.*\)$/cs_anaphzero-en_pers_12	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_perspron_unexpr	.*OK pers1.*\)$/cs_anaphzero-en_pers_12	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_perspron_unexpr	.*en_cor.*OK.*\)$/cs_anaphzero-en_anaphzero	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_cor	.*en_cor.*OK.*\)$/cs_anaphzero-en_anaphzero	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_perspron_unexpr	.*en_perspron_unexpr.*OK.*\)$/cs_anaphzero-en_anaphzero	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_cor	.*en_perspron_unexpr.*OK.*\)$/cs_anaphzero-en_anaphzero	\1/' cs.all.align.ref.sec19_00-49.summary
#vim en.all.align.ref.sec19_00-49.summary 
sed -i 's/^\([^c].*cs_cor	.*en_perspron.*OK.*\)$/cs_anaphzero-en_pers	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_perspron_unexpr	.*en_perspron.*OK.*\)$/cs_anaphzero-en_pers	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_perspron_unexpr	.*ANTE.*\)$/cs_anaphzero-en_no_ali	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_cor	.*ANTE.*\)$/cs_anaphzero-en_no_ali	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_perspron_unexpr	.*CS:	0.*\)$/cs_anaphzero-en_no_ali	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_cor	.*CS:	0.*\)$/cs_anaphzero-en_no_ali	\1/' cs.all.align.ref.sec19_00-49.summary
#vim cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_cor	.*\)$/cs_anaphzero-en_other	\1/' cs.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^c].*cs_perspron_unexpr	.*\)$/cs_anaphzero-en_other	\1/' cs.all.align.ref.sec19_00-49.summary

# after that, several manual adjustments must be performed

# one of the "cs_pers-en_zero" -> "cs_refl-en_zero"
# one of the "cs_inter_fused-en_no_ali_other" -> "cs_inter_fused-en_zero"

sed -i 's/cs_inter_fused-en_wh_word/cs_other_relat-en_inter_fused/g' cs.all.align.ref.sec19_00-49.summary
sed -i 's/cs_inter_fused-en_no_ali_other\(.*REPLACED_BY_NP.*$\)/cs_other_relat-en_no_ali_np_modif\1/g' cs.all.align.ref.sec19_00-49.summary
sed -i 's/cs_inter_fused-en_no_ali_other/cs_other_relat-en_no_ali_other/g' cs.all.align.ref.sec19_00-49.summary

