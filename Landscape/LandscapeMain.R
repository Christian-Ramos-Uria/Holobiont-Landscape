##### Landscape Paper #####

# Install dependencies


# Repository root directory
#setwd("/home/WUR/ramos011/Thesis/Landscape/")

# from the repository root directory:
setwd("code-human/")

# Uncompress raw fastq files, download the files before running
print("Raw")
source("Raw.R") # Human
source("Raw-plant.R") # Plant

# Get OTU tables using the Dada2 pipeline
print("Dada2")
source("Dada2.R") # Process raw data
source("Dada2-mosquito.R") # Mosquito
source("Dada2-plant.R") # Plant

# Get functional composition from the OTU tables using Tax4Fun2, specify the (Tax4Fun2) repository folder in each script before running.
print("Tax4Fun2")
source("Tax4Fun2.R") # Human1
source("Tax4Fun2-mosquito.R") # Mosquito
source("Tax4Fun2-plant.R") # Plant

# Save the functional predictions in the corresponding folder and format
print("Tax4Fun2Landscape and Mgnify2Landscape")
source("Tax4Fun2Landscape.R") # Human1
source("Tax4Fun2Landscape-mosquito.R") # Mosquito
source("Tax4Fun2Landscape-plant.R") # Plant
source("Mgnify2Landscape.R") # Save the GO predictions and metadata in the correct format

# Jensen Shannon divergence
print("make-jsds")
source("make-jsds-human.R") # Human1
source("make-jsds-human2.R") # Human2 (GO)
source("make-jsds-mosquito.R") # Mosquito
source("make-jsds-plant.R") # Plant

# Make Mapper networks
print("make-mapper-graphs")
source("make-mapper-graphs-human.R") # Human1
source("make-mapper-graphs-human2.R") # Human2
source("make-mapper-graphs-mosquito.R") # Mosquito
source("make-mapper-graphs-plant.R") # Plant

# Make figures for publication
print("Figure")
source("fig_humanF.R") # Human1
source("fig_human2F.R") # Human2
source("fig_mosquito.R") # Plant and Mosquito