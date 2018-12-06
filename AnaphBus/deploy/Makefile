SHELL=/bin/bash

release : data
	mkdir -p $@
	cp -r data $@
	cp -r bin $@

FINAL_TREEX_FILES=../multi/en-cs-ru-pl/data/03.treex.ru-pl_align_imported/*.treex.gz

data : data/treex data/plain data/conll
	mkdir -p $@
	mkdir -p $@/conll

data/treex : 
	mkdir -p $@
	cp $(FINAL_TREEX_FILES) $@

data/plain :
	mkdir -p $@
	treex -Len -Sref
