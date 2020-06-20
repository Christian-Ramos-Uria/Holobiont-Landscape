##### Idea1, Test #####
# Delete other objects from memory
rm(list = ls())

# Directory with csv files
dir <- "./CSVfiles/"

# Load libraries
library(ggplot2)
#library(car)
library(MuMIn)

# Read csv
d <- read.csv(paste0(dir, "Analysis1-lm.csv"), sep = ",", dec = ".")
#d <- read.csv("Analysis1-3.csv", sep = ",", dec = ".")
#str(d)
#head(d)

### Exploratory analysis
## Plot histograms
# Beta diversity

# 1. Open jpeg file
png("Morisita.png")
# 2. Create the plot

ggplot(data = d, aes()) +
  geom_histogram(aes(x = b.div), bins = 30) +
  facet_grid(con ~ fix) +
  labs(x = "Morisita Index", y = "Counts") +
  theme_bw() +
  theme(axis.title.x = element_text(size = 20), axis.title.y = element_text(size = 20),
        strip.text.x = element_text(size = 15), strip.text.y = element_text(size = 15))

# 3. Close the file
dev.off()

# Log Beta diversity
ggplot(data = d, aes()) +
  geom_histogram(aes(x = logb), bins = 30) +
  facet_grid(con ~ fix) +
  labs(x = "Morisita Index", y = "Counts") +
  theme_bw() +
  theme(axis.title.x = element_text(size = 20), axis.title.y = element_text(size = 20),
        strip.text.x = element_text(size = 15), strip.text.y = element_text(size = 15))

#### glm test ####
# Normal distribution, Linear link
m1 <- glm(data = d, b.div ~ con*fix, family = gaussian(link="identity"))
par(mfrow=c(1,2))
plot(m1, which=c(1,2)) # Non normal residuals
summary(m1)

# AICc
#options(na.action = "na.fail")
#m1.parc <- dredge(m1)
#m1.parc

# Gamma inverse
m2 <- glm(data = d, b.div ~ con*fix, family = Gamma(link="inverse"))
disp <- deviance(m2)/df.residual(m2); disp
plot(m2, which=c(1,2))
summary(m2)

# AICc
options(na.action = "na.fail")
m2.parc <- dredge(m2)
m2.parc

# Likelihood ratio test
m2.1 <- glm(data = d, b.div ~ con, family = Gamma(link="inverse"))
m2.2 <- glm(data = d, b.div ~ con + fix + con*fix, family = Gamma(link="inverse"))
anova(m2.1, m2.2, test = "LRT")

