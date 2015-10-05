#!/usr/bin/env Rscript
# Tests to determine if coral location had a significant effect on community composition 
#and if there was a significant difference in community composition between corals, seawater and sediment
library(vegan)
library(argparser, quietly=TRUE)

p <- arg_parser("A script to determine categories with statistically signifigant effects")
p <- add_argument(p, "--distance", help="The weighted Unifrac distance matrix")
p <- add_argument(p, "--map", help="the mapping file")
p <- add_argument(p, "--adonisout", help="the name for the results file to be generated")
argv <- parse_args(p)

#Write output to file
sink(argv$adonisout)

# Load the weighted distance matrix for all samples
dm<- read.table(argv$distance, sep="\t", header=T)

# Move row names
rownames(dm) <-dm$X
dm<-dm[,-1]
# Order rownames
dm<-dm[order(rownames(dm)),]

# Create an object of class 'dist'
dm.dist<-as.dist(dm)

# Read full environmental data matrix
env<-read.table(argv$map, header=F, sep="\t")
# Move row names
rownames(env)<-env$V1
env<-env[,-1]
# Order rownames
env<-env[order(rownames(env)),]
# Create categorical data
env$cnc <- ifelse(env$V7 %in% c("CoralBase","CoralUnderside","CoralUppermost"),"c", ifelse(env$V7 == "Sediment","s","w"))

## Test for significance between coral location
print("Testing for significance between coral location")
corals<-dm[c(1:3,5:6,8:13),c(1:3,5:6,8:13)]
corals.dist<-dist(corals)
corals.env<-env[env$cnc=="c",]
adonis(formula = corals.dist ~ V7 , data = corals.env, permutations = 10000)

## Test for significance between coral and seawater
print(" Testing for significance between coral and seawater")
csw<-dm[c(1:3,5:6,8:17),c(1:3,5:6,8:17)]
csw.dist<-dist(csw)
csw.env<-env[env$cnc %in% c("c","w"),]
adonis(formula = csw.dist ~ cnc , data = csw.env, permutations = 10000)

## Test for significance between coral and sediment
print("Testing for significance between coral and sediment")
cs<- dm[c(1:13),c(1:13)]
cs.dist<-dist(cs)
cs.env<-env[env$cnc %in% c("c","s"),]
adonis(formula = cs.dist ~ cnc , data = cs.env, permutations = 10000)

## Test for significance between seawater and sediment
print("Testing for significance between seawater and sediment")
ssw<- dm[c(4,7,14:17),c(4,7,14:17)]
ssw.dist<-dist(ssw)
ssw.env<-env[env$cnc %in% c("w","s"),]
adonis(formula = ssw.dist ~ cnc , data = ssw.env, permutations = 10000)

sink()
