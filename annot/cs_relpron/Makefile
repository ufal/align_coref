merge_annot : align.ref.sec19.all.ali_annot
align.ref.sec19.all.ali_annot : align.ref.sec19.anja.ali_annot align.ref.sec19.miso.ali_annot
	cat $^ > $@

first_half : align.ref.sec19_00-49.all.ali_annot
align.ref.sec19_00-49.all.ali_annot : align.ref.sec19.all.ali_annot
	cat $< | head -n 2387 > $@
