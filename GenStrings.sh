#!/bin/bash
shopt -s nullglob
for f in *.xib
do
	echo "Generating strings for - `basename $f .xib`" 
	ibtool --generate-strings-file `basename $f .xib`.strings $f
done