library(data.table)

data.dir <- "../data/"
human <- fread(paste0(data.dir, "human/Human_function.txt"),
                col.names = c("fun", "sample", "count"))


# Get sample info
meta <- fread(paste0(data.dir, "human/SraRunTable.txt"))
#head(meta)
# Useful variables
#host_subject_ID #host
#delivery # Diagnosis
#month # hour
# diet
# mom_child

human.samples <- meta[mom_child == "C", .(Run, Run, host_subject_ID, delivery, month)]
human.samples[, month := as.numeric(month)]
colnames(human.samples) <- c("sample", "id", "subject", "delivery", "month")
#head(human.samples)

# Add sample info to main dataset
#human[, "subject" := ]
#?match()
