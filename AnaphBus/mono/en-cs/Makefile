SHELL=/bin/bash

OUTDIR=data

##############################################################################################################
############### STAGE 4: COPY THE ENGLISH-CZECH DATA FROM THE PCEDT 2.0 COREF BUILD DIR ######################
##############################################################################################################

# The data from an intermediate stage of building PCEDT 2.0 Coref are copied.
# It contains all the coreferential annotation.
# However, it contains the original alignment instead of the gold one.

# Another possibility to obtain this is to use PCEDT 2.0 Coref,
# remove all "gold" alignment and replace it with the alignment from PCEDT 2.0.

after_coref_annot : $(OUTDIR)/04.tecto.after_coref_annot/full.list
$(OUTDIR)/04.tecto.after_coref_annot/full.list : /net/work/projects/pcedt-coref/lrec_2016/tmp/old_pcedt_new_coref/19
	mkdir -p $(dir $@)
	cp $</wsj_19{0,1,2,3,4}* $(dir $@)
	find $(dir $@) -name '*.treex.gz' | sed 's|.*/||' | sort > $@
