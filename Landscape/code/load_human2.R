library(data.table)

data.dir <- "../data/"
human <- fread(paste0(data.dir, "human2/Human2_function.txt"),
                col.names = c("fun", "sample", "count"))


# Get sample info
meta <- fread(paste0(data.dir, "human2/Human2_metadata.txt"))
#head(meta)

human.samples <- meta[, .(Run, Run, host_subject_ID, delivery, month)]
human.samples[, month := round(as.numeric(month), digits = 0)]
colnames(human.samples) <- c("sample", "id", "subject", "delivery", "month")
#head(human.samples)

# Add sample info to main dataset
#human[, "subject" := ]
#?match()
