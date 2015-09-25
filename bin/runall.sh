#!/bin/bash
#runall.sh A script to recreate all paper analyses
#Usage: runall.sh <outputdir>
#Adam R. Rivers 2015-09-15

#Local variables
OUTPUTDIR=`readlink -f "$1"`
DATAURL="https://"
FULLANALYSIS="True"

#Retrieve raw data 

cd data/
wget $DATAURL/* 
cd ..

if [ ! -d "$OUTPUTDIR" ]; then
	mkdir "$OUTPUTDIR"
fi

if [$FULLANALYSIS == "True"]; then
	./preprocessing-to-OTU-selection.sh "$OUTPUTDIR"
fi










