#' Get a vector of edge ID values
#' @description Obtain a vector of edge ID values
#' from a graph object. An optional filter by
#' edge attribute can limit the set of edge ID
#' values returned.
#' @param graph a graph object of class
#' \code{dgr_graph}.
#' @param conditions an option to use filtering
#' conditions for the retrieval of edges.
#' @return a vector of edge ID values.
#' @examples
#' # Create a node data frame (ndf)
#' ndf <-
#'   create_node_df(
#'     n = 4,
#'     type = "letter",
#'     color = c("red", "green", "grey", "blue"),
#'     value = c(3.5, 2.6, 9.4, 2.7))
#'
#' # Create an edge data frame (edf)
#' edf <-
#'   create_edge_df(
#'     from = c(1, 2, 3),
#'     to = c(4, 3, 1),
#'     rel = "leading_to",
#'     color = c("pink", "blue", "blue"),
#'     value = c(3.9, 2.5, 7.3))
#'
#' # Create a graph
#' graph <-
#'   create_graph(
#'     nodes_df = ndf,
#'     edges_df = edf)
#'
#' # Get a vector of all edges in a graph
#' get_edge_ids(graph)
#' #> [1] 1 2 3
#'
#' # Get a vector of edge ID values using a
#' # numeric comparison (i.e., all edges with
#' # `value` attribute greater than 3)
#' get_edge_ids(
#'   graph,
#'   conditions = "value > 3")
#' #> [1] 1 3
#'
#' # Get a vector of edge ID values using
#' # a match pattern (i.e., all nodes with
#' # `color` attribute of `pink`)
#' get_edge_ids(
#'   graph,
#'   conditions = "color == 'pink'")
#' #> [1] 1
#'
#' # Use multiple conditions to return nodes
#' # with the desired attribute values
#' get_edge_ids(
#'   graph,
#'   conditions = c("color == 'blue'",
#'                  "value > 5"))
#' #> [1] 3
#' @importFrom dplyr filter_
#' @export get_edge_ids

get_edge_ids <- function(graph,
                         conditions = NULL) {


  # If the graph contains no edges, return NA
  if (nrow(graph$edges_df) == 0) {
    return(NA)
  }

  # Extract edge data frame from the graph
  edges_df <- graph$edges_df

  # If conditions are provided then
  # pass in those conditions and filter the
  # data frame of `edges_df`
  if (!is.null(conditions)) {
    for (i in 1:length(conditions)) {
      edges_df <-
        edges_df %>%
        dplyr::filter_(conditions[i])
    }
  }

  # If no edges remain then return NA
  if (nrow(edges_df) == 0) {
    return(NA)
  }

  return(edges_df$id)
}
