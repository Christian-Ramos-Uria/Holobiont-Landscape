##### Idea1, analysis #####
# Delete other objects from memory
rm(list = ls())

# Directory with csv files
dir <- "./CSVfiles/"

# Load libraries
library(ggplot2)
library(vegan) # ordination # anova
#library(car) # vif
#library(MuMIn) # dredge

# Load dataset
df <- read.csv(paste0(dir, "idea1.4.csv"), sep = ",")
df[1] <- NULL
head(df)
str(df)
qplot(data = df, connectance, fixed, geom = "point")
#### CA of a subset ####
### Subset of connectance and initial population
# Connectance = 0.01 or 0.1
c <- 0.01
# initial fixed population = 0, 50 or 100
fixed <- 0

#  Subset rows
d <- df[which(df$connectance==c & df$fixed == fixed),]

# Subset without independent variables
d <- d[c(-51,-52)]

### CA ###
ca <- cca(d)
#summary(ca)
#plot(ca)
#str(ca)
ca$CA$eig

## Plot
# Extract CA coordinates for sites
si <- data.frame(ca$CA$u[,1:3])
#str(si)
#head(si)

# Extract CA coordinates for species
sp <- data.frame(ca$CA$v[,1:3])
#str(sp)
#head(sp)

# Plot
ggplot() +
  geom_point(data = si, aes(CA1, CA2)) +
  #geom_text(data = sp, aes(CA1, CA2, label=row.names(sp))) +
  theme_classic()

#### Beta diversity ####
# Function to get the diversity for two communities
div <-  function(c1, c2){
  # Sample random members from each community
  c.1 <- c1/sum(c1)
  c.2 <- c2/sum(c2)
  # Compare if they belong to the same species
  p <- c.1*c.2
  return(sum(p))
}

# Function to get beta diversity for two communities
d.beta <- function(c1, c2){
  # Alfa diversity for each community
  d1 <- div(d[c1,], d[c1,])
  d2 <- div(d[c2,], d[c2,])
  # Pairwise diversity
  d12 <- div(d[c1,], d[c2,])
  # Return Morisita Horn Index
  return((2*d12)/(d1 + d2))
}

# Function to choose two communities (rows) given two independent variables
choose.c <- function(con, fix){
  # Find all rows with the exact combination of independent variables
  options <- which(df$connectance == con & df$fixed == fix)
  return(sample(options, 2, replace = FALSE))
}

# Subset without independent variables
d <- df[c(-51,-52)]

## Create dataframe to store beta diversities
replicas <- 1000
# Independent variables
con <- c(rep(0, replicas*3), rep(0.1, replicas*3), rep(0.01, replicas*3))
fix <- rep(c(rep(0, replicas), rep(100, replicas), rep(200, replicas)), 3)
# Rows
rows <- mapply(choose.c, con = con, fix = fix)
row1 <- rows[1,]
row2 <- rows[2,]

# Get beta diversity
b.div <- mapply(d.beta, row1, row2)

logb <- log(b.div)
# Wrap everything in a dataframe
results <- data.frame(con, fix, row1, row2, b.div, logb)
head(results)

write.csv(results, "Analysis1-3.csv")

#### Plots ####
# Histograms
ggplot(data = results, aes()) +
  geom_histogram(aes(x = logb), bins = 30) +
  facet_grid(con ~ fix) +
  theme_bw()

# Scatter plots
ggplot(data = results, aes(x = fix, y = b.div)) +
  geom_point(aes(colour  = con)) +
  theme_bw()

#### Datafrme for glm ####
## Create dataframe to store beta diversities
replicas <- 25*5
# Independent variables
con <- c(rep(0, replicas*3), rep(0.01, replicas*3), rep(0.1, replicas*3))
fix <- rep(c(rep(0, replicas), rep(100, replicas), rep(200, replicas)), 3)
# Alternative method
#df[seq(1,450,2), 52]
# Rows
row1 <- seq(1,2250,2)
row2 <- row1 + 1

# Get beta diversity
b.div <- mapply(d.beta, row1, row2)

logb <- log(b.div)
# Wrap everything in a dataframe
results <- data.frame(con, fix, row1, row2, b.div, logb)
head(results)

write.csv(results, paste0(dir, "Analysis1-lm.csv"))
