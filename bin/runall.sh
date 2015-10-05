#!/bin/bash
#runall.sh A script to recreate all paper analyses
#Usage: runall.sh <outputdir>
#Adam R. Rivers 2015-09-15

#Local variables
OUTPUTDIR=`readlink -f "$1"`
DATAURL="http://portal.nersc.gov/dna/MEP/oldcores/CoralPaper2015/raw.tar.gz"
FULLANALYSIS="True"

#Retrieve raw data 
cd ../data/
mkdir raw
cd raw/
wget $DATAURL
tar -zxvf raw.tar.gz
cd ../../bin

#Check for and if needed make output directory
if [ ! -d "$OUTPUTDIR" ]; then
	mkdir "$OUTPUTDIR"
fi

#if full analysis is desired run this script (takes ~24 hours)
if [$FULLANALYSIS == "True"]; then
	./preprocessing-to-OTU-selection.sh "$OUTPUTDIR"
fi

#run cleaning and analysis steps
./OTU-cleaning-and-analysis.sh "$OUTPUTDIR"

# Run sourcetracker analysis
./runsourcetracker.sh "$OUTPUTDIR"

# Generate composition plot (if you get package no found errors make sure you are calling correct R installation)
./compositionplot.R -d $OUTPUTDIR/bdiv_even100/unweighted_unifrac_dm.txt -m ../data/map_reduced.txt -t ../data/taxaforplot2.csv -o $OUTPUTDIR/compositionplot.pdf

# Do adonis (permanova-like) tests for significance
./adonis.R --distance $OUTPUTDIR/bdiv_even100/weighted_unifrac_dm.txt --map ../data/map_reduced.txt --adonisout $OUTPUTDIR/adonisout.txt






