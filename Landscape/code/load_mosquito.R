library(data.table)
library(stringr)

data.dir <- "../data/"
mosquito <- fread(paste0(data.dir, "mosquito/Mosquito_function.txt"),
                col.names = c("fun", "sample", "count"))

mosquito[, sample := str_replace(sample, "\\.", "-")]

# Get sample info
meta <- fread(paste0(data.dir, "mosquito/mosquito.csv"))
#head(meta)

meta[, c("treatment", "generation") := tstrsplit(Description, "_")]

mosquito.samples <- meta[Description != "sham", .(SampleID, SampleID, Replicate, treatment, generation)]
mosquito.samples[, generation := as.numeric(str_replace(generation, "F", ""))]
colnames(mosquito.samples) <- c("sample", "id", "replicate", "treatment", "generation")
#head(mosquito.samples)

mosquito <- mosquito[sample !="C5" & sample !="C6" & sample !="K4",]