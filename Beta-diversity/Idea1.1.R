##### Thesis, idea 1 #####
# Delete other objects from memory
rm(list = ls())

# Directory with csv files
dir <- "./CSVfiles/"

# load pakages
library(seqtime)
library(dplyr)
source('mSOI.R') # modified SOI function
source('mHubbell.R') # modified Hubbell function


#### Wrap everything in a single function ####

# Run a generic SOI simulation
run <- function(N = 50, c = 0.05, I=500, f = 0, tend = 3000, replicas = 50){
  # Fixed initial population
  i.vector <- create.iv(f, N=N)
  
  if(c == 0){
    # Matrix to store results
    m <- matrix(nrow = N, ncol = replicas)
    # Species number in the metacommunity is the same as in the community
    M <- N
    
    # Run Hubbell
    for(i in 1:replicas){
      m[,i] <- msimHubbell(N=N, M=M, I=I, y=rep(1/N,N), m.vector=rep(1/M,M), i.vector = i.vector,m=0.02, d=10, tskip=0, tend=tend)[,tend]
      print(i)
    }
  } else{
    
    # Interaction matrix
    A <- generateA(N, c=c, d=-1)
    A <- modifyA(A,perc=70,strength="uniform", mode="negpercent")
    
    # Species abundance
    y <- round(generateAbundances(N,mode=5))
    names(y) <- c(1:length(y))
    
    # Matrix to store results
    m <- matrix(nrow = N, ncol = replicas)
    
    # Run SOI
    for(i in 1:replicas){
      m[,i] <- msoi(N=N, I=I, A=A, m.vector=y, i.vector = i.vector, tend=tend)[,tend]
      print(i)
    }
  }
  # Return composition at last tme step
  return(t(m))
}

# Create i.vector
create.iv <- function(len, N=50){
  if(len == 0){ return(NULL)}
  return(sample(1:N, len, replace = TRUE))
}

#### Multipe runs ####
replicas <- 250

# Parameters
c <- c(rep(0, 3), rep(0.01, 3), rep(0.1, 3))
i <- rep(c(0, 100, 200), 3)

# Parameters for dataframe
c.vector <- c(rep(0, 3*replicas), rep(0.01, 3*replicas), rep(0.1, 3*replicas))
i.fraction <- rep(c(rep(0, replicas), rep(100, replicas), rep(200, replicas)), 3)


# Results
r <- vector("list", 9)

for(p in 1:length(c)){
  r[[p]] <- run(c=c[p] , f=i[p], replicas = replicas)
}
#r[[2]]


# Bind all dataframes
df <- Reduce(function(x,y) rbind(x = x, y = y), r)
df <- as.data.frame(df)
df$connectance <- c.vector
df$fixed <- i.fraction
head(df)

## Write dataframe
write.csv(df, paste0(dir, "CSVfiles/idea1.4.csv"))