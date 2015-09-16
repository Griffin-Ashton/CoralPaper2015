#!/bin/bash
# A script to do the OTU fitlering and analysis of Coral 454 Amplicon data
# Adam R. Rivers 2015-09-15



#First find how many low count otus can be discarded and still retain ~99%  of the data
biom summarize-table -i "$OUTPUTDIR"/otus/otu_table.biom -o "$OUTPUTDIR"/otus/summary.txt
#total reads 70422, 69700 (99%) otus = 3098

# Remove OTU with less than 2 sequences
filter_otus_from_otu_table.py -i "$OUTPUTDIR"/otus/otu_table.biom -o "$OUTPUTDIR"/otus/filtered_otu_table.biom -s 2

#Summarize filtered reads
biom summarize-table -i "$OUTPUTDIR"/otus/filtered_otu_table.biom -o "$OUTPUTDIR"/otus/filtered_summary.txt
#filtered reads, 66627 (95%) otus =990

#remove chloroplast and mito
filter_taxa_from_otu_table.py -i "$OUTPUTDIR"/otus/filtered_otu_table.biom -o "$OUTPUTDIR"/otus/otu_table_no_chloro-mito.biom -n c__Chloroplast,f__mitochondria

#convert biom file to txt
biom convert -i "$OUTPUTDIR"/otus/otu_table_no_chloro-mito.biom -o "$OUTPUTDIR"/otus/otu_table_no_chloro-mito.txt -b

# run biom to remove them
biom subset-table -i "$OUTPUTDIR"/otus/otu_table_no_chloro-mito.biom -a samples -s ../data/samples_to_keep.txt -o "$OUTPUTDIR"/otus/final.biom



