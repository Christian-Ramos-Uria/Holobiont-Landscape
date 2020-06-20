##### Tax4Fun to Landscape #####

# Delete other objects from memory
rm(list = ls())

# Set working directory
input <- "../dada2/plant/Temp/"
out.dir <- "../data/plant/"

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
write.table(d, paste0(out.dir, "Plant_function.txt"), sep="\t",  col.names = FALSE, row.names = FALSE)
