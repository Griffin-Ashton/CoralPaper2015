#!/bin/bash
# A script to do the OTU fitlering and analysis of Coral 454 Amplicon data
# Adam R. Rivers 2015-09-15

## Variables ##
#Number of cores to use
CORES=3
# Define output dir
$OUTPUTDIR="$1"

## Cleaning ##

#First find how many OTUs are in the complete data set
biom summarize-table -i "$OUTPUTDIR"/otus/otu_table.biom -o "$OUTPUTDIR"/otus/summary.txt
#total reads 66720, otus = 3019

# Remove OTUs with less than 2 sequences
filter_otus_from_otu_table.py -i "$OUTPUTDIR"/otus/otu_table.biom -o "$OUTPUTDIR"/otus/filtered_otu_table.biom -s 2

#Summarize the filtered data 
biom summarize-table -i "$OUTPUTDIR"/otus/filtered_otu_table.biom -o "$OUTPUTDIR"/otus/filtered_summary.txt

#filtered reads remaining: 62918 (94%), otus = 929

## Classification ##

# Assign taxonomy using RDP with a classification probability of 0.7
assign_taxonomy.py -i "$OUTPUTDIR"/otus/rep_set/denoised_seqs_rep_set.fasta -m rdp -c 0.7 -o "$OUTPUTDIR"/otus/otus_rdp

# Identify chimeric reads
parallel_identify_chimeric_seqs.py -i "$OUTPUTDIR"/otus/pynast_aligned_seqs/denoised_seqs_rep_set_aligned.fasta -o "$OUTPUTDIR"/otus/chimera_slayer_chimeric_seqs.txt -O 3

# remove chimeric reads
filter_fasta.py -f "$OUTPUTDIR"/otus/pynast_aligned_seqs/denoised_seqs_rep_set_aligned.fasta -o"$OUTPUTDIR"/otus/non_chimeric_rep_set_aligned.fasta -s "$OUTPUTDIR"/otus/chimera_slayer_chimeric_seqs.txt -n

#20140429 09:23 regenerate otu table with chimeras removed and new taxonomy from RDP attached

make_otu_table.py -i "$OUTPUTDIR"/otus/usearch61_picked_otus/denoised_seqs_otus.txt -o "$OUTPUTDIR"/otus/otu-w_taxa.biom -e "$OUTPUTDIR"/otus/chimera_slayer_chimeric_seqs.txt -t "$OUTPUTDIR"/otus/otus_rdp/denoised_seqs_rep_set_tax_assignments.txt 

# remove chloroplasts and mitochondria
filter_taxa_from_otu_table.py -i "$OUTPUTDIR"/otus/otu-w_taxa.biom -o "$OUTPUTDIR"/otus/otu_table_no_chloro-mito.biom -n c__Chloroplast,f__mitochondria

#Remove the samples Prim46, Prim57, Prim44
# run biom to remove them
biom subset-table -i "$OUTPUTDIR"/otus/otu_table_no_chloro-mito.biom -a samples -s ../data/samples_to_keep.txt -o "$OUTPUTDIR"/otus/subset.biom

## ANALYSIS ##

#Generate plots
summarize_taxa_through_plots.py -o $OUTPUTDIR/taxa_summary -i $OUTPUTDIR/otus/subset.biom -m ../data/map_reduced.txt 

alpha_rarefaction.py -i $OUTPUTDIR/otus/subset.biom -o $OUTPUTDIR/arare/ -t $OUTPUTDIR/otus/rep_set.tre -m ../data/map_reduced.txt -p ../data/arare_params.txt -a -O 3

beta_diversity_through_plots.py -i $OUTPUTDIR/otus/subset.biom -o $OUTPUTDIR/bdiv_even100/ -t $OUTPUTDIR/otus/rep_set.tre -m ../data/map_reduced.txt -e 100

make_2d_plots.py -i $OUTPUTDIR/bdiv_even100/unweighted_unifrac_pc.txt -m ../data/map_reduced.txt -o $OUTPUTDIR/2d_plots/







