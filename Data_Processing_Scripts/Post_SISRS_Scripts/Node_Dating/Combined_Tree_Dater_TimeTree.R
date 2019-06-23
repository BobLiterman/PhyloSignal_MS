rm(list=ls())
library(ape)
library(reshape)
library(phylobase)
library(plyr)
library(tidyverse)
library(phytools)

nodeDater <- function(split_table,dated_topology_50000){
  ageList <- branching.times(dated_topology_50000)
  
  aList <- list()
  bList <- list()
  mrcaA <- list()
  mrcaB <- list()
  
  for(f in 1:nrow(split_table)){
    taxa_A<-unlist(strsplit((split_table$'a_Split'[f]),","))
    taxa_B<-unlist(strsplit((split_table$'b_Split'[f]),","))
    aList[f] <- is.monophyletic(dated_topology_50000,taxa_A)
    bList[f] <- is.monophyletic(dated_topology_50000,taxa_B)
    mrcaA[f] <- MRCA(dated_topology_50000,taxa_A)
    mrcaB[f] <- MRCA(dated_topology_50000,taxa_B)
  }
  
  split_table <- cbind(split_table,as.data.frame(unlist(aList))) %>%
    cbind(as.data.frame(unlist(bList))) %>%
    cbind(as.data.frame(unlist(mrcaA))) %>%
    cbind(as.data.frame(unlist(mrcaB)))
  
  colnames(split_table) <- c('SISRS_Split','a_Split','b_Split','A_Mono','B_Mono','A_MRCA','B_MRCA')
  
  split_table <- split_table %>%  mutate(Tree_Split = ifelse(A_Mono & B_Mono,paste(A_MRCA,B_MRCA,sep=","),ifelse(A_Mono & !B_Mono,A_MRCA,ifelse(B_Mono & !A_Mono,B_MRCA,"NA")))) %>%
    select(SISRS_Split,Tree_Split) %>%
    mutate(Node_Age = ifelse(str_detect(Tree_Split,","),NA,ageList[Tree_Split]))
  return(split_table)
}


##Combined
base_dir <- 'C:/Users/User-Pc/Desktop/Mammal_R/Datasets/Combined'
user_outgroup <- c('BalMys','BisBis','BosTau','BubBub','CapAeg','CapHir','ElaDav','GirTip','HipAmp','OdoVir','OkaJoh','OviAri')
raw_out_file <- "C:/Users/User-Pc/Desktop/Mammal_R/Node_Dating/Combined_Node_Date_Distribution.csv"
median_out_file <- "C:/Users/User-Pc/Desktop/Mammal_R/Node_Dating/Combined_Median_Node.csv"
time_tree_file <- "C:/Users/User-Pc/Desktop/Mammal_R/Node_Dating/Combined_TimeTree.nwk"

annotation_count_path <- paste(base_dir,'/Post_SISRS_Processing/Annotations/Annotation_Counts.tsv',sep = '')
ref_tree_path <- paste(base_dir,'/Reference_Topology/RefTree.nwk',sep = '')
split_list_path <- paste(base_dir,'/Reference_Topology/RefTree_SplitKey.txt',sep = '')
chronos_50000_path <- paste(base_dir,'/Post_SISRS_Processing/Chronos_50000/RAxML/RAxML_result.Concat_50000',sep = '')

split_list <- readLines(split_list_path)
split_table <- data.frame('SISRS_Split'=character(),'a_Split'=character(),'b_Split'=character(),stringsAsFactors = FALSE)
for(x in 1:length(split_list)){
  splitString <- unlist(strsplit(split_list[x],":"))
  splitNum <- as.character(str_replace(splitString[1],'Split ',''))
  wholeSplit <- as.character(str_replace(splitString[2],' ',''))
  leftSplit <- unlist(strsplit(wholeSplit,'...',fixed = TRUE))[1]
  rightSplit <- unlist(strsplit(wholeSplit,'...',fixed = TRUE))[2]
  split_table[x,] <- c(splitNum,leftSplit,rightSplit)
}


reference_topology_blank <- compute.brlen(root(read.tree(ref_tree_path),outgroup=user_outgroup,resolve.root = TRUE),1)
reference_topology_50000 <- root(read.tree(chronos_50000_path),outgroup = user_outgroup,resolve.root = TRUE)

node <- c(
  getMRCA(reference_topology_blank, tip = c("BalMys","HomSap") ), # Root of tree
  getMRCA(reference_topology_blank, tip = c("AotNan","HomSap") ), # Base of primates
  getMRCA(reference_topology_blank, tip = c("EllLut","MusMus") ), # Base of rodents
  getMRCA(reference_topology_blank, tip = c("BalMys","OviAri") )  # Base of pecora
) 

#Add min and max node age estimates from TimeTree (5.30.2019)
age.min <- c(91,41.0,26,54) 
age.max <- c(101,45.7,34,59) 
soft.bounds <- c(FALSE,FALSE,FALSE,FALSE) #For chronos
cal <- data.frame(node, age.min, age.max, soft.bounds) 

date_df <- data.frame(SISRS_Split=integer(),Tree_Split=character(),Node_Age=numeric())
edge_list <- reference_topology_blank$edge.length

for(i in 1:1000){
  branching_times_50000 <- chronos(reference_topology_50000,calibration = cal)
  
  dated_topology_50000 <- reference_topology_blank
  dated_topology_50000$edge.length <- branching_times_50000$edge.length
  edge_list <- rbind(edge_list, branching_times_50000$edge.length)
  date_df <- rbind(date_df,nodeDater(split_table,dated_topology_50000))
}

edge_list <- edge_list[-1,]
median_edge <- c()
for(i in 1:ncol(edge_list)){
  median_edge<-c(median_edge,median(edge_list[,i]))
}

time_tree <- reference_topology_blank
time_tree$edge.length <- median_edge

date_df <- date_df %>% filter(!is.na(Node_Age))

median_date_df <- date_df %>%
  group_by(SISRS_Split) %>%
  mutate(Median_Age = median(Node_Age)) %>%
  select(SISRS_Split,Tree_Split,Median_Age) %>%
  distinct(SISRS_Split,.keep_all = TRUE)

if(!is.ultrametric(time_tree)){
  time_tree <- force.ultrametric(time_tree,"extend")
}
write.tree(time_tree,time_tree_file)
write_csv(date_df,raw_out_file)
write_csv(median_date_df,median_out_file)
