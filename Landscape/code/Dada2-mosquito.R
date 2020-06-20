##### Thesis, dada2 pipeline #####
# Delete other objects from memory
rm(list = ls())

# Update packages
#update.packages()
# Install BiocManager
#if (!requireNamespace("BiocManager", quietly = TRUE)){install.packages("BiocManager")}
# Install DADA2
#BiocManager::install("dada2")
# Install DADA2, only after dependencies have been installed
#devtools::install_github("benjjneb/dada2")
# Set working directory
#setwd("C:/Users/Chris/OneDrive - WageningenUR/Thesis microbiota/Empirical/Pipeline/")

# load pakages
library(dada2)
#help(package="dada2")

#### Pipeline ####
# CHANGE ME to the directory containing the fastq files after unzipping.
path <- "../Raw/Mosquito_Raw/"
#"C:/Users/Chris/OneDrive - WageningenUR/Thesis microbiota/Empirical/Pipeline" 
# Silva training set
silva <- "../dada2/silva_nr_v138_train_set.fa.gz"
#"C:/Users/Chris/OneDrive - WageningenUR/Thesis microbiota/Empirical/Pipeline/silva_nr_v138_train_set.fa.gz"

# File to save output to
out.dir <- "../dada2/mosquito/"

if (!dir.exists(out.dir)) {
  dir.create(out.dir)
}

list.files(path)

# Fastq filenames have format: .fastq
fnFs <- sort(list.files(path, pattern="_R1_001_tr.fastq", full.names = TRUE))
fnRs <- sort(list.files(path, pattern="_R2_001_tr.fastq", full.names = TRUE))
# Extract sample names, assuming filenames have format: SAMPLENAME_XXX.fastq
sample.names <- sapply(strsplit(basename(fnFs), "_"), `[`, 1)

# Visualizing the quality profiles of the reads
plotQualityProfile(fnFs[1:2])

# Place filtered files in filtered/ subdirectory
filtFs <- file.path(path, "filtered", paste0(sample.names, "_F_filt.fastq.gz"))
filtRs <- file.path(path, "filtered", paste0(sample.names, "_R_filt.fastq.gz"))
names(filtFs) <- sample.names
names(filtRs) <- sample.names

# Choose correct trunclen
out <- filterAndTrim(fnFs, filtFs, fnRs, filtRs, truncLen=c(250,200),
              maxN=0, maxEE=c(2,2), truncQ=2, rm.phix=TRUE,
              compress=TRUE, multithread=TRUE) # On Windows set multithread=FALSE
head(out)

# Learn Error Rates
errF <- learnErrors(filtFs, multithread=FALSE)
errR <- learnErrors(filtRs, multithread=FALSE)
# Check
plotErrors(errF, nominalQ=TRUE)

# Apply the core sample inference algorithm to the filtered and trimmed sequence data
dadaFs <- dada(filtFs, err=errF, multithread=FALSE)
dadaRs <- dada(filtRs, err=errR, multithread=FALSE)

# Inspecting the returned dada-class object
dadaFs[[1]]

# Merge paired reads
mergers <- mergePairs(dadaFs, filtFs, dadaRs, filtRs, verbose=TRUE)
# Inspect the merger data.frame from the first sample
head(mergers[[1]])

# Construct an amplicon sequence variant table (ASV) table
seqtab <- makeSequenceTable(mergers)
dim(seqtab)

# Inspect distribution of sequence lengths
table(nchar(getSequences(seqtab)))

# Find Chimeras
seqtab.nochim <- removeBimeraDenovo(seqtab, method="consensus", multithread=FALSE, verbose=TRUE)
dim(seqtab.nochim)

sum(seqtab.nochim)/sum(seqtab)

# Check 
getN <- function(x) sum(getUniques(x))
track <- cbind(out, sapply(dadaFs, getN), sapply(dadaRs, getN), sapply(mergers, getN), rowSums(seqtab.nochim))
# If processing a single sample, remove the sapply calls: e.g. replace sapply(dadaFs, getN) with getN(dadaFs)
colnames(track) <- c("input", "filtered", "denoisedF", "denoisedR", "merged", "nonchim")
rownames(track) <- sample.names
head(track)

# Assing Taxonomy
taxa <- assignTaxonomy(seqtab.nochim, silva, multithread=FALSE)

#str(seqtab.nochim)
#head(seqtab.nochim[1,])
#head(seqtab.nochim)
#dim(seqtab.nochim)
#colnames(seqtab.nochim)
#row.names(seqtab.nochim)

# Get the representative sequences:
rep.seqs <- colnames(seqtab.nochim)
seq.names <- paste(">Seq", 1:length(rep.seqs), sep = "")
toFasta <- c(rbind(seq.names, rep.seqs))

# Save as Fasta
Fas <- file(paste0(out.dir, "mosquito.fasta"))
writeLines(toFasta, Fas)
close(Fas)
getwd()

# OTU table
seq.names <- paste("Seq", 1:length(rep.seqs), sep = "")
colnames(seqtab.nochim) <- seq.names
OTUs <- t(seqtab.nochim[,])
write.table(data.frame("ID"=rownames(OTUs),OTUs),paste0(out.dir, "mosquito_OTUs.txt"), row.names=FALSE, sep = "\t")

# Import into phyloseq:
#otu.table <- otu_table(otu, taxa_are_rows = FALSE)