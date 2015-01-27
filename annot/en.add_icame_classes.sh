sed -i 's|^[^/]*||' en.all.align.ref.sec19_00-49.summary

sed -i 's/^\(.*en_perspron	.*cs_perspron_unexpr.*\)$/en_pers_cs_zero	\1/' en.all.align.ref.sec19_00-49.summary
#vim en.all.align.ref.sec19_00-49.summary
#sed -n 's/^\([^e].*en_perspron	.*sel[vf].*se_\^.*\)$/en_pers_cs_zero	\1/p' en.all.align.ref.sec19_00-49.summary | wc -l
#sed -n 's/^\([^e].*en_perspron	.*sel[vf].*se_\^.*\)$/en_refl_cs_refl	\1/p' en.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^e].*en_perspron	.*sel[vf].*se_\^.*\)$/en_refl_cs_refl	\1/' en.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^e].*en_perspron	.*sel[vf].*\)$/en_refl_cs_other	\1/' en.all.align.ref.sec19_00-49.summary
#sed -n 's/^\([^e].*en_perspron	.*sv.*\)$/en_poss-cs_refl_poss	\1/p' en.all.align.ref.sec19_00-49.summary | wc -l
sed -i 's/^\([^e].*en_perspron	.*sv.*\)$/en_poss-cs_refl_poss	\1/' en.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^e].*en_perspron	.*PS.*\)$/en_poss-cs_poss	\1/' en.all.align.ref.sec19_00-49.summary
#vim en.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^e].*en_perspron	.*ten[^t].*\)$/en_pers-cs_demon	\1/' en.all.align.ref.sec19_00-49.summary
#vim en.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^e].*en_perspron	.*cs_perspron.*se.*\)$/en_poss-cs_refl	\1/' en.all.align.ref.sec19_00-49.summary
#vim en.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^e].*en_perspron	.*cs_perspron.*\)$/en_pers-cs_pers	\1/' en.all.align.ref.sec19_00-49.summary
#vim en.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^e].*en_perspron	.*PLEO.*\)$/en_pers-cs_pleo	\1/' en.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^e].*en_perspron	.*REWORD.*\)$/en_pers-cs_reword	\1/' en.all.align.ref.sec19_00-49.summary
#vim en.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^e].*en_perspron	.*NULL_POSS.*\)$/en_poss-cs_no_poss	\1/' en.all.align.ref.sec19_00-49.summary
#vim en.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^e].*en_perspron	.*its.*NN.*\)$/en_poss-cs_noun	\1/' en.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^e].*en_perspron	.*NN.*\)$/en_pers-cs_noun	\1/' en.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^e].*en_perspron	.*AA.*\)$/en_pers-cs_noun	\1/' en.all.align.ref.sec19_00-49.summary
#vim en.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^e].*en_perspron	.*\)$/en_pers-cs_other	\1/' en.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^e].*en_relpron	.*that.*undef.*undef.*\)$/en_that-cs_no_ali	\1/' en.all.align.ref.sec19_00-49.summary
#vim en.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^e].*en_relpron	.*that.*\)$/en_that-cs_other_relat	\1/' en.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^e].*en_relpron	.*což.*\)$/en_wh_words-cs_coz	\1/' en.all.align.ref.sec19_00-49.summary
#vim en.all.align.ref.sec19_00-49.summary
#sed -n 's/^\([^e].*en_relpron	.*undef	undef	undef	undef.*\)$/en_wh_words-cs_no_ali	\1/p' en.all.align.ref.sec19_00-49.summary | wc -l
sed -i 's/^\([^e].*en_relpron	.*undef	undef	undef	undef.*\)$/en_wh_words-cs_no_ali	\1/' en.all.align.ref.sec19_00-49.summary
#vim en.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^e].*en_relpron	.*FUSED.*\)$/en_wh_words-cs_inter_fused	\1/' en.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^e].*en_relpron	.*\)$/en_wh_words-cs_other_relat	\1/' en.all.align.ref.sec19_00-49.summary
#vim en.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^e].*en_perspron_unexpr	.*ANTE.*\)$/en_anaphzero-cs_no_ali	\1/' en.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^e].*en_cor	.*ANTE.*\)$/en_anaphzero-cs_no_ali	\1/' en.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^e].*en_perspron_unexpr	.*ALIGN=0.*\)$/en_anaphzero-cs_no_ali	\1/' en.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^e].*en_cor	.*ALIGN=0.*\)$/en_anaphzero-cs_no_ali	\1/' en.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^e].*en_perspron_unexpr	.*MISS_ARG.*\)$/en_anaphzero-cs_no_ali	\1/' en.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^e].*en_perspron_unexpr	.*REWORD.*\)$/en_anaphzero-cs_no_ali	\1/' en.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^e].*en_cor	.*MISS_ARG.*\)$/en_anaphzero-cs_no_ali	\1/' en.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^e].*en_cor	.*REWORD.*\)$/en_anaphzero-cs_no_ali	\1/' en.all.align.ref.sec19_00-49.summary
#vim en.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^e].*en_cor	.*cs_relpron.*\)$/en_anaphzero-cs_relpron	\1/' en.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^e].*en_perspron_unexpr	.*cs_relpron.*\)$/en_anaphzero-cs_relpron	\1/' en.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^e].*en_perspron_unexpr	.*cs_cor.*\)$/en_anaphzero-cs_anaphzero	\1/' en.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^e].*en_perspron_unexpr	.*cs_perspron_unexpr.*\)$/en_anaphzero-cs_anaphzero	\1/' en.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^e].*en_cor	.*cs_perspron_unexpr.*\)$/en_anaphzero-cs_anaphzero	\1/' en.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^e].*en_cor	.*cs_cor.*\)$/en_anaphzero-cs_anaphzero	\1/' en.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^e].*en_cor	.*cs_perspron.*\)$/en_anaphzero-cs_perspron	\1/' en.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^e].*en_perspron_unexpr	.*cs_perspron.*\)$/en_anaphzero-cs_perspron	\1/' en.all.align.ref.sec19_00-49.summary
#vim en.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^e].*en_perspron_unexpr	.*OK.*\)$/en_anaphzero-cs_other	\1/' en.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^e].*en_cor	.*OK.*\)$/en_anaphzero-cs_other	\1/' en.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^e].*en_cor	.*\)$/en_anaphzero-cs_no_ali	\1/' en.all.align.ref.sec19_00-49.summary
sed -i 's/^\([^e].*en_perspron_unexpr	.*\)$/en_anaphzero-cs_no_ali	\1/' en.all.align.ref.sec19_00-49.summary

# after that, several manual adjustments must be performed
