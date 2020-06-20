##### Tax4Fun2 functional analysis #####

# Setup
library(Tax4Fun2)
# OTU table and Fasta file directory
input <- "../dada2/plant/"
# Reference databases
Reference <- "/home/WUR/ramos011/R/Tax4FunDatabase/Tax4Fun2_ReferenceData_v2"
# Temporal output directory
Temp <- "../dada2/plant/Temp/"

# 1. Run the reference blast
runRefBlast(path_to_otus = paste0(input, "plant.fasta"), path_to_reference_data = Reference, path_to_temp_folder = Temp, database_mode = "Ref99NR", use_force = T, num_threads = 6)

# 2) Predicting functional profiles
makeFunctionalPrediction(path_to_otu_table = paste0(input, "plant_OTUs.txt"), path_to_reference_data = Reference, path_to_temp_folder = Temp, database_mode = "Ref99NR", normalize_by_copy_number = TRUE, min_identity_to_reference = 0.97, normalize_pathways = FALSE)

# Read results
#setwd('/home/WUR/ramos011/Thesis/Tax4FunToy/Temp')
# Functional predictions
#df <- read.csv("functional_prediction.txt", header = TRUE, sep = "	")
#str(df)