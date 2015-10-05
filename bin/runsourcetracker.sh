#!/bin/bash
#runall.sh A script to recreate all paper analyses
#Usage: runsourcetracker.sh <outputdir>
#Adam R. Rivers 2015-09-15

# Define output dir
$OUTPUTDIR="$1"

#convert biom file to txt 
biom convert -i "$OUTPUTDIR"/otus/filtered_otu_table.biom -o "$OUTPUTDIR"/otus/filtered_otu_table.txt -b

#Run source tracker to remove samples contaminated by sequencing or seawater
R --slave --vanilla --args -i $OUTPUTDIR/otus/filtered_otu_table.txt -m ../data/map_full.txt -o  $OUTPUTDIR/otus/sourcetracker_run1 < $SOURCETRACKER_PATH/sourcetracker_for_qiime.r

