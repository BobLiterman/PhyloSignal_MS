rm(list=ls())
library(ape)
library(scales)
library(reshape)
library(phylobase)
library(lsr)
library(plyr)
library(tidyverse)

statLetter <- function(statMatrix){
  #Extract p-value pairwise comparisons and create symmetric matrix

  p_table <- as.matrix(pairwise.prop.test(statMatrix)[3][[1]])

  row_col <- nrow(p_table)
  first_col <- colnames(p_table)[1]
  last_row <- rownames(p_table)[row_col]

  sym_p_table <- cbind(rbind(replicate(row_col,NA),p_table),replicate(row_col+1,NA))


  rownames(sym_p_table) <- c(first_col,rownames(p_table))
  colnames(sym_p_table) <- c(colnames(p_table),last_row)

  stat_letters <- data.frame(multcompView::multcompLetters(sym_p_table,compare = "<",threshold = 0.05)[[1]]) %>%
    rownames_to_column("Annotation")
  colnames(stat_letters) <- c('Annotation','StatGroup')
  return(stat_letters)
}

# #Primates
# base_dir <- "C:/Users/User-Pc/Desktop/Mammal_R/Datasets/Primates"
# dataset <- "Primates"
# out_file <-  "C:/Users/User-Pc/Desktop/Mammal_R/Primate_Annotation_Breakdown.tsv"
#
# #Rodents
# base_dir <- 'C:/Users/User-Pc/Desktop/Mammal_R/Datasets/Rodents'
# dataset <- "Rodents"
# out_file <-  "C:/Users/User-Pc/Desktop/Mammal_R/Rodent_Annotation_Breakdown.tsv"
#
# #Pecora
# base_dir <- 'C:/Users/User-Pc/Desktop/Mammal_R/Datasets/Pecora'
# dataset <- "Pecora"
# out_file <-  "C:/Users/User-Pc/Desktop/Mammal_R/Pecora_Annotation_Breakdown.tsv"
#
# #Combined
base_dir <- 'C:/Users/User-Pc/Desktop/Mammal_R/Datasets/Combined'
dataset <- "Combined"
out_file <-  "C:/Users/User-Pc/Desktop/Mammal_R/Combined_Annotation_Breakdown.tsv"

##### ANNOTATION COMPARISONS #####

annotation_count_path <- paste(base_dir,'/Post_SISRS_Processing/Annotations/Annotation_Counts.tsv',sep = '')

raw_count_data <- read_delim(annotation_count_path,delim = '\t',col_names = c('Dataset','Category','Split','Type','Count'))

# Set up base annotation DF
reference_breakdown <- raw_count_data %>% filter(Dataset == "Reference") %>% select(Type,Count)
colnames(reference_breakdown) <- c('Annotation','Reference')
composite_breakdown <- raw_count_data %>% filter(Dataset == "Composite") %>% select(Type,Count)
colnames(composite_breakdown) <- c('Annotation','Composite')
sisrs_breakdown <- raw_count_data %>% filter(Dataset == "SISRS" & Category == "All") %>% select(Type,Count)
colnames(sisrs_breakdown) <- c('Annotation','SISRS')
concordant_breakdown <- raw_count_data %>% filter(Dataset == "SISRS" & Category == "Good" & Split == "All") %>% select(Type,Count)
colnames(concordant_breakdown) <- c('Annotation','Concordant')

anno_breakdown <- join_all(list(reference_breakdown,composite_breakdown,sisrs_breakdown,concordant_breakdown),by="Annotation",type="left") %>% arrange(Annotation)

##### COMPARE REFERENCE AND COMPOSITE (WHAT GOT ASSEMBLED?) #####

ref_comp_pool <- anno_breakdown %>%
  select(Annotation,Composite,Reference) %>%
  mutate(Composite_Percent = Composite/Reference*100) %>%
  mutate(Unassembled = Reference - Composite) %>%
  arrange(Annotation)

ref_comp_matrix <- cbind(ref_comp_pool$Composite,ref_comp_pool$Unassembled)
rownames(ref_comp_matrix) <- ref_comp_pool$Annotation
colnames(ref_comp_matrix) <- c('Composite','Unassembled')
ref_comp_letters <- statLetter(ref_comp_matrix)

chi_list <- c()
p_list <- c()
diff_list <- c()

for(anno in ref_comp_pool$Annotation){
  in_data <- ref_comp_pool %>% filter(Annotation == anno) %>% select(Composite,Unassembled) %>% colSums()
  out_data <- ref_comp_pool %>% filter(Annotation != anno) %>% select(Composite,Unassembled) %>% colSums()
  test_matrix <- rbind(in_data,out_data)
  row.names(test_matrix) <- c(anno,'Other')
  chi_test <- prop.test(test_matrix)
  chi_list <- c(chi_list,chi_test$statistic)
  p_list <- c(p_list,chi_test$p.value)
  diff_list <- c(diff_list,(chi_test$estimate[[1]]-chi_test$estimate[[2]])*100)
}

ref_comp_pool$Solo_ChiSquare <- chi_list
ref_comp_pool$Solo_P.Value <- p_list
ref_comp_pool$Solo_Rel.Diff <- diff_list

ref_comp_pool <- ref_comp_pool %>%
  arrange(desc(Solo_ChiSquare)) %>%
  mutate(Solo_BF_Sig = ifelse(Solo_P.Value < (0.05/nrow(ref_comp_pool)),"BF_Sig","Not_Sig")) %>%
  select(-Unassembled) %>%
  left_join(ref_comp_letters,by="Annotation")

##### COMPARE COMPOSITE AND SISRS (WHAT GOT FILTERED OUT?) #####

comp_sisrs_pool <- anno_breakdown %>%
  select(Annotation,SISRS,Composite) %>%
  mutate(SISRS_Percent = SISRS/Composite*100) %>%
  mutate(Filtered_Out = Composite - SISRS) %>%
  arrange(Annotation)

comp_sisrs_matrix <- cbind(comp_sisrs_pool$SISRS,comp_sisrs_pool$Filtered_Out)
rownames(comp_sisrs_matrix) <- comp_sisrs_pool$Annotation
colnames(comp_sisrs_matrix) <- c('SISRS','Filtered_Out')
comp_sisrs_letters <- statLetter(comp_sisrs_matrix)


chi_list <- c()
p_list <- c()
diff_list <- c()

for(anno in comp_sisrs_pool$Annotation){
  in_data <- comp_sisrs_pool %>% filter(Annotation == anno) %>% select(SISRS,Filtered_Out) %>% colSums()
  out_data <- comp_sisrs_pool %>% filter(Annotation != anno) %>% select(SISRS,Filtered_Out) %>% colSums()
  test_matrix <- rbind(in_data,out_data)
  row.names(test_matrix) <- c(anno,'Other')
  chi_test <- prop.test(test_matrix)
  chi_list <- c(chi_list,chi_test$statistic)
  p_list <- c(p_list,chi_test$p.value)
  diff_list <- c(diff_list,(chi_test$estimate[[1]]-chi_test$estimate[[2]])*100)
}

comp_sisrs_pool$Solo_ChiSquare <- chi_list
comp_sisrs_pool$Solo_P.Value <- p_list
comp_sisrs_pool$Solo_Rel.Diff <- diff_list

comp_sisrs_pool <- comp_sisrs_pool %>%
  arrange(desc(Solo_ChiSquare)) %>%
  mutate(Solo_BF_Sig = ifelse(Solo_P.Value < (0.05/nrow(comp_sisrs_pool)),"BF_Sig","Not_Sig")) %>%
  select(-Filtered_Out) %>%
  left_join(comp_sisrs_letters,by="Annotation")

##### COMPARE GOOD VERSUS BAD AMONG ANNOTATION TYPES BROADLY #####

sisrs_conc_pool <- anno_breakdown %>%
  select(Annotation,Concordant,SISRS) %>%
  mutate(Concordant_Percent = Concordant/SISRS*100) %>%
  mutate(Discordant = SISRS - Concordant) %>%
  arrange(Annotation)

sisrs_conc_matrix <- cbind(sisrs_conc_pool$Concordant,sisrs_conc_pool$Discordant)
rownames(sisrs_conc_matrix) <- sisrs_conc_pool$Annotation
colnames(sisrs_conc_matrix) <- c('Concordant','Discordant')
sisrs_conc_letters <- statLetter(sisrs_conc_matrix)

chi_list <- c()
p_list <- c()
diff_list <- c()

for(anno in sisrs_conc_pool$Annotation){
  in_data <- sisrs_conc_pool %>% filter(Annotation == anno) %>% select(Concordant,Discordant) %>% colSums()
  out_data <- sisrs_conc_pool %>% filter(Annotation != anno) %>% select(Concordant,Discordant) %>% colSums()
  test_matrix <- rbind(in_data,out_data)
  row.names(test_matrix) <- c(anno,'Other')
  chi_test <- prop.test(test_matrix)
  chi_list <- c(chi_list,chi_test$statistic)
  p_list <- c(p_list,chi_test$p.value)
  diff_list <- c(diff_list,(chi_test$estimate[[1]]-chi_test$estimate[[2]])*100)
}

sisrs_conc_pool$Solo_ChiSquare <- chi_list
sisrs_conc_pool$Solo_P.Value <- p_list
sisrs_conc_pool$Solo_Rel.Diff <- diff_list

sisrs_conc_pool <- sisrs_conc_pool %>%
  arrange(desc(Solo_ChiSquare)) %>%
  mutate(Solo_BF_Sig = ifelse(Solo_P.Value < (0.05/nrow(sisrs_conc_pool)),"BF_Sig","Not_Sig")) %>%
  select(-Discordant) %>%
  left_join(sisrs_conc_letters,by="Annotation")

dataset_median <- median(sisrs_conc_pool$Concordant_Percent)
min_ratio = min(sisrs_conc_pool$Concordant_Percent)
max_ratio = max(sisrs_conc_pool$Concordant_Percent)

names(ref_comp_pool) <- c('Annotation','Positive','Total','Percent','Solo_Chi','Solo_P','Solo_Diff','Solo_Sig','StatGroup')
ref_comp_pool$Test <- 'Assembly'

names(comp_sisrs_pool) <- c('Annotation','Positive','Total','Percent','Solo_Chi','Solo_P','Solo_Diff','Solo_Sig','StatGroup')
comp_sisrs_pool$Test <- 'SISRS'

names(sisrs_conc_pool) <- c('Annotation','Positive','Total','Percent','Solo_Chi','Solo_P','Solo_Diff','Solo_Sig','StatGroup')
sisrs_conc_pool$Test <- 'Concordance'

all_data <- rbind(ref_comp_pool,comp_sisrs_pool,sisrs_conc_pool)

all_data$Dataset <- dataset
write_tsv(all_data,out_file)
