merge_annot : align.ref.sec19.all.ali_annot
align.ref.sec19.all.ali_annot : align.ref.sec19.structured.miso.pt1.ali_annot align.ref.sec19.structured.anja.pt1.ali_annot align.ref.sec19.structured.miso.pt2.ali_annot align.ref.sec19.structured.anja.pt2.ali_annot
	cat $^ > $@

first_half : align.ref.sec19_00-49.all.ali_annot
align.ref.sec19_00-49.all.ali_annot : align.ref.sec19.all.ali_annot
	cat $< | head -n 3689 > $@
