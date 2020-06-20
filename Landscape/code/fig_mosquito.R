
# setup -------------------------------------------------------------------


library(data.table)
library(tidyverse)
library(tidygraph)
library(ggraph)
library(igraph)
library(cowplot)

utils.dir <- "utils/"
output.dir <- "mapper-output/"
figs.dir <- "../figures/"
for (script in list.files(utils.dir, full.names = TRUE)) source(script)
source("load_mosquito.R")
source("load_plant.R")

#### Mosquito -------------------------------------------------------------

mosquito.mapper <- read.mapper.graph(paste0(output.dir, "mosquito"))
mosquito.v2p <- merge.mpr.samples(mosquito.mapper, mosquito.samples)
# lay out Mapper graph without singletons
plotter <- function(v) {
  plot.mapper.graph(mosquito.mapper$graph,
                    node = geom_node_point(aes_(size = ~size, fill = v),
                                           shape = 21),
                    seed = 1,
                    exclude.singletons = TRUE) +
    guides(size = FALSE) +
    coord_equal()
}
basin.palette <- "Set3"
na.color <- "grey50"

# fraction Field -------------------------------------------------------

plotter(~f.state) +
  scale_fill_distiller(palette = "Spectral") +
  labs(fill = "fraction\nField")
fstate.m <- last_plot()

# basins ------------------------------------------------------------------

plotter(~as.factor(basin)) +
  scale_fill_brewer(palette = basin.palette, na.value = na.color)
basin.m <- last_plot()

# basin time series -------------------------------------------------------

theme_set(theme_cowplot())
p2basin <- mosquito.v2p[, .N, by = .(replicate, treatment, id, generation, basin)]
p2basin[, time := generation]
p2basin[, time.unit := "generation"]
p2basin[, i := rank(basin), by = .(replicate, id)]
p2basin[, basin := as.factor(basin)]
theme_set(theme_cowplot(font_size = 10))
setkey(p2basin, treatment)
p2basin[,] %>%
  ggplot(aes(x = as.factor(time))) +
  geom_bar(aes(fill = basin)) +
  facet_grid(~ treatment) +
  #theme(axis.ticks.y = element_blank(), panel.spacing = unit(1, "points")) +
  labs(x = "generation", fill = "basin") +
  scale_fill_brewer(palette = basin.palette, na.value = na.color,
                    drop = FALSE) +
  theme(strip.placement = "outside")
basin.series.m <- last_plot()

#### Plant -------------------------------------------------------------

plant.mapper <- read.mapper.graph(paste0(output.dir, "plant"))
plant.v2p <- merge.mpr.samples(plant.mapper, plant.samples)
# lay out Mapper graph without singletons
plotter <- function(v) {
  plot.mapper.graph(plant.mapper$graph,
                    node = geom_node_point(aes_(size = ~size, fill = v),
                                           shape = 21),
                    seed = 1,
                    exclude.singletons = TRUE) +
    guides(size = FALSE) +
    coord_equal()
}
basin.palette <- "Set3"
na.color <- "grey50"

# fraction Root -------------------------------------------------------

plotter(~f.state) +
  scale_fill_distiller(palette = "Spectral") +
  labs(fill = "fraction\nRoot")
fstate.p <- last_plot()

# basins ------------------------------------------------------------------

plotter(~as.factor(basin)) +
  scale_fill_brewer(palette = basin.palette, na.value = na.color)
basin.p <- last_plot()

# basin time series -------------------------------------------------------

theme_set(theme_cowplot())
p2basin <- plant.v2p[, .N, by = .(genotype, type, id, generation, basin)]
p2basin[, time := generation]
p2basin[, time.unit := "generation"]
p2basin[, i := rank(basin), by = .(genotype, id)]
p2basin[, basin := as.factor(basin)]
theme_set(theme_cowplot(font_size = 10))
setkey(p2basin, type)
p2basin[,] %>%
  ggplot(aes(x = as.factor(time))) +
  geom_bar(aes(fill = basin)) +
  facet_grid(~ type) +
  #theme(axis.ticks.y = element_blank(), panel.spacing = unit(1, "points")) +
  labs(x = "generation", fill = "basin") +
  scale_fill_brewer(palette = basin.palette, na.value = na.color,
                    drop = FALSE) +
  theme(strip.placement = "outside")
basin.series.p <- last_plot()

# combined figure ---------------------------------------------------------
#pl <- plot_grid(plot_grid(fstate.p, basin.p, labels = "AUTO", nrow = 1, align = "hv"), basin.series.p, labels = c("", "C"), rel_widths = c(2, 1), nrow = 1, align = "none")
#mo <- plot_grid(plot_grid(fstate.m, basin.m, labels = c("D", "E"), nrow = 1, align = "hv"), basin.series.m, labels = c("", "F"), rel_widths = c(2, 1), nrow = 1, align = "none")

pl <- plot_grid(fstate.p, fstate.m, labels = "AUTO", nrow = 1, align = "h")
mo <- plot_grid(basin.p, basin.m, labels = c("C", "D"), nrow = 1, align = "h")
se <- plot_grid(basin.series.p, basin.series.m, labels = c("E", "F"), nrow = 1, align = "h")

plot_grid(pl, mo, se, rel_heights = c(1, 1, 1), ncol = 1)

#plot_grid(fstate.p, basin.p, basin.series.p, labels = "AUTO", nrow = 1, rel_widths = c(1, 1, 1))

save_plot(last_plot(), filename = paste0(figs.dir, "/figmp.png"),
          base_width = 9, base_height = 9)
