rm(list=ls())
library(plyr)
library(tidyverse)
library(ggthemes)
library(ggtree)
library(ape)
library(phytools)
library(jtools)
library(scales)

rootFinder <- function(split_table,topology_50000){
  aList <- c()
  bList <- c()
  for(f in 1:nrow(split_table)){
    taxa_A<-unlist(strsplit((split_table$'Taxa_A'[f]),","))
    taxa_B<-unlist(strsplit((split_table$'Taxa_B'[f]),","))
    aList[f] <- is.monophyletic(topology_50000,taxa_A)
    bList[f] <- is.monophyletic(topology_50000,taxa_B)
  }
  
  split_table <- split_table %>% 
    mutate(Mono_A = aList) %>%
    mutate(Mono_B = bList) %>%
    mutate(Root = ifelse(Mono_A & Mono_B,"Y","N")) %>%
    mutate(Node=0)
  
  for(f in 1:nrow(split_table)){
    Mono_A <- split_table$Mono_A[f]
    Mono_B <- split_table$Mono_B[f]
    split_table$Node[f] <- ifelse(Mono_A & !Mono_B,getMRCA(topology_50000,unlist(strsplit((split_table$'Taxa_A'[f]),","))),ifelse(Mono_B & !Mono_A,getMRCA(topology_50000,unlist(strsplit((split_table$'Taxa_B'[f]),","))),NA))
  }
  return(split_table)
}

time_lm <- function(df,group){
  annos <- unique(df$Annotation)
  critical_value <- 0.05/length(annos)
  
  stat_list <- c()
  r_list  <- c()
  intercept_list <- c()
  
  for(anno in annos){
    focal_lm <-df %>%
      filter(Annotation==anno) %>%
      lm(PercentSplit ~ Median_Node_Age, data=.)
    stat_list[[length(stat_list)+1]] <-t(data.frame(summary(focal_lm)$coefficients[2,]))
    r_list[[length(r_list)+1]] <-summary(focal_lm)$adj.r.squared
    intercept_list[[length(intercept_list)+1]] <-focal_lm$coefficients[[1]]
  }
  return(data.frame(matrix(unlist(stat_list), nrow=length(stat_list), byrow=T)) %>% 
           rename(Slope='X1',StdErr='X2',t_value='X3',p_value = 'X4') %>% 
           mutate(Annotation=annos,Dataset=group) %>%
           mutate(BF_Sig = ifelse(p_value <= critical_value,"Y","N")) %>%
           mutate(Adj_R_Sq=r_list) %>%
           mutate(Intercept=intercept_list))
}

mod_z_test <- function(statMatrix,col1,col2){
  prop_matrix <- prop.test(statMatrix)
  
  median_stat <- median(prop_matrix$estimate)
  mad_stat <- mad(prop_matrix$estimate,constant = 1)
  
  prop_matrix_median <- (abs(prop_matrix$estimate - median_stat))/mad_stat
  
  diff_list <- c()
  p_list <- c()
  
  prop_matrix_df <- data.frame(statMatrix) %>% rownames_to_column("Annotation")

  prop_matrix_df <- prop_matrix_df %>%
    mutate(MADs_from_Median = prop_matrix_median)
  return(prop_matrix_df)
}

###### PRIMATE DATA ######
primate_min <- 41.0 # TimeTree.org: 05/30/2019
primate_max <- 45.7 # TimeTree.org: 05/30/2019
primate_outgroup <- c('AotNan','CalJac')

primate_anno_count <- read_tsv('C:/Users/User-Pc/Documents/GitHub/PhyloSignal_MS/Data_and_Tables/Annotation_Counts/Primate_Annotation_Counts.tsv',col_names = c('Data_Subset','All_Good_Bad','Split','Annotation','Count')) %>%
  mutate(Dataset="Primates")

primate_chronos <- ape::root.phylo(ape::read.tree('C:/Users/User-Pc/Documents/GitHub/PhyloSignal_MS/Data_and_Tables/Node_Date_Information/01_RAxML_Trees/Primate_Chronos_50000.nwk'),outgroup=primate_outgroup,resolve.root = TRUE)

primate_good_split_counts <- read_tsv('C:/Users/User-Pc/Documents/GitHub/PhyloSignal_MS/Data_and_Tables/Site_Splits/Primate_GoodSplit_Counts.tsv',col_names = c('Split','Taxa','Support'),col_types = 'ccn') %>%
  mutate(SplitType = "Phylogenetic Signal") %>%
  mutate(Dataset="Primates") %>% 
  separate(Taxa,into=c('Taxa_A','Taxa_B'),sep = '[.][.][.]') %>%
  rootFinder(split_table = .,topology_50000 = primate_chronos)

primate_focal_node_list <- primate_good_split_counts %>% filter(Root=="N") %>% pull(Node)

primate_bad_split_counts <- read_tsv('C:/Users/User-Pc/Documents/GitHub/PhyloSignal_MS/Data_and_Tables/Site_Splits/Primate_BadSplit_Counts.tsv',col_names = c('Split','Taxa','Support'),col_types = 'ccn') %>%
  mutate(SplitType = "Non-Phylogenetic Signal") %>%
  mutate(Dataset="Primates") %>% 
  separate(Taxa,into=c('Taxa_A','Taxa_B'),sep = '[.][.][.]')

primate_cal <- makeChronosCalib(primate_chronos,age.min = primate_min,age.max = primate_max) # Set chronos calibrartion using root CI from TimeTree.org

primate_edge_list <- compute.brlen(primate_chronos,1)$edge.length
primate_branch_list <- branching.times(compute.brlen(primate_chronos,1))  

for(i in 1:1000){
  primate_chronos_iter <- chronos(primate_chronos,calibration = primate_cal)
  primate_edge_list <- rbind(primate_edge_list, primate_chronos_iter$edge.length)
  primate_branch_list <- rbind(primate_branch_list, branching.times(primate_chronos_iter))
}

primate_edge_list <- primate_edge_list[-1,]
primate_branch_list <- primate_branch_list[-1,]

primate_branches <- colnames(primate_branch_list)

primate_medians <- c()
for(i in 1:ncol(primate_branch_list)){
  primate_medians[colnames(primate_branch_list)[i]] <- median(primate_branch_list[,i])
}

primate_focal_nodes <- data.frame(Node=as.integer(colnames(primate_branch_list)),Median_Node_Age=as.numeric(primate_medians)) %>% filter(Node %in% primate_focal_node_list) %>% left_join(primate_good_split_counts) %>%
  select(Dataset,SplitType,Split,Node,Median_Node_Age,Support,Taxa_A,Taxa_B)

primate_timetree <- compute.brlen(primate_chronos,1)
primate_median_edge <- c()
for(i in 1:ncol(primate_edge_list)){
  primate_median_edge<-c(primate_median_edge,median(primate_edge_list[,i]))
}
primate_timetree$edge.length <- primate_median_edge
if(!is.ultrametric(primate_timetree)){
  primate_timetree <- force.ultrametric(primate_timetree,"extend")
}

primate_anno_signal <- primate_anno_count %>% filter(All_Good_Bad=="Good" & Annotation!="SISRS_Sites") %>% 
  select(-Data_Subset,-All_Good_Bad) %>% 
  group_by(Split) %>%
  mutate(PercentSplit=(Count/sum(Count))*100) %>%
  left_join(select(primate_focal_nodes,Split,Node,Median_Node_Age),by="Split") %>%
  filter(Split %in% primate_focal_nodes$Split)

primate_good_split_counts <- primate_good_split_counts %>%
  left_join(select(primate_focal_nodes,Split,Median_Node_Age),by="Split") %>%
  mutate(Split = ifelse(Root=="Y","Root",Split))

###### RODENT DATA ######
rodent_min <- 26 # TimeTree.org: 05/30/2019
rodent_max <- 34 # TimeTree.org: 05/30/2019
rodent_outgroup <- c('EllLut','PerLeu')

rodent_anno_count <- read_tsv('C:/Users/User-Pc/Documents/GitHub/PhyloSignal_MS/Data_and_Tables/Annotation_Counts/Rodent_Annotation_Counts.tsv',col_names = c('Data_Subset','All_Good_Bad','Split','Annotation','Count')) %>%
  mutate(Dataset="Rodents")

rodent_chronos <- ape::root.phylo(ape::read.tree('C:/Users/User-Pc/Documents/GitHub/PhyloSignal_MS/Data_and_Tables/Node_Date_Information/01_RAxML_Trees/Rodent_Chronos_50000.nwk'),outgroup=rodent_outgroup,resolve.root = TRUE)

rodent_good_split_counts <- read_tsv('C:/Users/User-Pc/Documents/GitHub/PhyloSignal_MS/Data_and_Tables/Site_Splits/Rodent_GoodSplit_Counts.tsv',col_names = c('Split','Taxa','Support'),col_types = 'ccn') %>%
  mutate(SplitType = "Phylogenetic Signal") %>%
  mutate(Dataset="Rodents") %>% 
  separate(Taxa,into=c('Taxa_A','Taxa_B'),sep = '[.][.][.]') %>%
  rootFinder(split_table = .,topology_50000 = rodent_chronos)

rodent_focal_node_list <- rodent_good_split_counts %>% filter(Root=="N") %>% pull(Node)

rodent_bad_split_counts <- read_tsv('C:/Users/User-Pc/Documents/GitHub/PhyloSignal_MS/Data_and_Tables/Site_Splits/Rodent_BadSplit_Counts.tsv',col_names = c('Split','Taxa','Support'),col_types = 'ccn') %>%
  mutate(SplitType = "Non-Phylogenetic Signal") %>%
  mutate(Dataset="Rodents") %>% 
  separate(Taxa,into=c('Taxa_A','Taxa_B'),sep = '[.][.][.]')

rodent_cal <- makeChronosCalib(rodent_chronos,age.min = rodent_min,age.max = rodent_max) # Set chronos calibrartion using root CI from TimeTree.org

rodent_edge_list <- compute.brlen(rodent_chronos,1)$edge.length
rodent_branch_list <- branching.times(compute.brlen(rodent_chronos,1))  

for(i in 1:1000){
  rodent_chronos_iter <- chronos(rodent_chronos,calibration = rodent_cal)
  rodent_edge_list <- rbind(rodent_edge_list, rodent_chronos_iter$edge.length)
  rodent_branch_list <- rbind(rodent_branch_list, branching.times(rodent_chronos_iter))
}

rodent_edge_list <- rodent_edge_list[-1,]
rodent_branch_list <- rodent_branch_list[-1,]

rodent_branches <- colnames(rodent_branch_list)

rodent_medians <- c()
for(i in 1:ncol(rodent_branch_list)){
  rodent_medians[colnames(rodent_branch_list)[i]] <- median(rodent_branch_list[,i])
}

rodent_focal_nodes <- data.frame(Node=as.integer(colnames(rodent_branch_list)),Median_Node_Age=as.numeric(rodent_medians)) %>% filter(Node %in% rodent_focal_node_list) %>% left_join(rodent_good_split_counts) %>%
  select(Dataset,SplitType,Split,Node,Median_Node_Age,Support,Taxa_A,Taxa_B)

rodent_timetree <- compute.brlen(rodent_chronos,1)
rodent_median_edge <- c()
for(i in 1:ncol(rodent_edge_list)){
  rodent_median_edge<-c(rodent_median_edge,median(rodent_edge_list[,i]))
}
rodent_timetree$edge.length <- rodent_median_edge
if(!is.ultrametric(rodent_timetree)){
  rodent_timetree <- force.ultrametric(rodent_timetree,"extend")
}

rodent_anno_signal <- rodent_anno_count %>% filter(All_Good_Bad=="Good" & Annotation!="SISRS_Sites") %>% 
  select(-Data_Subset,-All_Good_Bad) %>% 
  group_by(Split) %>%
  mutate(PercentSplit=(Count/sum(Count))*100) %>%
  left_join(select(rodent_focal_nodes,Split,Node,Median_Node_Age),by="Split") %>%
  filter(Split %in% rodent_focal_nodes$Split)

rodent_good_split_counts <- rodent_good_split_counts %>%
  left_join(select(rodent_focal_nodes,Split,Median_Node_Age),by="Split") %>%
  mutate(Split = ifelse(Root=="Y","Root",Split))

###### PECORA DATA ######
pecora_min <- 54 # TimeTree.org: 05/30/2019
pecora_max <- 59 # TimeTree.org: 05/30/2019
pecora_outgroup <- c('HipAmp','BalMys')

pecora_anno_count <- read_tsv('C:/Users/User-Pc/Documents/GitHub/PhyloSignal_MS/Data_and_Tables/Annotation_Counts/Pecora_Annotation_Counts.tsv',col_names = c('Data_Subset','All_Good_Bad','Split','Annotation','Count')) %>%
  mutate(Dataset="Pecora")

pecora_chronos <- ape::root.phylo(ape::read.tree('C:/Users/User-Pc/Documents/GitHub/PhyloSignal_MS/Data_and_Tables/Node_Date_Information/01_RAxML_Trees/Pecora_Chronos_50000.nwk'),outgroup=pecora_outgroup,resolve.root = TRUE)

pecora_good_split_counts <- read_tsv('C:/Users/User-Pc/Documents/GitHub/PhyloSignal_MS/Data_and_Tables/Site_Splits/Pecora_GoodSplit_Counts.tsv',col_names = c('Split','Taxa','Support'),col_types = 'ccn') %>%
  mutate(SplitType = "Phylogenetic Signal") %>%
  mutate(Dataset="Pecora") %>% 
  separate(Taxa,into=c('Taxa_A','Taxa_B'),sep = '[.][.][.]') %>%
  rootFinder(split_table = .,topology_50000 = pecora_chronos)

pecora_focal_node_list <- pecora_good_split_counts %>% filter(Root=="N") %>% pull(Node)

pecora_bad_split_counts <- read_tsv('C:/Users/User-Pc/Documents/GitHub/PhyloSignal_MS/Data_and_Tables/Site_Splits/Pecora_BadSplit_Counts.tsv',col_names = c('Split','Taxa','Support'),col_types = 'ccn') %>%
  mutate(SplitType = "Non-Phylogenetic Signal") %>%
  mutate(Dataset="Pecora") %>% 
  separate(Taxa,into=c('Taxa_A','Taxa_B'),sep = '[.][.][.]')

pecora_cal <- makeChronosCalib(pecora_chronos,age.min = pecora_min,age.max = pecora_max) # Set chronos calibrartion using root CI from TimeTree.org

pecora_edge_list <- compute.brlen(pecora_chronos,1)$edge.length
pecora_branch_list <- branching.times(compute.brlen(pecora_chronos,1))  

for(i in 1:1000){
  pecora_chronos_iter <- chronos(pecora_chronos,calibration = pecora_cal)
  pecora_edge_list <- rbind(pecora_edge_list, pecora_chronos_iter$edge.length)
  pecora_branch_list <- rbind(pecora_branch_list, branching.times(pecora_chronos_iter))
}

pecora_edge_list <- pecora_edge_list[-1,]
pecora_branch_list <- pecora_branch_list[-1,]

pecora_branches <- colnames(pecora_branch_list)

pecora_medians <- c()
for(i in 1:ncol(pecora_branch_list)){
  pecora_medians[colnames(pecora_branch_list)[i]] <- median(pecora_branch_list[,i])
}

pecora_focal_nodes <- data.frame(Node=as.integer(colnames(pecora_branch_list)),Median_Node_Age=as.numeric(pecora_medians)) %>% filter(Node %in% pecora_focal_node_list) %>% left_join(pecora_good_split_counts) %>%
  select(Dataset,SplitType,Split,Node,Median_Node_Age,Support,Taxa_A,Taxa_B)

pecora_timetree <- compute.brlen(pecora_chronos,1)
pecora_median_edge <- c()
for(i in 1:ncol(pecora_edge_list)){
  pecora_median_edge<-c(pecora_median_edge,median(pecora_edge_list[,i]))
}
pecora_timetree$edge.length <- pecora_median_edge
if(!is.ultrametric(pecora_timetree)){
  pecora_timetree <- force.ultrametric(pecora_timetree,"extend")
}

pecora_anno_signal <- pecora_anno_count %>% filter(All_Good_Bad=="Good" & Annotation!="SISRS_Sites") %>% 
  select(-Data_Subset,-All_Good_Bad) %>% 
  group_by(Split) %>%
  mutate(PercentSplit=(Count/sum(Count))*100) %>%
  left_join(select(pecora_focal_nodes,Split,Node,Median_Node_Age),by="Split") %>%
  filter(Split %in% pecora_focal_nodes$Split)

pecora_good_split_counts <- pecora_good_split_counts %>%
  left_join(select(pecora_focal_nodes,Split,Median_Node_Age),by="Split") %>%
  mutate(Split = ifelse(Root=="Y","Root",Split))

###### COMBINED DATA ######
combined_outgroup <- c('BalMys','BisBis','BosTau','BubBub','CapAeg','CapHir','ElaDav','GirTip','HipAmp','OdoVir','OkaJoh','OviAri')
combined_chronos <- ape::root.phylo(ape::read.tree('C:/Users/User-Pc/Documents/GitHub/PhyloSignal_MS/Data_and_Tables/Node_Date_Information/01_RAxML_Trees/Combined_Chronos_50000.nwk'),outgroup=combined_outgroup,resolve.root = TRUE)
node <- c(
  getMRCA(combined_chronos, tip = c("BalMys","HomSap") ), # Root of tree
  getMRCA(combined_chronos, tip = c("AotNan","HomSap") ), # Base of primates
  getMRCA(combined_chronos, tip = c("EllLut","MusMus") ), # Base of rodents
  getMRCA(combined_chronos, tip = c("BalMys","OviAri") )  # Base of pecora
) 
age.min <- c(91,41.0,26,54) # TimeTree.org: 05/30/2019
age.max <- c(101,45.7,34,59) # TimeTree.org: 05/30/2019
soft.bounds <- c(FALSE,FALSE,FALSE,FALSE)
combined_cal <- data.frame(node, age.min, age.max, soft.bounds) 

combined_anno_count <- read_tsv('C:/Users/User-Pc/Documents/GitHub/PhyloSignal_MS/Data_and_Tables/Annotation_Counts/Combined_Annotation_Counts.tsv',col_names = c('Data_Subset','All_Good_Bad','Split','Annotation','Count')) %>%
  mutate(Dataset="Combined")


combined_good_split_counts <- read_tsv('C:/Users/User-Pc/Documents/GitHub/PhyloSignal_MS/Data_and_Tables/Site_Splits/Combined_GoodSplit_Counts.tsv',col_names = c('Split','Taxa','Support'),col_types = 'ccn') %>%
  mutate(SplitType = "Phylogenetic Signal") %>%
  mutate(Dataset="Combined") %>% 
  separate(Taxa,into=c('Taxa_A','Taxa_B'),sep = '[.][.][.]') %>%
  rootFinder(split_table = .,topology_50000 = combined_chronos)

combined_focal_node_list <- combined_good_split_counts %>% filter(Root=="N") %>% pull(Node)

combined_bad_split_counts <- read_tsv('C:/Users/User-Pc/Documents/GitHub/PhyloSignal_MS/Data_and_Tables/Site_Splits/Combined_BadSplit_Counts.tsv',col_names = c('Split','Taxa','Support'),col_types = 'ccn') %>%
  mutate(SplitType = "Non-Phylogenetic Signal") %>%
  mutate(Dataset="Combined") %>% 
  separate(Taxa,into=c('Taxa_A','Taxa_B'),sep = '[.][.][.]')

combined_edge_list <- compute.brlen(combined_chronos,1)$edge.length
combined_branch_list <- branching.times(compute.brlen(combined_chronos,1))  

for(i in 1:1000){
  combined_chronos_iter <- chronos(combined_chronos,calibration = combined_cal)
  combined_edge_list <- rbind(combined_edge_list, combined_chronos_iter$edge.length)
  combined_branch_list <- rbind(combined_branch_list, branching.times(combined_chronos_iter))
}

combined_edge_list <- combined_edge_list[-1,]
combined_branch_list <- combined_branch_list[-1,]

combined_branches <- colnames(combined_branch_list)

combined_medians <- c()
for(i in 1:ncol(combined_branch_list)){
  combined_medians[colnames(combined_branch_list)[i]] <- median(combined_branch_list[,i])
}

combined_focal_nodes <- data.frame(Node=as.integer(colnames(combined_branch_list)),Median_Node_Age=as.numeric(combined_medians)) %>% filter(Node %in% combined_focal_node_list) %>% left_join(combined_good_split_counts) %>%
  select(Dataset,SplitType,Split,Node,Median_Node_Age,Support,Taxa_A,Taxa_B)

combined_timetree <- compute.brlen(combined_chronos,1)
combined_median_edge <- c()
for(i in 1:ncol(combined_edge_list)){
  combined_median_edge<-c(combined_median_edge,median(combined_edge_list[,i]))
}
combined_timetree$edge.length <- combined_median_edge
if(!is.ultrametric(combined_timetree)){
  combined_timetree <- force.ultrametric(combined_timetree,"extend")
}

combined_anno_signal <- combined_anno_count %>% filter(All_Good_Bad=="Good" & Annotation!="SISRS_Sites") %>% 
  select(-Data_Subset,-All_Good_Bad) %>% 
  group_by(Split) %>%
  mutate(PercentSplit=(Count/sum(Count))*100) %>%
  left_join(select(combined_focal_nodes,Split,Node,Median_Node_Age),by="Split") %>%
  filter(Split %in% combined_focal_nodes$Split)

combined_good_split_counts <- combined_good_split_counts %>%
  left_join(select(combined_focal_nodes,Split,Median_Node_Age),by="Split") %>%
  mutate(Split = ifelse(Root=="Y","Root",Split))


###### PRINT TIME STATS ######
# write_tsv(primate_good_split_counts %>% select(Split,Taxa_A,Taxa_B,Node,Median_Node_Age),"C:/Users/User-Pc/Documents/GitHub/PhyloSignal_MS/Data_and_Tables/Node_Date_Information/02_Date_Estimates/Primate_Node_Table.tsv")
# write_tsv(rodent_good_split_counts %>% select(Split,Taxa_A,Taxa_B,Node,Median_Node_Age),"C:/Users/User-Pc/Documents/GitHub/PhyloSignal_MS/Data_and_Tables/Node_Date_Information/02_Date_Estimates/Rodent_Node_Table.tsv")
# write_tsv(pecora_good_split_counts %>% select(Split,Taxa_A,Taxa_B,Node,Median_Node_Age),"C:/Users/User-Pc/Documents/GitHub/PhyloSignal_MS/Data_and_Tables/Node_Date_Information/02_Date_Estimates/Pecora_Node_Table.tsv")
# write_tsv(combined_good_split_counts %>% select(Split,Taxa_A,Taxa_B,Node,Median_Node_Age),"C:/Users/User-Pc/Documents/GitHub/PhyloSignal_MS/Data_and_Tables/Node_Date_Information/02_Date_Estimates/Combined_Node_Table.tsv")
# 
# 
# write.tree(primate_timetree,"C:/Users/User-Pc/Documents/GitHub/PhyloSignal_MS/Data_and_Tables/Node_Date_Information/03_R_TimeTrees/Primate_TimeTree.nwk")
# write.tree(rodent_timetree,"C:/Users/User-Pc/Documents/GitHub/PhyloSignal_MS/Data_and_Tables/Node_Date_Information/03_R_TimeTrees/Rodent_TimeTree.nwk")
# write.tree(pecora_timetree,"C:/Users/User-Pc/Documents/GitHub/PhyloSignal_MS/Data_and_Tables/Node_Date_Information/03_R_TimeTrees/Pecora_TimeTree.nwk")
# write.tree(combined_timetree,"C:/Users/User-Pc/Documents/GitHub/PhyloSignal_MS/Data_and_Tables/Node_Date_Information/03_R_TimeTrees/Combined_TimeTree.nwk")

###### SPLIT SUPPORT ANALYSIS ######

#Mann-Whitney-Wilcoxon test for good versus bad split support
primate_support <- primate_good_split_counts %>%
  select(Dataset,Split,SplitType,Support) %>%
  rbind(select(primate_bad_split_counts,Dataset,Split,SplitType,Support))
primate_wilcox <- wilcox.test(Support ~ SplitType, data=primate_support)

rodent_support <- rodent_good_split_counts %>%
  select(Dataset,Split,SplitType,Support) %>%
  rbind(select(rodent_bad_split_counts,Dataset,Split,SplitType,Support))
rodent_wilcox <- wilcox.test(Support ~ SplitType, data=rodent_support)

pecora_support <- pecora_good_split_counts %>%
  select(Dataset,Split,SplitType,Support) %>%
  rbind(select(pecora_bad_split_counts,Dataset,Split,SplitType,Support))
pecora_wilcox <- wilcox.test(Support ~ SplitType, data=pecora_support)

combined_support <- combined_good_split_counts %>%
  select(Dataset,Split,SplitType,Support) %>%
  rbind(select(combined_bad_split_counts,Dataset,Split,SplitType,Support))
combined_wilcox <- wilcox.test(Support ~ SplitType, data=combined_support)

primate_wilcox$p.value
rodent_wilcox$p.value
pecora_wilcox$p.value
combined_wilcox$p.value

all_support <- rbind(primate_support,rodent_support,pecora_support,combined_support) 

support_summary <- all_support %>% 
  group_by(Dataset,SplitType) %>% 
  summarize(Total_Support = sum(Support),Min_Support=min(Support),Max_Support=max(Support),Mean_Support = mean(Support),Median_Support=median(Support))

#Figure
split_figure <- rbind(primate_support,rodent_support,pecora_support,combined_support) %>% group_by(Dataset,SplitType) %>%
  ggplot(aes(x=Dataset,fill=SplitType, y=Support)) +
  scale_y_log10() +
  geom_violin(trim=TRUE) +
  ylab("Log10 (Split Support)") +
  theme(axis.title.x=element_text(size=14,face="bold"),
        axis.title.y =element_text(size=14,face="bold"),
        axis.text.x =element_text(size=14,face="bold"),
        axis.text.y =element_text(size=14),
        axis.line = element_line(colour = "black",size=1),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank())

###### Z-SCORE ANALYSIS ######

#Set up comparison annotation DFs

all_anno <- rbind(primate_anno_count,rodent_anno_count,pecora_anno_count,combined_anno_count)

reference_breakdown <- all_anno %>% filter(Data_Subset == "Reference") %>% select(Dataset,Annotation,Count)
colnames(reference_breakdown) <- c('Dataset','Annotation','Reference')

composite_breakdown <- all_anno %>% filter(Data_Subset == "Composite") %>% select(Dataset,Annotation,Count)
colnames(composite_breakdown) <- c('Dataset','Annotation','Composite')

sisrs_breakdown <- all_anno %>% filter(Data_Subset == "SISRS" & All_Good_Bad == "All") %>% select(Dataset,Annotation,Count)
colnames(sisrs_breakdown) <- c('Dataset','Annotation','SISRS')

concordant_breakdown <- all_anno %>% filter(Data_Subset == "SISRS" & All_Good_Bad == "Good" & Split == "All") %>% select(Dataset,Annotation,Count)
colnames(concordant_breakdown) <- c('Dataset','Annotation','Concordant')

anno_breakdown <- join_all(list(reference_breakdown,composite_breakdown,sisrs_breakdown,concordant_breakdown),by=c("Dataset","Annotation"),type="left") %>% 
  mutate(Composite_Percent = Composite/Reference*100) %>% 
  mutate(Unassembled = Reference - Composite) %>% 
  mutate(SISRS_Percent = SISRS/Composite*100) %>% 
  mutate(Filtered_Out = Composite - SISRS) %>%
  mutate(Concordant_Percent = Concordant/SISRS*100) %>% 
  mutate(Discordant = SISRS - Concordant) %>%
  select(Dataset,Annotation,Reference,Composite,Composite_Percent,SISRS,SISRS_Percent,Concordant,Concordant_Percent,Unassembled,Filtered_Out,Discordant)

#Primates
primate_anno <- anno_breakdown %>% filter(Dataset=="Primates")

primate_ref_comp <- as.matrix(primate_anno %>% select(Composite,Unassembled))
rownames(primate_ref_comp) <- primate_anno %>% pull(Annotation)

primate_comp_sisrs <- as.matrix(primate_anno %>% select(SISRS,Filtered_Out))
rownames(primate_comp_sisrs) <- primate_anno %>% pull(Annotation)

primate_sisrs_conc <- as.matrix(primate_anno %>% select(Concordant,Discordant))
rownames(primate_sisrs_conc) <- primate_anno %>% pull(Annotation)

#Rodents
rodent_anno <- anno_breakdown %>% filter(Dataset=="Rodents")

rodent_ref_comp <- as.matrix(rodent_anno %>% select(Composite,Unassembled))
rownames(rodent_ref_comp) <- rodent_anno %>% pull(Annotation)

rodent_comp_sisrs <- as.matrix(rodent_anno %>% select(SISRS,Filtered_Out))
rownames(rodent_comp_sisrs) <- rodent_anno %>% pull(Annotation)

rodent_sisrs_conc <- as.matrix(rodent_anno %>% select(Concordant,Discordant))
rownames(rodent_sisrs_conc) <- rodent_anno %>% pull(Annotation)

#Pecora
pecora_anno <- anno_breakdown %>% filter(Dataset=="Pecora")

pecora_ref_comp <- as.matrix(pecora_anno %>% select(Composite,Unassembled))
rownames(pecora_ref_comp) <- pecora_anno %>% pull(Annotation)

pecora_comp_sisrs <- as.matrix(pecora_anno %>% select(SISRS,Filtered_Out))
rownames(pecora_comp_sisrs) <- pecora_anno %>% pull(Annotation)

pecora_sisrs_conc <- as.matrix(pecora_anno %>% select(Concordant,Discordant))
rownames(pecora_sisrs_conc) <- pecora_anno %>% pull(Annotation)

#Combined
combined_anno <- anno_breakdown %>% filter(Dataset=="Combined")

combined_ref_comp <- as.matrix(combined_anno %>% select(Composite,Unassembled))
rownames(combined_ref_comp) <- combined_anno %>% pull(Annotation)

combined_comp_sisrs <- as.matrix(combined_anno %>% select(SISRS,Filtered_Out))
rownames(combined_comp_sisrs) <- combined_anno %>% pull(Annotation)

combined_sisrs_conc <- as.matrix(combined_anno %>% select(Concordant,Discordant))
rownames(combined_sisrs_conc) <- combined_anno %>% pull(Annotation)

#Tests of proportions within groups

#Primates (9 annotations ~ alpha = 0.05/9 ~ Critical Z = 2.77)

primate_ref_comp_df <- mod_z_test(primate_ref_comp,'Composite','Unassembled') %>%
  mutate(Dataset="Primates") %>%
  mutate(Test="Composite") %>%
  mutate(MAD=ifelse(MADs_from_Median >= 2.77,'Y','N'))
primate_comp_sisrs_df <- mod_z_test(primate_comp_sisrs,'SISRS','Filtered_Out') %>%
  mutate(Dataset="Primates") %>%
  mutate(Test="SISRS") %>%
  mutate(MAD=ifelse(MADs_from_Median >= 2.77,'Y','N'))
primate_sisrs_conc_df <- mod_z_test(primate_sisrs_conc,'Concordant','Discordant') %>%
  mutate(Dataset="Primates") %>%
  mutate(Test="Concordant") %>%
  mutate(MAD=ifelse(MADs_from_Median >= 2.77,'Y','N'))

#Rodents

rodent_ref_comp_df <- mod_z_test(rodent_ref_comp,'Composite','Unassembled') %>%
  mutate(Dataset="Rodents") %>%
  mutate(Test="Composite") %>%
  mutate(MAD=ifelse(MADs_from_Median >= 2.77,'Y','N'))
rodent_comp_sisrs_df <- mod_z_test(rodent_comp_sisrs,'SISRS','Filtered_Out') %>%
  mutate(Dataset="Rodents") %>%
  mutate(Test="SISRS") %>%
  mutate(MAD=ifelse(MADs_from_Median >= 2.77,'Y','N'))
rodent_sisrs_conc_df <- mod_z_test(rodent_sisrs_conc,'Concordant','Discordant') %>%
  mutate(Dataset="Rodents") %>%
  mutate(Test="Concordant") %>%
  mutate(MAD=ifelse(MADs_from_Median >= 2.77,'Y','N'))


#Pecora (7 annotations ~ alpha = 0.05/7 ~ Critical Z = 2.69)

pecora_ref_comp_df <- mod_z_test(pecora_ref_comp,'Composite','Unassembled') %>%
  mutate(Dataset="Pecora") %>%
  mutate(Test="Composite") %>%
  mutate(MAD=ifelse(MADs_from_Median >= 2.69,'Y','N'))
pecora_comp_sisrs_df <- mod_z_test(pecora_comp_sisrs,'SISRS','Filtered_Out') %>%
  mutate(Dataset="Pecora") %>%
  mutate(Test="SISRS") %>%
  mutate(MAD=ifelse(MADs_from_Median >= 2.69,'Y','N'))
pecora_sisrs_conc_df <- mod_z_test(pecora_sisrs_conc,'Concordant','Discordant') %>%
  mutate(Dataset="Pecora") %>%
  mutate(Test="Concordant") %>%
  mutate(MAD=ifelse(MADs_from_Median >= 2.69,'Y','N'))

#Combined

combined_ref_comp_df <- mod_z_test(combined_ref_comp,'Composite','Unassembled') %>%
  mutate(Dataset="Combined") %>%
  mutate(Test="Composite") %>%
  mutate(MAD=ifelse(MADs_from_Median >= 2.77,'Y','N'))
combined_comp_sisrs_df <- mod_z_test(combined_comp_sisrs,'SISRS','Filtered_Out') %>%
  mutate(Dataset="Combined") %>%
  mutate(Test="SISRS") %>%
  mutate(MAD=ifelse(MADs_from_Median >= 2.77,'Y','N'))
combined_sisrs_conc_df <- mod_z_test(combined_sisrs_conc,'Concordant','Discordant') %>%
  mutate(Dataset="Combined") %>%
  mutate(Test="Concordant") %>%
  mutate(MAD=ifelse(MADs_from_Median >= 2.77,'Y','N'))

#Prep joins

ref_comp <- rbind(primate_ref_comp_df,rodent_ref_comp_df,pecora_ref_comp_df,combined_ref_comp_df) %>%
  select(Dataset,Test,Annotation,Composite,MADs_from_Median,MAD)

comp_sisrs <- rbind(primate_comp_sisrs_df,rodent_comp_sisrs_df,pecora_comp_sisrs_df,combined_comp_sisrs_df) %>%
  select(Dataset,Test,Annotation,SISRS,MADs_from_Median,MAD)

sisrs_conc <- rbind(primate_sisrs_conc_df,rodent_sisrs_conc_df,pecora_sisrs_conc_df,combined_sisrs_conc_df) %>%
  select(Dataset,Test,Annotation,Concordant,MADs_from_Median,MAD)

#Compile data
anno_comp <- anno_breakdown %>% 
  select(Dataset,Annotation,Composite_Percent) %>% 
  mutate(Test="Composite") %>% rename(Percent='Composite_Percent') %>%
  left_join(ref_comp,by = c('Dataset','Test','Annotation')) %>%
  rename(Positive="Composite")

anno_sisrs <- anno_breakdown %>% 
  select(Dataset,Annotation,SISRS_Percent) %>% 
  mutate(Test="SISRS") %>% 
  rename(Percent='SISRS_Percent') %>%
  left_join(comp_sisrs,by = c('Dataset','Test','Annotation')) %>%
  rename(Positive="SISRS")

anno_conc <- anno_breakdown %>% 
  select(Dataset,Annotation,Concordant_Percent) %>% 
  mutate(Test="Concordant") %>% 
  rename(Percent='Concordant_Percent') %>%
  left_join(sisrs_conc,by = c('Dataset','Test','Annotation')) %>%
  rename(Positive="Concordant")

outlier_df <- rbind(anno_comp,anno_sisrs,anno_conc) %>%
  mutate(p_val = 2*pnorm(-abs(MADs_from_Median )))

#Significant deviations from median

mad_sets <- outlier_df %>% 
  filter(MAD=="Y") %>% 
  select(Test,Dataset,Annotation) %>% 
  group_by(Test,Dataset) %>% 
  summarize(MAD_Anno = paste(Annotation, collapse=";"))

mad_diff_df <- outlier_df %>% 
  group_by(Dataset,Test,MAD) %>% 
  summarize(Percent=mean(Percent)) %>% 
  spread(MAD,Percent) %>% 
  filter(!is.na(Y)) %>% 
  mutate(MAD_Diff = Y-N) %>% 
  mutate(MAD_Percent_Change = ((Y-N)/N)*100) %>% 
  right_join(mad_sets,by=c('Test','Dataset')) %>%
  ungroup() %>%
  mutate(Test=factor(Test,levels = c('Composite','SISRS','Concordant'))) %>%
  arrange(Test,Dataset)

cds_diff_df <- outlier_df %>% 
  filter(Test=="Concordant") %>%
  mutate(IsCDS = ifelse(Annotation=="CDS","Y","N")) %>%
  group_by(Dataset,Test,IsCDS) %>% 
  summarize(Percent=median(Percent)) %>% 
  spread(IsCDS,Percent) %>% 
  filter(!is.na(Y)) %>% 
  mutate(CDS_Diff = Y-N) %>% 
  mutate(CDS_Percent_Change = ((Y-N)/N)*100) %>% 
  arrange(Test,Dataset)

#Figure

z_facet_names <- c(`Composite` = "Reference to Composite",`SISRS` = "Composite to SISRS",`Concordant` = "Percent Concordance")

z_figure_df <- outlier_df %>%
  mutate(Test=factor(Test,levels = c('Composite','SISRS','Concordant'))) %>%
  mutate(Dataset=factor(Dataset,levels = c('Combined','Rodents','Pecora','Primates'))) %>%
  mutate(Annotation_Label = ifelse(MAD=="Y",Annotation,"Not Signficant")) %>%
  mutate(Annotation_Size = ifelse(MAD=="Y",5,2))

z_figure <- ggplot(z_figure_df,aes(x=Dataset,y=Percent)) + 
  geom_point(aes(size=Annotation_Size,color=Annotation_Label,shape=Annotation_Label,fill=Annotation_Label)) +
  geom_boxplot(width=0.15,alpha=0.1,coef = 0,outlier.shape = NA) +
  facet_grid(~Test,scales='free',labeller = as_labeller(z_facet_names)) +
  scale_fill_manual(name = "Annotation Type",labels=c('CDS','Five-prime UTR','Pseudogene','smRNA','Three-prime UTR'),breaks=c('CDS','fivePrimeUTR','pseudogene','smRNA','threePrimeUTR'),values = c("#D55E00","#009E73","#000000","#0072B2","#56B4E9","#CC79A7")) +
  scale_color_manual(name = "Annotation Type",labels=c('CDS','Five-prime UTR','Pseudogene','smRNA','Three-prime UTR'),breaks=c('CDS','fivePrimeUTR','pseudogene','smRNA','threePrimeUTR'),values = c("#D55E00","#009E73","#000000","#0072B2","#56B4E9","#CC79A7")) +
  scale_shape_manual(name = "Annotation Type",labels=c('CDS','Five-prime UTR','Pseudogene','smRNA','Three-prime UTR'),breaks=c('CDS','fivePrimeUTR','pseudogene','smRNA','threePrimeUTR'),values = c(17,15,1,25,16,23)) +
  scale_size_identity() + 
  coord_flip() +
  ylab("\nPercent of Sites from Previous Pool") +
  theme_bw() +
  theme(axis.title=element_text(size=14,face="bold"),
        axis.text.x=element_text(size=13),
        axis.text.y = element_text(size=13,face="bold"),
        axis.title.y = element_blank(),
        legend.text =element_text(size=13),
        legend.title = element_text(size=13,face="bold"),
        panel.spacing = unit(1.5, "lines"),
        legend.title.align=0.5,
        strip.text.x = element_text(size = 12,face="bold")) + 
  guides(shape = guide_legend(override.aes = list(size = 4)))

###### TIME-DEPENDENT ANALYSES ######

#all_tax_signal <- rbind(primate_anno_signal,rodent_anno_signal,pecora_anno_signal,combined_anno_signal)
all_tax_signal <- read_tsv("C:/Users/User-Pc/Documents/GitHub/PhyloSignal_MS/Data_and_Tables/Node_Date_Information/04_Plot_Data/all_tax_signal.tsv",col_types = "ccicnin" )


time_lm_df <- rbind(time_lm(all_tax_signal[all_tax_signal$Dataset=="Primates",],'Primates'),
                    time_lm(all_tax_signal[all_tax_signal$Dataset=="Rodents",],'Rodents'),
                    time_lm(all_tax_signal[all_tax_signal$Dataset=="Pecora",],'Pecora'),
                    time_lm(all_tax_signal[all_tax_signal$Dataset=="Combined",],'Combined'))

min_max_time_df <- all_tax_signal %>% group_by(Dataset) %>% summarize(Min_Node=min(Median_Node_Age),Max_Node=max(Median_Node_Age))

sig_time_lm_df <- time_lm_df %>% filter(BF_Sig =="Y") %>% 
  left_join(min_max_time_df,by="Dataset") %>%
  mutate(Young_Estimate = ((Slope*Min_Node)+Intercept),Old_Estimate=((Slope*Max_Node)+Intercept)) %>%
  mutate(Slope_Diff = Slope / Young_Estimate*100) %>%
  arrange(Annotation)
  
#Figure

median_order <- all_tax_signal %>% group_by(Annotation) %>% summarize(Median = median(PercentSplit)) %>% arrange(desc(Median)) %>% pull(Annotation)

all_time_figure <- all_tax_signal %>%
  left_join(select(sig_time_lm_df,c(BF_Sig,Dataset,Annotation)),by=c('Dataset','Annotation')) %>%
  mutate(BF_Sig = replace_na(BF_Sig,"N")) %>% 
  mutate(Annotation = factor(Annotation, levels=median_order)) %>%
  ggplot(aes(x=Median_Node_Age,y=PercentSplit,color=Dataset)) +
  geom_jitter(size=2,aes(shape=BF_Sig)) +
  geom_smooth(size=1,method=lm,se=TRUE) +
  theme_bw() +
  theme(axis.title.x=element_text(size=6,face="bold"),
        axis.title.y =element_text(size=5,face="bold",margin = margin(t = 0, r = 20, b = 0, l = 0)),
        axis.text.x =element_text(size=6,face="bold"),
        axis.text.y =element_text(size=6),
        strip.text.x = element_text(size = 5,face="bold",margin = margin(t = 10, r = 0, b =10, l = 0)),
        panel.spacing = unit(2, "lines"),
        legend.position = "none") +
  scale_color_colorblind() +
  xlab("\nNode Age (MYA)\n") +
  ylab("Percent Support from Subset") +
  #scale_y_continuous(limits = c(0,110),breaks=seq(0,100,20)) +
  facet_wrap(~Annotation,scales = 'free')

ms_time_df <- all_tax_signal %>%
  filter(Annotation=="CDS" | Annotation=="intronic" | Annotation =="lncRNA" | Annotation == "intergenic") %>%
  left_join(select(sig_time_lm_df,c(BF_Sig,Dataset,Annotation)),by=c('Dataset','Annotation')) %>%
  mutate(BF_Sig = replace_na(BF_Sig,"N")) %>% 
  mutate(Annotation = factor(Annotation, labels = c("CDS","Intronic","lncRNA","Intergenic"),levels=c("CDS","intronic","lncRNA","intergenic"))) %>%
  mutate(Dataset = factor(Dataset,levels = c("Pecora","Primates","Rodents","Combined"))) %>%
  mutate(Anno_Shape = ifelse(Dataset=="Primates" & BF_Sig=="Y","Primates, Signficant",
                      ifelse(Dataset=="Primates" & BF_Sig=="N","Primates, Not Signficant",
                      ifelse(Dataset=="Rodents" & BF_Sig=="Y","Rodents, Signficant",
                      ifelse(Dataset=="Rodents" & BF_Sig=="N","Rodents, Not Signifcant",
                      ifelse(Dataset=="Pecora" & BF_Sig=="Y","Pecora, Signficant",
                      ifelse(Dataset=="Pecora" & BF_Sig=="N","Pecora, Not Signficant",
                      ifelse(Dataset=="Combined" & BF_Sig=="Y","Combined, Signifcant",
                      "Combined, Not Significant"))))))))

ms_time_figure <- ggplot(ms_time_df,aes(x=Median_Node_Age,y=PercentSplit)) +
geom_jitter(size=4,aes(shape=Anno_Shape,color=Anno_Shape)) +
geom_smooth(size=1,method=lm,se=TRUE,aes(color=Anno_Shape),show.legend = FALSE) +
theme_bw() +
theme(axis.title=element_text(size=14,face="bold"),
      axis.text.x=element_text(size=13),
      axis.text.y = element_text(size=13,face="bold"),
      legend.text =element_text(size=13),
      legend.title = element_text(size=13,face="bold"),
      panel.spacing = unit(1.5, "lines"),
      legend.title.align=0.5,
      strip.text.x = element_text(size = 12,face="bold")) + 
xlab("\nTime Since Split (MYA)\n") +
ylab("Proportion of Phylogenetic Signal (%)\n") +
facet_wrap(~Annotation,scales="free") +
scale_shape_manual(name="Dataset and Signficance",values = c(0,15,2,17,1,5,18)) +
scale_color_manual(name="Dataset and Signficance",values = c('#D55E00','#D55E00','#56B4E9','#56B4E9','#000000','#009E73','#009E73')) +
scale_x_reverse() +
guides(shape = guide_legend(override.aes = list(size = 4)))


###### TREE FIGURE ######
combined_ggtree <- combined_good_split_counts %>% 
  filter(Root=="N") %>%
  mutate(Mono_Taxa = ifelse(Mono_A,Taxa_A,Taxa_B)) %>%
  rename(node='Node') %>%
  select(node,Dataset,Support,Mono_Taxa)

primate_ggtree <- primate_good_split_counts %>% 
  filter(Root=="N") %>%
  mutate(Mono_Taxa = ifelse(Mono_A,Taxa_A,Taxa_B)) %>%
  select(Dataset,Support,Mono_Taxa) %>%
  left_join(select(combined_ggtree,Mono_Taxa,node))

rodent_ggtree <- rodent_good_split_counts %>% 
  filter(Root=="N") %>%
  mutate(Mono_Taxa = ifelse(Mono_A,Taxa_A,Taxa_B)) %>%
  select(Dataset,Support,Mono_Taxa) %>%
  left_join(select(combined_ggtree,Mono_Taxa,node))

pecora_ggtree <- pecora_good_split_counts %>% 
  filter(Root=="N") %>%
  mutate(Mono_Taxa = ifelse(Mono_A,Taxa_A,Taxa_B)) %>%
  select(Dataset,Support,Mono_Taxa) %>%
  left_join(select(combined_ggtree,Mono_Taxa,node))

ggtree_df <- rbind(primate_ggtree,rodent_ggtree,pecora_ggtree) %>%
  select(node,Dataset,Support) %>%
  rbind(select(combined_ggtree,node,Dataset,Support)) %>%
  mutate(Support = rescale(Support,to=c(3.5,20)))

focal_ggtree_df  <- ggtree_df %>% filter(Dataset!="Combined")
focal_combined_ggtree_df <- ggtree_df %>% filter(Dataset=="Combined")
combined_ggtree_df <- ggtree_df %>% filter(Dataset=="Combined" & !(node %in% focal_ggtree_df$node))

ggtree_combo <- combined_timetree
ggtree_combo$tip.label <- c("Colobus angolensis","Macaca mulatta","Macaca nemestrina","Papio anubis","Papio cynocephalus","Hylobates moloch","Homo sapiens","Pan troglodytes","Pan paniscus","Gorilla gorilla","Peromyscus leucopus","Ellobius lutescens","Psammomys obesus","Meriones unguiculatus","Rattus norvegicus","Rattus nitidus","Apodemus sylvaticus","Apodemus uralensis","Mus musculus","Mus spretus","Mus caroli","Mastomys coucha","Capra aegagrus","Capra hircus","Ovis aries","Bubalis bubalis","Bison bison","Bos taurus","Odocoileus virginianus","Elaphurus davidianus","Okapia johnstoni","Giraffa tippelskirchi","Balaena mysticetus","Hippopotamus amphibius","Callithrix jacchus","Aotus nancymaae")

combo_tree <- ggtree(ggtree_combo,size=1.3,branch.length = "none") + geom_tiplab(fontface="italic",size=6)

focal_tree_figure <- combo_tree  %<+% focal_ggtree_df + 
  geom_nodepoint(alpha=0.9,aes(shape=Dataset,size=Support,color=Dataset)) + 
  scale_size_identity() + 
  scale_color_manual(values = c("#56B4E9","#E69F00","#009E73")) + 
  ggplot2::xlim(0, 12)

# combo_focal_mask <- ggtree(ggtree_combo,branch.length = "none",color="white")  %<+% focal_combined_ggtree_df + 
#   geom_nodepoint(alpha=0.5,aes(size=Support)) + 
#   scale_size_identity() + 
#   ggplot2::xlim(0, 12) 

combo_only_mask <- ggtree(ggtree_combo,branch.length = "none",color="white")  %<+% combined_ggtree_df + 
  geom_nodepoint(shape=18,alpha=0.9,color="black",aes(size=Support)) + 
  scale_size_identity() + 
  ggplot2::xlim(0, 12)

###### CHECK FIGURES ######
#Figure 1
#focal_tree_figure
#combo_focal_mask
#combo_only_mask

#Figure 2
#z_figure
#ggsave("C:/Users/User-Pc/Documents/GitHub/PhyloSignal_MS/Figures/Figure2.tif",z_figure,device = "tiff",units = "in",width = 15,height=5)

#Figure 3
ms_time_figure
#ggsave("C:/Users/User-Pc/Documents/GitHub/PhyloSignal_MS/Figures/Figure3.tif",ms_time_figure,device = "tiff",units = "in",width = 8,height=7)

#all_time_figure

#Figure S1
#split_figure





