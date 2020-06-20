##### Tax4Fun to Landscape #####

# Delete other objects from memory
rm(list = ls())

# Set working directory
input <- "../data/human2/"
out.dir <- "../data/human2/"

if (!dir.exists(out.dir)) {
  dir.create(out.dir)
}

# Install packages

# Load packages
library(igraph)

#### Load and transform functions dataframe ####
# Load dataframe
d <- read.csv(paste0(input, "ERP108956_GO_abundances_v4.1.tsv"), sep = "\t")
des <- data.frame(d$description)
row.names(d) <- rownames(des) <- d$GO
d$GO <- d$description <- d$category <- NULL
head(d)

# Transform to pairwise list
d <- data.matrix(d)
#str(d)
g <- graph_from_incidence_matrix(d, weighted = TRUE)
d <- get.edgelist(g)
d <- as.data.frame(d)
d$Weight <- edge_attr(g, "weight")

# Save dataframe
write.table(d, paste0(out.dir, "Human2_function.txt"), sep="\t",  col.names = FALSE, row.names = FALSE)

#### Metadata ####
## SRA sample metadata ##
SRA <- read.csv(paste0(input, "SraRunTable.txt"), sep = ",")
#str(SRA)
#head(SRA)

## DIABIMMUNE subject metadata ##
load(paste0(input, "DIABIMMUNE_Karelia_metadata.RData"))
#head(metadata)
#metadata$subjectID

# Get keys
key.delivery <- unique(metadata[c("subjectID", "delivery")])

## Run accession to sample accession ##
r2s <- read.csv(paste0(input, "filereport_analysis_PRJEB26925_tsv.txt"), sep = "\t")
#head(r2s)
#dim(r2s)
#length(unique(r2s$sample_accession))
#length(unique(r2s$analysis_accession))

# Get keys
key.r2s <- unique(r2s[c("sample_accession", "analysis_accession")])

## Complete metadata file ##
d <- SRA[c("BioSample", "Host_Age", "host_subject_ID")]
#head(d)

# Add delivery variable
d$delivery <- key.delivery$delivery[match(d$host_subject_ID, key.delivery$subjectID)]

# Add Run accession
d$Run <- key.r2s$analysis_accession[match(d$BioSample, key.r2s$sample_accession)]

# Trmsform age to months
d$month <- d$Host_Age/30
#head(d)

# Save metadata dataframe
write.table(d, paste0(out.dir, "Human2_metadata.txt"), sep="\t",  col.names = TRUE, row.names = FALSE)
#write.table(d, "Human2_metadata.txt", sep="\t",  col.names = TRUE, row.names = FALSE)

