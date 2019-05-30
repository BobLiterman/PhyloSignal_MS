rm(list=ls())
library(ape)
library(reshape)
library(phylobase)
library(plyr)
library(tidyverse)

nodeDater <- function(split_list,dated_topology_10000,dated_topology_50000){

  split_table <- data.frame('SISRS_Split'=character(),'a_Split'=character(),'b_Split'=character(),stringsAsFactors = FALSE)
  for(x in 1:length(split_list)){
    splitString <- unlist(strsplit(split_list[x],":"))
    splitNum <- as.character(str_replace(splitString[1],'Split ',''))
    wholeSplit <- as.character(str_replace(splitString[2],' ',''))
    leftSplit <- unlist(strsplit(wholeSplit,'...',fixed = TRUE))[1]
    rightSplit <- unlist(strsplit(wholeSplit,'...',fixed = TRUE))[2]
    split_table[x,] <- c(splitNum,leftSplit,rightSplit)
  }

  ageList10 <- branching.times(dated_topology_10000)
  ageList50 <- branching.times(dated_topology_50000)

  aList <- list()
  bList <- list()
  mrcaA <- list()
  mrcaB <- list()

  for(f in 1:nrow(split_table)){
    taxa_A<-unlist(strsplit((split_table$'a_Split'[f]),","))
    taxa_B<-unlist(strsplit((split_table$'b_Split'[f]),","))
    aList[f] <- is.monophyletic(dated_topology_10000,taxa_A)
    bList[f] <- is.monophyletic(dated_topology_50000,taxa_B)
    mrcaA[f] <- MRCA(dated_topology_10000,taxa_A)
    mrcaB[f] <- MRCA(dated_topology_50000,taxa_B)
  }

  split_table <- cbind(split_table,as.data.frame(unlist(aList))) %>%
    cbind(as.data.frame(unlist(bList))) %>%
    cbind(as.data.frame(unlist(mrcaA))) %>%
    cbind(as.data.frame(unlist(mrcaB)))

  colnames(split_table) <- c('SISRS_Split','a_Split','b_Split','A_Mono','B_Mono','A_MRCA','B_MRCA')

  split_table <- split_table %>%  mutate(Tree_Split = ifelse(A_Mono & B_Mono,paste(A_MRCA,B_MRCA,sep=","),ifelse(A_Mono & !B_Mono,A_MRCA,ifelse(B_Mono & !A_Mono,B_MRCA,"NA")))) %>%
    select(SISRS_Split,Tree_Split) %>%
    mutate(Node_Age_10000 = ifelse(str_detect(Tree_Split,","),NA,ageList10[Tree_Split])) %>%
    mutate(Node_Age_50000 = ifelse(str_detect(Tree_Split,","),NA,ageList50[Tree_Split]))
  return(split_table)
}

# #Primates
# base_dir <- "PATH/Primates"
# user_outgroup <- c('AotNan','CalJac')
# user_min <- 41.0 # TimeTree.org: 05/30/2019
# user_max <- 45.7 # TimeTree.org: 05/30/2019
# raw_out_file <- "PATH/Primates/Primate_Node_Date_Distribution.csv"
# median_out_file <- "PATH/Primates/Primate_Median_Node.csv"

# #Rodents
# base_dir <- 'PATH/Rodents'
# user_outgroup <- c('EllLut','PerLeu')
# user_min <- 26 # TimeTree.org: 05/30/2019
# user_max <- 34 # TimeTree.org: 05/30/2019
# raw_out_file <- "PATH/Rodents/Rodent_Node_Date_Distribution.csv"
# median_out_file <- "PATH/Rodents/Rodent_Median_Node.csv"

# #Pecora
# base_dir <- 'PATH/Pecora'
# user_outgroup <- c('BalMys','HipAmp')
# user_min <- 54 # TimeTree.org: 05/30/2019
# user_max <- 59 # TimeTree.org: 05/30/2019
# raw_out_file <- "PATH/Pecora/Pecora_Node_Date_Distribution.csv"
# median_out_file <- "PATH/Pecora/Pecora_Median_Node.csv"

annotation_count_path <- paste(base_dir,'/Post_SISRS_Processing/Annotations/Annotation_Counts.tsv',sep = '')
ref_tree_path <- paste(base_dir,'/Reference_Topology/RefTree.nwk',sep = '')
split_list_path <- paste(base_dir,'/Reference_Topology/RefTree_SplitKey.txt',sep = '')
chronos_10000_path <- paste(base_dir,'/Post_SISRS_Processing/Chronos_10000/RAxML/RAxML_result.Concat_10000',sep = '')
chronos_50000_path <- paste(base_dir,'/Post_SISRS_Processing/Chronos_50000/RAxML/RAxML_result.Concat_50000',sep = '')

split_list <- readLines(split_list_path)
reference_topology_blank <- root(read.tree(ref_tree_path),outgroup=user_outgroup,resolve.root = TRUE)
reference_topology_blank <- compute.brlen(reference_topology_blank, 1)
reference_topology_10000 <- root(read.tree(chronos_10000_path),outgroup = user_outgroup,resolve.root = TRUE)
reference_topology_50000 <- root(read.tree(chronos_50000_path),outgroup = user_outgroup,resolve.root = TRUE)

date_df <- data.frame(SISRS_Split=integer(),Tree_Split=character(),Node_Age_10000=numeric(),Node_Age_50000=numeric())

for(i in 1:1000){
  cal_10000 <- makeChronosCalib(reference_topology_10000,age.min = user_min,age.max = user_max) # Set chronos calibrartion using root CI from TimeTree.org
  cal_50000 <- makeChronosCalib(reference_topology_50000,age.min = user_min,age.max = user_max) # Set chronos calibrartion using root CI from TimeTree.org

  branching_times_10000 <- chronos(reference_topology_10000,calibration = cal_10000)
  branching_times_50000 <- chronos(reference_topology_50000,calibration = cal_50000)

  dated_topology_10000 <- reference_topology_blank
  dated_topology_10000$edge.length <- branching_times_10000$edge.length

  dated_topology_50000 <- reference_topology_blank
  dated_topology_50000$edge.length <- branching_times_50000$edge.length
  date_df <- rbind(date_df,nodeDater(split_list,dated_topology_10000,dated_topology_50000))
}

median_date_df <- date_df %>%
  group_by(SISRS_Split) %>%
  mutate(Median_10000 = median(Node_Age_10000),Median_50000 = median(Node_Age_50000)) %>%
  select(SISRS_Split,Tree_Split,Median_10000,Median_50000) %>%
  distinct(SISRS_Split,.keep_all = TRUE) %>%
  rename(Node_Age_10000 = Median_10000,Node_Age_50000 = Median_50000) %>%
  filter(!is.na(Node_Age_10000))

date_df <- date_df %>% filter(!is.na(Node_Age_10000))

write_csv(date_df,raw_out_file)
write_csv(median_date_df,median_out_file)

#Plotting

plot_df <- date_df %>% select(-Tree_Split) %>%
  rename(Estimate_10000 = Node_Age_10000,Estimate_50000 = Node_Age_50000) %>%
  left_join(median_date_df,by="SISRS_Split") %>%
  select(-Tree_Split) %>%
  rename(Median_10000 = Node_Age_10000,Median_50000 = Node_Age_50000)

plot_df %>%  group_by(SISRS_Split) %>%
  ggplot(aes(fill=SISRS_Split)) +
  geom_density(aes(x=Estimate_10000),color='black',alpha=0.5) +
  geom_density(aes(x=Estimate_50000),color='red',alpha=0.2) +
  geom_vline(aes(xintercept = Median_10000),color="black") +
  geom_vline(aes(xintercept = Median_50000),color="red")

             
