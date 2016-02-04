test :
	cat align.src.sec19_00-49.all.clean.ali_annot | grep "EN_A:" > en_a.clean.txt
	cat align.src.sec19_00-49.all.full.ali_annot | grep "EN_A:" > en_a.full.txt
	diff en_a.clean.txt en_a.full.txt
	cat align.src.sec19_00-49.all.clean.ali_annot | grep "CS_A:" > cs_a.clean.txt
	cat align.src.sec19_00-49.all.full.ali_annot | grep "CS_A:" > cs_a.full.txt
	diff cs_a.clean.txt cs_a.full.txt

clean :
	rm en_a.clean.txt en_a.full.txt cs_a.clean.txt cs_a.full.txt
