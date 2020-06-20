
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
source("load_human.R")
human.mapper <- read.mapper.graph(paste0(output.dir, "human"))
human.v2p <- merge.mpr.samples(human.mapper, human.samples)
# lay out Mapper graph without singletons
plotter <- function(v) {
  plot.mapper.graph(human.mapper$graph,
                    node = geom_node_point(aes_(size = ~size, fill = v),
                                           shape = 21),
                    seed = 1,
                    exclude.singletons = TRUE) +
    guides(size = FALSE) +
    coord_equal()
}
basin.palette <- "Set3"
na.color <- "grey50"

# fraction Vaginal -------------------------------------------------------

plotter(~f.state) +
  scale_fill_distiller(palette = "Spectral") +
  labs(fill = "fraction\nVaginal")
fstate <- last_plot()

# basins ------------------------------------------------------------------

plotter(~as.factor(basin)) +
  scale_fill_brewer(palette = basin.palette, na.value = na.color)
basin <- last_plot()

# basin time series Vaginal -------------------------------------------------------

theme_set(theme_cowplot())
p2basin <- human.v2p[, .N, by = .(subject, delivery, id, month, basin)]
p2basin[, time := month]
p2basin[, time.unit := "month"]
p2basin[, i := rank(basin), by = .(subject, id)]
p2basin[, basin := as.factor(basin)]
theme_set(theme_cowplot(font_size = 10))
setkey(p2basin, delivery)
p2basin["Vaginal"] %>%
  ggplot(aes(x = time, y = basin)) +
  geom_tile(aes(fill = basin)) +
  facet_grid(subject ~ ., scales = "free_y", switch = "y") +
  theme(axis.ticks.y = element_blank(), panel.spacing = unit(1, "points"), legend.position = "none") +
  labs(x = "month", fill = "basin") +
  scale_fill_brewer(palette = basin.palette, na.value = na.color,
                    drop = FALSE) +
  theme(axis.text.y = element_blank(),
        axis.title.y = element_blank(), strip.placement = "outside")
basin.series.V <- last_plot()

# basin time series Cesarean -------------------------------------------------------

theme_set(theme_cowplot())
p2basin <- human.v2p[, .N, by = .(subject, delivery, id, month, basin)]
p2basin[, time := month]
p2basin[, time.unit := "month"]
p2basin[, i := rank(basin), by = .(subject, id)]
p2basin[, basin := as.factor(basin)]
theme_set(theme_cowplot(font_size = 10))
setkey(p2basin, delivery)
p2basin["Cesarean"] %>%
  ggplot(aes(x = time, y = basin)) +
  geom_tile(aes(fill = basin)) +
  facet_grid(subject ~ ., scales = "free_y", switch = "y") +
  theme(axis.ticks.y = element_blank(), panel.spacing = unit(1, "points"), legend.position = "none") +
  labs(x = "month", fill = "basin") +
  scale_fill_brewer(palette = basin.palette, na.value = na.color,
                    drop = FALSE) +
  theme(axis.text.y = element_blank(),
        axis.title.y = element_blank(), strip.placement = "outside")
basin.series.C <- last_plot()

# combined figure ---------------------------------------------------------

plot_grid(plot_grid(fstate, basin, labels = "AUTO", align = "h", nrow = 1),
          plot_grid(basin.series.V, basin.series.C, labels = c("C", "D"), vjust = 0.3, nrow = 1),
          rel_heights = c(1, 2),
          #label_y = c(1, 1.5),
          ncol = 1)
save_plot(last_plot(), filename = paste0(figs.dir, "/fighF.png"),
          ncol = 1, base_width = 8, base_height = 8)
