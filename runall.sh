#!/bin/bash
#runall.sh A script to recreate all paper analyses
#Adam R. Rivers 2015-09-15

#Global variables
DATAURL="https://"
FULLANALYSIS="True"

#Retrieve raw data 
cd data/
wget $DATAURL/* 
cd ..










