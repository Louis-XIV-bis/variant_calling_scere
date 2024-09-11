#!/usr/bin/env Rscript
## Université Paris-Saclay
## Lab : LISN ~ UMR9015 ~ BIOINFO team 

#R script to determine the threshold for filtering on each score 

###### Package initialization  ----------------------------------------

if (!require('ggplot2', quietly = T)) install.packages('tibble');
if (!require('tibble', quietly = T)) install.packages('tibble');
if (!require('tidyr', quietly = T)) install.packages('tidyr');
if (!require('dplyr', quietly = T)) install.packages('dplyr');
if (!require('grid', quietly = T)) install.packages('grid');
if (!require('gridExtra', quietly = T)) install.packages('gridExtra');
if (!require('ggVennDiagram', quietly = T)) install.packages('ggVennDiagram');

library(ggplot2)
library(tibble)
library(tidyr)
library(dplyr)
library(grid)
library(gridExtra)
library(ggVennDiagram)

########################################################################
###### Data upload and basic analyses ----------------------------------

rm(list=ls())

# Read the data and store it in a tibble
annotations <- read.table("../results/table_scores_merged.tsv", sep="\t", header=TRUE, na.strings=".") %>% 
  as_tibble()

head(annotations)

# Number of NA removed 
rows_before <- nrow(annotations)
annotations <- annotations %>%
  drop_na()
rows_after <- nrow(annotations)
cat("Number of rows before dropping NA:", rows_before, ", after: ", rows_after, "\nTotal removed: ", rows_before-rows_after)

# Group by CHROM and count the number of SNP for each group
rows_per_chrom <- annotations %>%
  group_by(CHROM) %>%
  summarize(n = n())
print(rows_per_chrom)

########################################################################
###### Filtration of the data based on defined thresholds --------------

# Chosen thresholds 
lim.QD = 2
lim.FS = 60
lim.MQ = 50
lim.MQRankSum = -10
lim_inf.ReadPosRankSum = -5.0
lim_sup.ReadPosRankSum = 5.0
lim.SOR = 2
lim.BaseQRankSum = -2

# Calculate the proportion of rows that did not pass each filter
proportions_pass <- annotations %>%
  summarize(
    pass_QD = round(mean(QD > lim.QD), 3),
    pass_FS = round(mean(FS < lim.FS), 3),
    pass_MQ = round(mean(MQ > lim.MQ), 3),
    pass_MQRankSum = round(mean(MQRankSum > lim.MQRankSum), 3),
    pass_ReadPosRankSum = round(mean(ReadPosRankSum > lim_inf.ReadPosRankSum & ReadPosRankSum < lim_sup.ReadPosRankSum), 3),
    pass_SOR = round(mean(SOR < lim.SOR), 3),
    pass_BaseQRankSum = round(mean(BaseQRankSum > lim.BaseQRankSum), 3)
  )
print(proportions_pass)

# Filter the data
filtered_data <- annotations %>%
  filter(
    QD > lim.QD,
    FS < lim.FS,
    MQ > lim.MQ,
    MQRankSum > lim.MQRankSum,
    ReadPosRankSum > lim_inf.ReadPosRankSum,
    ReadPosRankSum < lim_sup.ReadPosRankSum,
    SOR < lim.SOR, 
    BaseQRankSum > lim.BaseQRankSum
  )
filtered_data
cat("Number of rows before filtering:", rows_after, ", after: ", nrow(filtered_data), "\nTotal removed: ", rows_before-nrow(filtered_data))

###### QUAL distribution -----------------------------------------------

max(filtered_data$QUAL)
QUAL = filtered_data %>%
  filter(QUAL < 50000) %>% 
  ggplot(aes(x = QUAL)) +
  geom_histogram(fill = "skyblue", color = "black") +
  labs(title = "Distribution of QUAL values (filtered < 50000)", x = "QUAL", y = "Frequency") 
ggsave("QUAL_distrib.png", plot = QUAL)

###### Filters scores distribution --------------------------------------
QD_plot <- ggplot(annotations, aes(x = QD)) +
  geom_density(fill = "lightblue") +
  geom_vline(xintercept = lim.QD, color = "red") +
  ggtitle(paste0("QD > ", lim.QD, ", pass: ", proportions_pass$pass_QD)) +
  theme_minimal() +  # Set the minimal theme first
  theme(
    plot.title = element_text(size = 20, hjust = 0.5, face = "bold")  
  )
QD_plot

FS_plot <- ggplot(annotations, aes(x = FS)) +
  geom_density(fill = "lightblue") +
  geom_vline(xintercept = lim.FS, color = "red") +
  ggtitle(paste0("FS < ", lim.FS,  ", pass: ", proportions_pass$pass_FS)) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 20, hjust = 0.5, face = "bold")  
  )
FS_plot

MQ_plot <- ggplot(annotations, aes(x = MQ)) +
  geom_density(fill = "lightblue") +
  geom_vline(xintercept = lim.MQ, color = "red") +
  ggtitle(paste0("MQ > ", lim.MQ,  ", pass: ", proportions_pass$pass_MQ)) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 20, hjust = 0.5, face = "bold")  
  )
MQ_plot

MQRS_plot <- ggplot(annotations, aes(x = MQRankSum)) +
  geom_density(fill = "lightblue") +
  geom_vline(xintercept = lim.MQRankSum, color = "red") +
  ggtitle(paste0("MQRankSum > ", lim.MQRankSum,  ", pass: ", proportions_pass$pass_MQRankSum)) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 20, hjust = 0.5, face = "bold")  
  )
MQRS_plot

ReadPosRankSum_plot <- ggplot(annotations, aes(x = ReadPosRankSum)) +
  geom_density(fill = "lightblue") +
  geom_vline(xintercept = lim_inf.ReadPosRankSum, color = "red") +
  geom_vline(xintercept = lim_sup.ReadPosRankSum, color = "red") +
  ggtitle(paste0("ReadPosRankSum in range: ", lim_inf.ReadPosRankSum, " to ", lim_sup.ReadPosRankSum, ", pass: ", proportions_pass$pass_ReadPosRankSum)) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 20, hjust = 0.5, face = "bold")  
  )
ReadPosRankSum_plot

SOR_plot <- ggplot(annotations, aes(x = SOR)) +
  geom_density(fill = "lightblue") +
  geom_vline(xintercept = lim.SOR, color = "red") +
  ggtitle(paste0("SOR < ", lim.SOR, ", pass: ", proportions_pass$pass_SOR)) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 20, hjust = 0.5, face = "bold")  
  )
SOR_plot

BaseQRankSum_plot <- ggplot(annotations, aes(x = BaseQRankSum)) +
  geom_density(fill = "lightblue") +
  geom_vline(xintercept = lim.BaseQRankSum, color = "red") +
  ggtitle(paste0("BaseQRankSum > ", lim.BaseQRankSum, ", pass: ", proportions_pass$pass_BaseQRankSum)) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 20, hjust = 0.5, face = "bold")  
  )
BaseQRankSum_plot

text_grob <- textGrob(
  paste0("Raw dataset: ", rows_before, " SNP                                        \n", 
         "After removing sites w/ NA: ", rows_after, " SNP               \n", 
         "After filtration w/ shown thresholds: ", nrow(filtered_data), " SNP"), 
  gp = gpar(fontsize = 15, fontface = "bold", col = "black"))
# Left justification didn't work properly so I wame up with theses spaces

combined_plot <- arrangeGrob(
  QD_plot, FS_plot, MQ_plot, MQRS_plot, ReadPosRankSum_plot,
  SOR_plot, BaseQRankSum_plot, text_grob,
  ncol = 2,
  layout_matrix = rbind(
    c(1, 2),
    c(3, 4),
    c(5, 6),
    c(7, 8)  # Ensure the text is in the 8th cell
  )
)
ggsave("FiltersDistrib.png", plot = combined_plot, width = 10, height = 13, units = "in")

###### Venn diagram for all filtered SNP per score-------------------------

# Create a list for each filtered each per score : keep only the filtered position to compare
param_list <- list(
  QD = which(annotations$QD < lim.QD),
  MQ = which(annotations$MQ < lim.MQ),
  SOR = which(annotations$SOR > lim.SOR),
  MQRS = which(annotations$MQRankSum < lim.MQRankSum),
  ReadPosRS = which(annotations$ReadPosRankSum < lim_inf.ReadPosRankSum | annotations$ReadPosRankSum > lim_sup.ReadPosRankSum),
  FS = which(annotations$FS > lim.FS),
  BaseQRS =  which(annotations$BaseQRankSum < lim.BaseQRankSum)
)

venn = ggVennDiagram(param_list, label_alpha = 0) + 
  scale_fill_distiller(palette = "Reds", direction = 1) + 
  labs(title = "Venn diagram of the filtered SNP for each filter")
venn
ggsave("venn_filters.png", plot = venn, width = 15, height = 13)
