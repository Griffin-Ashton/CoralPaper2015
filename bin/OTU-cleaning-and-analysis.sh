#!/bin/bash
# A script to do the OTU fitlering and analysis of Coral 454 Amplicon data
# Adam R. Rivers 2015-09-15

#Number of cores to use
CORES=3
# Define output dir
$OUTPUTDIR="$1"

##CLEANING##

#First find how many low count otus can be discarded and still retain ~99%  of the data
biom summarize-table -i "$OUTPUTDIR"/otus/otu_table.biom -o "$OUTPUTDIR"/otus/summary.txt
#total reads 70422, 69700 (99%) otus = 3098

# Remove OTU with less than 2 sequences
filter_otus_from_otu_table.py -i "$OUTPUTDIR"/otus/otu_table.biom -o "$OUTPUTDIR"/otus/filtered_otu_table.biom -s 2

#Summarize filtered reads
biom summarize-table -i "$OUTPUTDIR"/otus/filtered_otu_table.biom -o "$OUTPUTDIR"/otus/filtered_summary.txt
#filtered reads, 66627 (95%) otus =990

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
biom subset-table -i "$OUTPUTDIR"/otus/otu_table_no_chloro-mito.biom -a samples -s samples_to_keep.txt -o "$OUTPUTDIR"/otus/subset.biom

##ANALYSIS##

#ANALYSIS

#Paths need to be fixed below here

#Generate plots
summarize_taxa_through_plots.py -o taxa_summary -i subset.biom -m Map20140425-decon.txt.csv

beta_diversity_through_plots.py -i subset.biom -o bdiv_even200/ -t /home/adam/Desktop/corals/results/20140318/otus/rep_set.tre -m /home/adam/Desktop/corals/results/20140424/Map20140425-decon.txt.csv -e 200

make_2d_plots.py -i /home/adam/Desktop/corals/results/20140424/bdiv_even200/unweighted_unifrac_pc.txt -m Map20140425-decon.txt.csv -o 2d_plots/

compare_categories.py --method adonis -i /home/adam/Desktop/corals/results/20140424/bdiv_even200/unweighted_unifrac_dm.txt -m Map20140425-decon.txt.csv  -c Env -o adonis_out -n 9999

compare_categories.py --method anosim -i /home/adam/Desktop/corals/results/20140424/bdiv_even200/unweighted_unifrac_dm.txt -m Map20140425-decon.txt.csv  -c Env -o anosim_out -n 9999



