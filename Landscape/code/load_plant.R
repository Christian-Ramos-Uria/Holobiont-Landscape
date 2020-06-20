library(data.table)
library(stringr)

data.dir <- "../data/"
plant <- fread(paste0(data.dir, "plant/Plant_function.txt"),
                col.names = c("fun", "sample", "count"))

plant[, sample := str_replace(sample, "\\.", "-")]

# Get sample info
meta <- fread(paste0(data.dir, "plant/SraRunTable.txt"))
#head(meta)

meta2 <- fread(paste0(data.dir, "plant/plants.csv"))
#head(meta2)

# Make IDs compatible
meta[,Alias := str_remove_all(Alias, "_")]
# Map between meta2 and meta
m.alias <- match(meta[,Alias], meta2[,sample_name])
#length(is.na(m.alias))

meta[,"type" := meta2[m.alias,type_sample]]
meta[,"generation" := meta2[m.alias,ramet_position]]
meta[,"genotype" := meta2[m.alias,genotype]]

# Complete metadata
plant.samples <- meta[Description != "sham", .(Run, Alias, genotype, type, generation)]
plant.samples[, generation := match(generation, LETTERS)]
plant.samples[, generation := as.numeric(generation)]
colnames(plant.samples) <- c("sample", "id", "genotype", "type", "generation")
#head(plant.samples)

plant.samples <- plant.samples[!is.na(genotype),]

plant <- plant[sample %in% plant.samples[,sample],]