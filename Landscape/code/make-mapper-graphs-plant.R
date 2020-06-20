# setup -------------------------------------------------------------------

library(data.table)
library(tidyverse)
library(TDAmapper)
library(ggraph)
library(igraph)
library(tidygraph)
library(cowplot)

# validation parameters
nrep <- 10             # number of replicates
rs <- c(0.9, 0.5, 0.1) # downsampling ratios

jsd.dir <- "jsds/"
figs.dir <- "../figures/"
output.dir <- "mapper-output/"
for (d in c(figs.dir, output.dir)) {
  if (!dir.exists(d)) dir.create(d, recursive = TRUE)
}
data.dir <- "../data/"
utils.dir <- "utils/"
for (script in list.files(utils.dir, full.names = TRUE)) source(script)

#' Construct function to call Mapper2D and map vertices to original data points
#'
#' @param ni      number intervals
#' @param po      percent overlap
#' @param vfn     optional, function for aggregating per-vertex data
#'
#' @return list, [1] Mapper graph [2] vertex-point map
#' @export
#'
#' @examples
mapper2.call <- function(ni, po, vfn = NULL) {
  function(dist, samples, ftr) {
    mpr <- mapper2D(dist, filter_values = ftr, num_intervals = ni,
                    percent_overlap = po)
    v2p <- vertex.2.points(mpr$points_in_vertex)
    v2p <- merge(v2p, samples, by.x = "point.name", by.y = "sample")
    v2p[, frac := 1 / .N, by = point]
    graf <- mapper.2.igraph(mpr) %>%
      as_tbl_graph
    graf <- graf %>%
      mutate(membership = components(.)$membership) %>%
      mutate(in.singleton = in.singleton(v2p$point.name, v2p$vertex, membership))
    if (!is.null(vfn)) {
      vertices <- do.call(vfn, list(map = v2p))
      setorder(vertices, vertex)
      # browser()
      graf <- graf %>%
        activate(nodes) %>%
        left_join(vertices, by = c("name" = "vertex.name"))
    }
    list(graph = graf, map = v2p)
  }
}

#' Random subset of distance matrix and data
#'
#' @param dist distance matrix
#' @param dt   original data
#' @param r    fraction to sample
#'
#' @return list, [1] reduced distance matrix [2] reduced data
#' @export
#'
#' @examples
subsample <- function(dist, dt, r = 0.9) {
  n <- nrow(dist)
  size <- round(n * r)
  idx <- sample.int(n, size)
  dist <- dist[idx, idx]
  samps <- rownames(dist)
  setkey(dt, sample)
  dt <- dt[samps]
  list(dist = dist, data = dt)
}

#' Validate Mapper representation by subsampling by given ratios some number of
#' times
#'
#' @param dist  original distance matrix
#' @param dt    original sample data
#' @param fn    function to wrap Mapper
#' @param rs    vector of downsampling coefficients
#' @param nrep  number of replicates per coefficient
#'
#' @return list of list of Mapper representations and vertex-sample maps
#' @export
#'
#' @examples
validate <- function(dist, dt, fn, rs, nrep) {
  lapply(rs, function(r, nrep, dist, dt, fn) {
    lapply(seq_len(nrep), function(i, r, dist, dt, fn) {
      subsamp <- subsample(dist, dt, r)
      mds <- cmdscale(subsamp$dist)
      rk.mds <- apply(mds, 2, rank)
      do.call(fn, list(dist = subsamp$dist,
                       samples = subsamp$data,
                       ftr = list(rk.mds[,1], rk.mds[,2])))
    }, r, dist, dt, fn)
  }, nrep, dist, dt, fn)
}

#' Generate a function to plot a Mapper graph as a line or circle
#'
#' @param vatt      The vertex attribute by which to color the vertices
#' @param circular  Whether to plot in a circle
#'
#' @return a function
#' @export
#'
#' @examples
plot.mapper.linear <- function(vatt, circular = TRUE) {
  if (circular) {
    ej <- geom_edge_density(fill = "black")
  } else {
    ej <- geom_edge_arc0(width = 0.1)
  }
  function(graf) {
    plot.mapper.graph(graf,
                      node = geom_node_point(aes_string(color = vatt),
                                             size = 0.2),
                      edge = ej,
                      layout = "linear", circular = circular, sort.by = vatt)
  }
}

#' Plot downsampled Mapper graphs in a grid
#'
#' @param subsets  list of lists of downsampled Mappers
#' @param fn       function used for plotting each downsampled Mapper
#'
#' @return
#' @export         list of ggplot objects
#'
#' @examples
batch.plot <- function(subsets, fn) {
  pl <- lapply(subsets, function(l) {
    plots <- lapply(l, function(mpr) {
      fn(mpr$graph)
    })
    # get legend
    legend <- get_legend(plots[[1]])
    # delete legends and "subplotify"
    plots <- lapply(plots, function(p) {
      p +  theme(legend.position = "None",
                 plot.margin = unit(c(10, 10, 10, 10), "points"))
    })
    viz <- plot_grid(plotlist = plots, nrow = 2)
    plot_grid(viz, legend, ncol = 2, rel_widths = c(8, 1))
  })
}

#' Write the Mapper graph and vertex data to files
#'
#' @param tbl_graph  a `tbl_graph` representing a Mapper graph
#' @param v2p        a `data.frame` representing vertex attributes
#' @param directory  target directory
#'
#' @return
#' @export
#'
#' @examples
write.graph <- function(tbl_graph, v2p, directory) {
  if (!dir.exists(directory)) {
    dir.create(directory, recursive = TRUE)
  }
  tbl_graph %>%
    activate(nodes) %>%
    as.data.table %>%
    fwrite(paste0(directory, "vertices.txt"), sep = "\t", na = "NA")
  tbl_graph %>%
    activate(edges) %>%
    as.data.table %>%
    fwrite(paste0(directory, "edges.txt"), sep = "\t", na = "NA")
  names(v2p) <- c("point", "vertex")
  fwrite(v2p, paste0(directory, "/vertices-to-points.txt"), sep = "\t")
}

#' Print the grid plot of downsampled Mapper graphs to file
#'
#' @param fn
#' @param plt
#'
#' @return
#' @export
#'
#' @examples
write.validation.plot <- function(fn, plt) {
  save_plot(fn, plt, ncol = 1, base_width = 8, base_height = 6)
}

# plant -----------------------------------------------------------------

source("load_plant.R")

plant[, freq := count / sum(count), by = sample]

plant.samples[, idx := frank(generation), by = genotype]
plant.samples[, progression := idx / max(idx), by = genotype]
distribs <- dcast(plant, sample ~ fun, value.var = "freq", fill = 0)
sample.names <- distribs$sample
distribs <- as.matrix(distribs[, -1])

# import js distance
jsd.file <- paste0(jsd.dir, "nabs.txt")
if (!file.exists(jsd.file)) {
  print("Making plant distance matrix...")
  source("make-jsds-plant.R")
}
jsd <- fread(jsd.file)
js.dist <- dcast(jsd, sample.x ~ sample.y, value.var = "jsd") %>%
  column_to_rownames("sample.x") %>%
  data.matrix(rownames.force = TRUE) %>%
  sqrt

#' ## K-nearest neighbor density
k <- round(nrow(plant.samples) / 10)
knn <- dist2knn(js.dist, k = k)
plant.samples[, knn := knn[sample]]
ggplot(plant.samples, aes(x = progression, y = knn)) +
  geom_smooth() +
  geom_point(aes(color = type)) +
  facet_wrap(~ genotype)

#' Diarrhea samples only showing disease duration:
setkey(plant.samples, type)
theme_set(theme_cowplot())
ggplot(plant.samples["R"], aes(x = generation, y = knn)) +
  geom_smooth() +
  geom_point() +
  facet_wrap(~ genotype)

#' MDS sketch suggests existence of at least 2 clusters.
mds2 <- cmdscale(js.dist, 2, eig = TRUE)
mds2$GOF # lossy
rk.mds <- apply(mds2$points, 2, rank)
plot(rk.mds)

# mapper call
po <- 70
# Originally c(15, 15)
ni <- c(15, 15)
ftr <- list(rk.mds[,1], rk.mds[,2])

cholera.vertices <- function(map) {
  map[, .(mean.knn = mean(knn),
          f.state = sum(type == "R") / .N,
          mean.t = mean(generation),
          size = .N),
      by = .(vertex, vertex.name)]
}

cholera.mapper <- mapper2.call(ni, po, cholera.vertices)
mpr <- cholera.mapper(js.dist, plant.samples, ftr)
plot.fstate <- function(graf, ...) {
  plot.mapper.graph(graf,
                    node = geom_node_point(aes(color = f.state, size = size)),
                    ...)
}
plot.fstate(mpr$graph, seed = 1)

## validate
#subsets <- validate(js.dist, plant.samples, cholera.mapper, rs, nrep)
#plot.fstate.valid <- function(g) {
#  f <- plot.mapper.linear("f.state")
#  f(g) + labs(color = "fraction\nField") +
#    scale_color_distiller(palette = "Spectral", values = c(0, 0.5, 1))
#}
## plot.fstate.linear <- plot.mapper.linear("f.state")
## p2 <- function(g) {
##   plot.fstate.linear(g) +
##     labs(color = "fraction\ndiarrhea") +
##     scale_color_distiller(palette = "Spectral", values = c(0, 0.5, 1))
##
## }
#pl <- batch.plot(subsets, plot.fstate.valid)
#plot_grid(plotlist = pl, ncol = 1, labels = rs)
#pl.cholera.validate <- last_plot()
#write.validation.plot(paste0(figs.dir, 'sup_figplant.pdf'), last_plot())

# assign minima and basins
mpr$graph <- mpr$graph %>% mutate(scaled.knn = mean.knn / size)
mpr$graph <- assign.basins(mpr$graph, "scaled.knn", ignore.singletons = TRUE)
mpr$graph <- mpr$graph %>%
  mutate(basin = mapply(function(b, x) if (x) NA else b,
                        b = basin, x = in.singleton)) %>%
  mutate(is.extremum = mapply(function(b, x) if (x) NA else b,
                        b = is.extremum, x = in.singleton))
write.graph(mpr$graph, mpr$map[, .(point.name, vertex)],
            paste0(output.dir, "plant/"))

