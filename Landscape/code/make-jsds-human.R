#### JSdivergence ####
# setup -------------------------------------------------------------------


library(data.table)
library(philentropy)
library(tidyverse)

scripts.dir <- "./"
data.dir <- "../data/"
out.dir <- "jsds/"
if (!dir.exists(out.dir)) {
  dir.create(out.dir)
}


# cholera ---------------------------------------------------------------

source(paste0(scripts.dir, "load_human.R"))

human[, freq := count / sum(count), by = sample]
#human.samples <- unique(human[, .(sample, subject, diagnosis, id, hour)])
#human.samples[, idx := frank(hour), by = subject]
distribs <- dcast(human, sample ~ fun, value.var = "freq", fill = 0)
sample.names <- distribs$sample
distribs <- as.matrix(distribs[, -1])

# compute js distance
jsd <- JSD(distribs)
rownames(jsd) <- sample.names
colnames(jsd) <- sample.names
jsd <- melt(jsd, varnames = c("sample.x", "sample.y"),
            value.name = "jsd")

fwrite(jsd, paste0(out.dir, "/human.txt"), sep = "\t")


