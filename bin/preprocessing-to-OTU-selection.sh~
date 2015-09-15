#!/bin/bash
# A script to do the initial formatting, clustering and OTU picking of 454 Amplicon data
# Adam R. Rivers 2015-09-15

#Nunber of cores to use
CORES=3
#Seqquencing was done at different facilities for processing is slightly different. this genrates the sff.txt file for one the seawater samples (sequecned later)
process_sff.py -i data/022614DK27F-full.fasta / -f -o processed/

# Split libraries by sample
split_libraries.py -o ../results/run1 -f ../data/UGA0271.HIWZ5CS07.sff.fasta -q ../data/UGA0271.HIWZ5CS07.sff.qual  -m ../data/MapFeb22.txt -b 8 -w 50 -g -r -l 150 -L 400

split_libraries.py -o ../results/run2 -f ../data/UGA0271.HIWZ5CS08.sff.fasta -q ../data/UGA0271.HIWZ5CS08.sff.qual  -m ../data/MapFeb22.txt -b 8 -w 50 -g -r -l 150 -L 400

split_libraries.py -o ../results/run3 -f ../data/022614DK27F.fna -q ../data/022614DK27F.qual -m ../data/022614DK27F-mapping2.txt -b 8 -w 50 -g -r -l 150 -L 400

# Denoise the data
denoise_wrapper.py -v -i ../data/UGA0271.HIWZ5CS07.sff.txt -f ../results/run1/seqs.fna -o ../results/run1/denoised/ -m ../data/MapFeb22.txt -n $CORES

denoise_wrapper.py -v -i ../data/UGA0271.HIWZ5CS08.sff.txt -f ../results/run2/seqs.fna -o ../results/run2/denoised/ -m ../data/MapFeb22.txt -n $CORES

denoise_wrapper.py -v -i ../data/022614DK27F.txt -f ../results/run3/seqs.fna -o ../results/run3/denoised/ -m ../data/MapFeb22.txt -n $CORES

#Reintegrate denoiser results into pipeline



