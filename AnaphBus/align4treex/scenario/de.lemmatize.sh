#!/bin/bash

tokenize=$1
selector=$2

scen="Util::SetGlobal language=de "
if [ -n "$selector" ]; then
    scen+="Util::SetGlobal selector=$selector "
fi
if [ "$tokenize" == "whitespace" ]; then
    scen+="W2A::TokenizeOnWhitespace "
    scen+='W2A::UDPipe tokenize=0 parse=0 model_alias="de"'
else
    scen+='W2A::UDPipe tokenize=1 parse=0 model_alias="de"'
fi

echo "$scen"
