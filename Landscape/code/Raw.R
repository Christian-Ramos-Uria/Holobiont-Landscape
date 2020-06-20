##### Tax4Fun to Landscape #####

# Delete other objects from memory
rm(list = ls())

# Load packages
library(R.utils)
library(data.table)

# Directory with raw sequences
dir.raw <- "../Raw/Human_Raw/PRJEB14529/"
# Directory to extract files to
out.dir <- "../Raw/Human_Raw/Analysis/"

if (!dir.exists(out.dir)) {
  dir.create(out.dir)
}

# All Fastq files
#files <- list.files(path = dir.raw, pattern = "fastq.gz", recursive = TRUE)

# Read metadata
meta <- fread("../data/human/SraRunTable.txt")
# Keep only childs
keep <- meta[mom_child == "C", .(sample)]
# fastq files
keep[, toKeep := paste(dir.raw, sample, "/", sample, ".fastq.gz", sep = "")]
# Save fastq files here
keep[, toSave := paste(out.dir, sample, ".fastq", sep = "")]
#head(keep)

# Extract 
#setwd("C:/Users/Chris/OneDrive - WageningenUR/Thesis microbiota/Empirical")
#files <- list.files(pattern = "fastq", recursive = TRUE)
#files
#help(":=")

mapply(FUN = gunzip, filename = keep[, toKeep], destname = keep[, toSave], remove = FALSE)