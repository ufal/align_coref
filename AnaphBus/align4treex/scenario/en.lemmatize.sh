#!/bin/bash

tokenize=$1
selector=$2

scen="Util::SetGlobal language=en "
if [ -n "$selector" ]; then
    scen+="Util::SetGlobal selector=$selector "
fi
if [ "$tokenize" == "whitespace" ]; then
    scen+="W2A::TokenizeOnWhitespace "
else
    scen+="W2A::EN::Tokenize "
fi
scen+="W2A::EN::NormalizeForms W2A::EN::FixTokenization "
scen+="W2A::EN::TagMorphoDiTa W2A::EN::FixTags W2A::EN::FixTagsImperatives "
scen+="W2A::EN::Lemmatize"

echo "$scen"
