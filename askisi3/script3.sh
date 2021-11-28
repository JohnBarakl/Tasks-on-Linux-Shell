#!/bin/bash

len=$(wc -l $1 | sed "s/\([0-9][0-9]*\) .*/\1/g");

begin=$(grep -n "\*\*\*" $1 | head -n 2 | sed "s/:.*//")

end=$(echo $begin | sed -e "s/[0-9][0-9]*[[:space:]]//")

begin=$(echo $begin | sed "s/[[:space:]][[:space:]]*.*//") 

cat $1 | tail -n $(expr $len - $begin) | head -n $(expr $(expr $len - $begin) - $(expr $len - $end) - 1) | tr ' ' '\n' | tr '[:upper:]' '[:lower:]' | sed "s/\([a-z][a-z]*\)'.*/\1/g" | tr "[:punct:]" "\n" | sed "s/]*[\.\,\?\;\!\:\t\(\)\_\"\[]*[[:space:]]*-*//g" | sed "/^[[:space:]]*$/d" | sort | uniq -c -i | sed "s/  /00/g" | sed "s/[[:space:]]\([1-9][0-9]*[[:space:]]\)/0\1/g" | sort -r | sed "s/^0*//g" | sed "s/\([0-9]*\) \(.*\)/\2 \1/" | head -n $2
