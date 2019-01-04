# Summary

PAWS is a multilingual parallel treebank with tectogrammatical annotation and annotation of coreference.

# Introduction

PAWS (Parallel Anaphoric Wall Street Journal) is a multi-lingual parallel treebank with coreference annotation. It consists of English texts from the Wall Street Journal translated into Czech, Russian and Polish. In addition, the texts are syntactically parsed and word-aligned. PAWS is based on PCEDT 2.0 and continues the tradition of multilingual treebanks with coreference annotation. PAWS offers linguistic material that can be further leveraged in cross-lingual studies, especially on coreference.

# Changelog

##### 2018-05-15 v1.0
- original release.
- source English texts translated to Czech, Russian and Polish.
- tectogrammatical annotation:
   - full manual tectogrammatical annotation for English and Czech (copied from Prague Czech-English Dependency Treebank 2.0).
   - limited manually corrected automatic tectogrammatical annotation for Russian and Polish.
- annotation of coreference:
   - manually annotated for all languages
- annotation of word/node alignment:
   - automatic using GIZA++ between all pairs of languages
   - manual annotation on selected coreferential expressions between English, Czech and Russian

# Credits

The dataset and the annotation guidelines were developed at Charles University by Anna Nedoluzhko, Michal Novák, and Maciej Ogrodniczuk.

# Citation

You are encouraged to cite the dataset directly:

```
@misc{ paws2018,
   title = {{PAWS}},
   author = {Anna Nedoluzhko and Michal Nov{\'{a}}k and Maciej Ogrodniczuk},
   year = {2018},
   publisher = {{\'{U}}{FAL} {MFF} {UK}},
   organization = {{\'{U}}{FAL} {MFF} {UK}},
   address = {Prague, Czech Republic},
   url = {http://hdl.handle.net/11234/1-2683},
}
```

or cite the following paper:

```
@inproceedings{ paws-paper2018,
   title = {{PAWS}: A Multi-lingual Parallel Treebank with Anaphoric Relations},
   author = {Anna Nedoluzhko and Michal Nov{\'{a}}k and Maciej Ogrodniczuk},
   booktitle = {Proceedings of the First Workshop on Computational Models of Reference, Anaphora and Coreference},
   editor = {Massimo Poesio and Vincent Ng and Maciej Ogrodniczuk},
   year = {2018},
   publisher = {Association for Computational Linguistics},
   organization = {Association for Computational Linguistics},
   address = {Stroudsburg, {PA}, {USA}},
   pages = {68--76},
   isbn = {978-1-948087-13-1},
}
```
