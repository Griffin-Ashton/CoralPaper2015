#!/usr/bin/env Rscript
library(RColorBrewer)
library(reshape)
library(argparser, quietly=TRUE)

p <- arg_parser("A script to plot taxonomic composition")
p <- add_argument(p, "--distance", help="The unweighted Unifrac distance matrix")
p <- add_argument(p, "--map", help="the mapping file")
p <- add_argument(p, "--taxa", help="A file containing taxa for the plot")
p <- add_argument(p, "--output", help="the name for the PDF file to be generated")
argv <- parse_args(p)

#Load Unifrac distance matrix
dm<- read.table(argv$distance, sep="\t", header=T)
row.names(dm) <-dm$X
dm<-dm[,-1]
dm.dist<-as.dist(dm)

#load mapping file
env<-read.table(argv$map,header=T, sep="\t")


#Load data for bargraphs 
select<-read.table(argv$taxa, header=T,sep=",")
rownames(select)<-select[,1]
select<-select[,-1]
select<-select[order(-1:-18),]
dm.clust<-hclust(dm.dist)
dm.dend<-as.dendrogram(dm.clust)

#oreder samples by clustering
select<-select[,order.dendrogram(dm.dend)]
mat<-as.matrix(select)

#assign colors to samples with RColorBrewer
alphas<-brewer.pal(3, "Reds")
proteo<-brewer.pal(5,"Greens")
other<-brewer.pal(9,"Set1")
cyano<-"LightSeaGreen"
colors<- c(alphas,proteo,other, cyano)


#Plotting combined transcript and 16s data
pdf(file=argv$output, width=6, height=5)
nf <- layout(matrix(c(1,2),2,1,byrow=F), height=c(1,4))

#16sdata
par(mar=c(0,4,1,1))
plot(dm.dend, leaflab="none",yaxt="n")
par(mar=c(1,4,0,1))
barplot(mat,col=colors,beside=F,cex.names=0.8, axisnames=F, legend=T)
dev.off()
