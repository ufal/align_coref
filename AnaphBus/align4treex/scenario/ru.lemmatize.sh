#!/bin/bash

tokenize=$1

scen="Util::SetGlobal language=ru "
if [ "$tokenize" == "whitespace" ]; then
    scen+="W2A::TokenizeOnWhitespace "
else
    scen+="W2A::RU::Tokenize "
fi
scen+="W2A::TagTreeTagger lemmatize=1"

echo "$scen"
