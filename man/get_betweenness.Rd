% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_betweenness.R
\name{get_betweenness}
\alias{get_betweenness}
\title{Get betweenness centrality scores}
\usage{
get_betweenness(graph)
}
\arguments{
\item{graph}{a graph object of class
\code{dgr_graph}.}
}
\value{
a data frame with betweenness scores for
each of the nodes.
}
\description{
Get the betweenness centrality scores
for all nodes in a graph.
}
\examples{
# Create a random graph
graph <-
  create_random_graph(
    10, 22, set_seed = 1)

# Get the betweenness scores for nodes in the graph
get_betweenness(graph)
#>    id betweenness
#> 1   1    6.633333
#> 2   2    5.638095
#> 3   3    1.904762
#> 4   4    4.019048
#> 5   5    8.157143
#> 6   6    2.000000
#> 7   7   10.157143
#> 8   8    8.857143
#> 9   9    3.466667
#> 10 10    1.166667

# Add the betweenness values to the graph
# as a node attribute
graph <-
  graph \%>\%
  join_node_attrs(
    get_betweenness(.))
}

