EN_TYPED_ANNOT_FILES=en_perspron/align.ref.sec19_00-49.all.with_types.ali_annot en_perspron_unexpr/align.ref.sec19_00-49.all.with_types.ali_annot en_relpron/align.ref.sec19_00-49.all.with_types.ali_annot en_cor/align.ref.sec19_00-49.all.with_types.ali_annot
CS_TYPED_ANNOT_FILES=cs_perspron/align.ref.sec19_00-49.all.with_types.ali_annot cs_perspron_unexpr/align.ref.sec19_00-49.all.with_types.ali_annot cs_relpron/align.ref.sec19_00-49.all.with_types.ali_annot cs_cor/align.ref.sec19_00-49.all.with_types.ali_annot

merge_annots : en.all.align.ref.sec19_00-49.ali_annot cs.all.align.ref.sec19_00-49.ali_annot
en.all.align.ref.sec19_00-49.ali_annot : $(EN_TYPED_ANNOT_FILES)
	cat $^ > $@
cs.all.align.ref.sec19_00-49.ali_annot : $(CS_TYPED_ANNOT_FILES)
	cat $^ > $@

%.with_types.ali_annot : %.ali_annot
	type=`echo $* | sed 's/^\([^\/]*\)\/.*$$/\1/'`; \
	echo $$type; \
	cat $< | sed "s/^ERR:/ERR:TYPE=$$type	/" > $@

clean_typed:
	rm $(EN_TYPED_ANNOT_FILES) $(CS_TYPED_ANNOT_FILES)
