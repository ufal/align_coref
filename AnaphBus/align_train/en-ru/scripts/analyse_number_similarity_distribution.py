#!/usr/bin/env python

from pandas import *
from scipy import stats
from scipy import sparse
from sklearn.cluster import AgglomerativeClustering
import time as time
import sys

def printf(format, *args):
    sys.stdout.write(format % args)
  
# must specify that blank space " " is NaN  
experimentDF = read_table("number_similarity_distr/all.sample_033.en_ru.for_giza.distr")
print experimentDF["Distance"].mean()
print experimentDF["Distance"].var()
print stats.sem(experimentDF["Distance"])

size = experimentDF.shape[0]
N = 20

for i in range(0, N):
    start = i * int(size/N)
    end = ((i+1) * int(size/N))-1
    printf("%.2f\t%.2f\n", experimentDF[start:end]["Distance"].mean(), experimentDF[start:end]["Distance"].var())


#X = experimentDF[0:100].as_matrix()
#print X.shape
#
#connectivity = sparse.eye(X.shape[0], k=1)
##print connectivity
#
#
##set1 = experimentDF[]["Distance"]
#clustering = AgglomerativeClustering(linkage="ward", n_clusters=1, connectivity=connectivity, compute_full_tree=True)
##clustering = AgglomerativeClustering(linkage="ward", n_clusters=10)
#st = time.time()
#clustering.fit(X)
#elapsed_time = time.time() - st
#print("Elapsed time: %.2fs" % elapsed_time)
#
#print clustering.n_components_
#print clustering.n_leaves_ 
#print clustering.children_ 
