#!/bin/bash

# Treex repository must be checked out to the "hamledt.ud2_to_prague" branch

tokenize=$1

scen="Util::SetGlobal language=pl "
if [ "$tokenize" == "whitespace" ]; then
    scen+='W2A::TokenizeOnWhitespace W2A::UDPipe tokenize=0 parse=0 model_alias="pl_2.0"'
else
    scen+='W2A::UDPipe tokenize=1 parse=0 model_alias="pl_2.0"'
fi

echo "$scen"
