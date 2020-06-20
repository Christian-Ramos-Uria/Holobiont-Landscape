##### Tax4Fun to Landscape #####

# Delete other objects from memory
rm(list = ls())

# Set working directory
input <- "../dada2/human/Temp/"
out.dir <- "../data/human/"

if (!dir.exists(out.dir)) {
  dir.create(out.dir)
}

# Install packages

# Load packages
library(igraph)

#### Load and transform function dataframe ####
# Load dataframe
d <- read.csv(paste0(input, "functional_prediction.txt"), sep = "\t")
des <- data.frame(d$description)
row.names(d) <- rownames(des) <- d$KO
d$KO <- d$description <- NULL
head(d)

# Transform to pairwise list
d <- data.matrix(d)
#str(d)
g <- graph_from_incidence_matrix(d, weighted = TRUE)
d <- get.edgelist(g)
d <- as.data.frame(d)
d$Weight <- edge_attr(g, "weight")

# Save dataframe
write.table(d, paste0(out.dir, "Human_function.txt"), sep="\t",  col.names = FALSE, row.names = FALSE)

#### Metadata ####
# Load dataframe
#m <- read.csv("SraRunTable.txt", sep = ",")
#head(m)
#str(m)
#colnames(m)
# Columns to keep:
# Run, Description, diet_2_month, mom_child, mom_ld_abx, mom_prenatal_abx, sample_name, sample_summary, sample_type, Day_of_life,
# delivery, month or month_of_life, sex, 
#m$diet_3
