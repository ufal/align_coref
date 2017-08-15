#!/bin/bash

tokenize=$1

scen="Util::SetGlobal language=en "
if [ "$tokenize" == "whitespace" ]; then
    scen+="W2A::TokenizeOnWhitespace "
else
    scen+="W2A::EN::Tokenize "
fi
scen+="W2A::EN::NormalizeForms W2A::EN::FixTokenization "
scen+="W2A::EN::TagMorphoDiTa W2A::EN::FixTags W2A::EN::FixTagsImperatives "
scen+="W2A::EN::Lemmatize"

echo "$scen"
