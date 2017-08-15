#!/bin/bash

tokenize=$1

scen="Util::SetGlobal language=cs "
if [ "$tokenize" == "whitespace" ]; then
    scen+="W2A::TokenizeOnWhitespace "
else
    scen+="W2A::CS::Tokenize "
fi
scen+="W2A::CS::TagMorphoDiTa lemmatize=1"

echo "$scen"
