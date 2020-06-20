##### Tax4Fun to Landscape #####

# Delete other objects from memory
rm(list = ls())

# Load packages
library(R.utils)
library(data.table)

# Directory with raw sequences
dir.raw <- "../Raw/Plant_Raw/PRJEB20603/"
# Directory to extract files to
out.dir <- "../Raw/Plant_Raw/Analysis/"

if (!dir.exists(out.dir)) {
  dir.create(out.dir)
}

# All Fastq files
files <- list.files(path = dir.raw, pattern = "fastq.gz", recursive = TRUE)
#files

f.names <- unlist(strsplit(files, split = "/"))

# Names of unpacked files
toSave <- f.names[which(grepl(f.names, pattern = ".fastq.gz", fixed = TRUE))]
toSave <- sapply(FUN = substr, toSave, start = 1, stop = nchar(toSave)-3)
#head(toSave)

# Uncompress
mapply(FUN = gunzip, filename = paste0(dir.raw, files), destname = paste0(out.dir, toSave), remove = FALSE)