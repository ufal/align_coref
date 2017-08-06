orig_translations.ru.txt :
	cat ../annot/en_poss/align.src.sec19_00-49.all.full.ali_annot | grep -B3 -P '^INFO_TRANSL_RU:.*[\x{0400}-\x{052F}]+.*$$' | grep "^RU_A:" | sed 's/^RU_A:[	 ]*//' > $@

new_translations.ru.txt :
	cat ../annot/en_poss/align.src.sec19_00-49.all.full.ali_annot | grep "INFO_TRANSL_RU:" | grep -v -P '^[^\x{0400}-\x{052F}]+$$' > $@
	# + manual prefix removal in VIM
