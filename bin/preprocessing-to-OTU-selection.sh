#!/bin/bash
# A script to do the initial formatting, clustering and OTU picking of Coral 454 Amplicon data
# Usage: preprocessing-to-OTU-selection.sh <outputdir>
# Adam R. Rivers 2015-09-15

#Number of cores to use
CORES=3
# Define output dir
$OUTPUTDIR="$1"

#Seqquencing was done at different facilities for processing is slightly different. this genrates the sff.txt file for one the seawater samples (sequecned later)
process_sff.py -i data/022614DK27F-full.fasta / -f -o processed/

# Split libraries by sample
split_libraries.py -o "$OUTPUTDIR"/run1 -f ../data/raw/UGA0271.HIWZ5CS07.sff.fasta -q ../data/raw/UGA0271.HIWZ5CS07.sff.qual  -m ../data/MapFeb22.txt -b 8 -w 50 -g -r -l 150 -L 400

split_libraries.py -o "$OUTPUTDIR"/run2 -f ../data/raw/UGA0271.HIWZ5CS08.sff.fasta -q ../data/raw/UGA0271.HIWZ5CS08.sff.qual  -m ../data/MapFeb22.txt -b 8 -w 50 -g -r -l 150 -L 400

split_libraries.py -o "$OUTPUTDIR"/run3 -f ../data/raw/022614DK27F.fna -q ../data/raw/022614DK27F.qual -m ../data/022614DK27F-mapping2.txt -b 8 -w 50 -g -r -l 150 -L 400

# Denoise the data
denoise_wrapper.py -v -i ../data/UGA0271.HIWZ5CS07.sff.txt -f "$OUTPUTDIR"/run1/seqs.fna -o "$OUTPUTDIR"/run1/denoised/ -m ../data/MapFeb22.txt -n $CORES

denoise_wrapper.py -v -i ../data/UGA0271.HIWZ5CS08.sff.txt -f "$OUTPUTDIR"/run2/seqs.fna -o "$OUTPUTDIR"/run2/denoised/ -m ../data/MapFeb22.txt -n $CORES

denoise_wrapper.py -v -i ../data/022614DK27F.txt -f "$OUTPUTDIR"/run3/seqs.fna -o "$OUTPUTDIR"/run3/denoised/ -m ../data/MapFeb22.txt -n $CORES

#Reinflate denoiser results 
inflate_denoiser_output.py -c "$OUTPUTDIR"/run1/denoised/centroids.fasta,"$OUTPUTDIR"/run2/denoised/centroids.fasta,"$OUTPUTDIR"/run3/denoised/centroids.fasta -s "$OUTPUTDIR"/run1/denoised/singletons.fasta,"$OUTPUTDIR"/run2/denoised/singletons.fasta,"$OUTPUTDIR"/run3/denoised/singletons.fasta -f "$OUTPUTDIR"/run1/seqs.fna,"$OUTPUTDIR"/run2/seqs.fna,"$OUTPUTDIR"/run3/seqs.fna -d "$OUTPUTDIR"/run1/denoised/denoiser_mapping.txt,"$OUTPUTDIR"/run2/denoised/denoiser_mapping.txt,"$OUTPUTDIR"/run3/denoised/denoiser_mapping.txt -o "$OUTPUTDIR"/denoised_seqs.fna

#Pick otus
pick_de_novo_otus.py -i "$OUTPUTDIR"/denoised_seqs.fna -o "$OUTPUTDIR"/otus -p "$OUTPUTDIR"/usearch_params.txt



