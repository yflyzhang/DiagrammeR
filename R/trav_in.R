#' Traverse from one or more selected nodes onto
#' adjacent, inward nodes
#' @description From a graph object of class
#' \code{dgr_graph} move along inward edges from one
#' or more nodes present in a selection to other
#' connected nodes, replacing the current nodes in
#' the selection with those nodes traversed to. An
#' optional filter by node attribute can limit the set
#' of nodes traversed to.
#' @param graph a graph object of class
#' \code{dgr_graph}.
#' @param conditions an option to use filtering
#' conditions for the traversal.
#' @return a graph object of class \code{dgr_graph}.
#' @examples
#' # Set a seed
#' set.seed(23)
#'
#' # Create a simple graph
#' graph <-
#'   create_graph() %>%
#'   add_n_nodes(
#'     2, type = "a",
#'     label = c("asd", "iekd")) %>%
#'   add_n_nodes(
#'     3, type = "b",
#'     label = c("idj", "edl", "ohd")) %>%
#'   add_edges_w_string(
#'     "1->2 1->3 2->4 2->5 3->5",
#'     rel = c(NA, "A", "B", "C", "D"))
#'
#' # Create a data frame with node ID values
#' # representing the graph edges (with `from`
#' # and `to` columns), and, a set of numeric values
#' df_edges <-
#'   data.frame(
#'     from = c(1, 1, 2, 2, 3),
#'     to = c(2, 3, 4, 5, 5),
#'     values = round(rnorm(5, 5), 2))
#'
#' # Create a data frame with node ID values
#' # representing the graph nodes (with the `id`
#' # columns), and, a set of numeric values
#' df_nodes <-
#'   data.frame(
#'     id = 1:5,
#'     values = round(rnorm(5, 7), 2))
#'
#' # Join the data frame to the graph's internal
#' # edge data frame (edf)
#' graph <-
#'   graph %>%
#'   join_edge_attrs(df_edges) %>%
#'   join_node_attrs(df_nodes)
#'
#' get_node_df(graph)
#' #>   id type label values
#' #> 1  1    a   asd   8.58
#' #> 2  2    a  iekd   7.22
#' #> 3  3    b   idj   5.95
#' #> 4  4    b   edl   6.71
#' #> 5  5    b   ohd   7.48
#'
#' get_edge_df(graph)
#' #>   id from to  rel values
#' #> 1  1    1  2 <NA>   6.00
#' #> 2  2    1  3    A   6.11
#' #> 3  3    2  4    B   4.72
#' #> 4  4    2  5    C   6.02
#' #> 5  5    3  5    D   5.05
#'
#' # Perform a simple traversal from node `4` to
#' # inward adjacent edges with no conditions
#' # on the nodes traversed to
#' graph %>%
#'   select_nodes_by_id(4) %>%
#'   trav_in() %>%
#'   get_selection()
#' #> [1] 2
#'
#' # Traverse from node `5` to inbound-facing
#' # nodes, filtering to those nodes that have
#' # numeric values greater than `5.0` for
#' # the `values` node attribute
#' graph %>%
#'   select_nodes_by_id(4) %>%
#'   trav_in(
#'     conditions = "values > 5.0") %>%
#'   get_selection()
#' #> [1] 2
#'
#' # Traverse from node `5` to any inbound
#' # nodes, filtering to those nodes that
#' # have a `type` attribute of `b`
#' graph %>%
#'   select_nodes_by_id(5) %>%
#'   trav_in(
#'     conditions = "type == 'b'") %>%
#'   get_selection()
#' #> [1] 3
#'
#' # Traverse from node `5` to any inbound
#' # nodes, filtering to those nodes that
#' # have a degree of `2`
#' graph %>%
#'   {
#'   node_degrees <-
#'     node_info(.) %>%
#'     dplyr::select(id, deg)
#'   join_node_attrs(., node_degrees)
#'   } %>%
#'   select_nodes_by_id(5) %>%
#'   trav_in(
#'     conditions = "deg == 2") %>%
#'   get_selection()
#' #> [1] 3
#'
#' # Traverse from node `5` to any inbound
#' # nodes, and use multiple conditions for the
#' # traversal (using a vector in `conditions`
#' # creates a set of `AND` conditions)
#' graph %>%
#'   select_nodes_by_id(5) %>%
#'   trav_in(
#'     conditions = c(
#'       "type == 'a'",
#'       "values > 6.0")) %>%
#'   get_selection()
#' #> [1] 2
#'
#' # Traverse from node `5` to any inbound
#' # nodes, and use multiple conditions with
#' # a single-length vector (here, using a
#' # `|` to create a set of `OR` conditions)
#' graph %>%
#'   select_nodes_by_id(5) %>%
#'   trav_in(
#'     conditions = c(
#'       "type == 'b' | values > 6.0")) %>%
#'   get_selection()
#' #> [1] 2 3
#'
#' # Traverse from node `5` to any inbound
#' # nodes, and use a regular expression as
#' # a filtering condition
#' graph %>%
#'   select_nodes_by_id(2) %>%
#'   trav_in(
#'     conditions = "grepl('^i...', label)") %>%
#'   get_selection()
#' #> [1] 2
#' @importFrom dplyr filter filter_ select inner_join rename
#' @importFrom tibble as_tibble
#' @export trav_in

trav_in <- function(graph,
                    conditions = NULL) {

  # Get the time of function start
  time_function_start <- Sys.time()

  # Validation: Graph object is valid
  if (graph_object_valid(graph) == FALSE) {
    stop("The graph object is not valid.")
  }

  # Validation: Graph contains nodes
  if (graph_contains_nodes(graph) == FALSE) {
    stop("The graph contains no nodes, so, no traversal can occur.")
  }

  # Validation: Graph contains edges
  if (graph_contains_edges(graph) == FALSE) {
    stop("The graph contains no edges, so, no traversal can occur.")
  }

  # Validation: Graph object has valid node selection
  if (graph_contains_node_selection(graph) == FALSE) {
    stop("There is no selection of nodes, so, no traversal can occur.")
  }

  # Create bindings for specific variables
  from <- to <- NULL

  # Get the selection of nodes as the starting
  # nodes for the traversal
  starting_nodes <- graph$node_selection$node

  # Get the graph's edge data frame
  edf <- graph$edges_df

  # Get the graph's node data frame
  ndf <- graph$nodes_df

  # Find all nodes that are connected to the
  # starting nodes via incoming edges
  valid_nodes <-
    edf %>%
    dplyr::filter(to != from) %>%
    dplyr::filter(to %in% starting_nodes) %>%
    dplyr::select(from)

  valid_nodes <-
    tibble::as_tibble(valid_nodes) %>%
    dplyr::rename(id = from) %>%
    dplyr::inner_join(ndf, by = "id")

  # If no rows returned, then there are no
  # valid traversals, so return the same graph
  # object without modifying the selection
  if (nrow(valid_nodes) == 0) {
    return(graph)
  }

  # If traversal conditions are provided then
  # pass in those conditions and filter the
  # data frame of `valid_nodes`
  if (!is.null(conditions)) {
    for (i in 1:length(conditions)) {

      valid_nodes <-
        valid_nodes %>%
        dplyr::filter_(conditions[i])
    }
  }

  # If no rows returned, then there are no
  # valid traversals, so return the same graph
  # object without modifying the selection
  if (nrow(valid_nodes) == 0) {
    return(graph)
  }

  # Add the node ID values to the active selection
  # of nodes in `graph$node_selection`
  graph$node_selection <-
    replace_graph_node_selection(
      graph = graph,
      replacement = valid_nodes$id)

  # Replace `graph$edge_selection` with an empty df
  graph$edge_selection <- create_empty_esdf()

  # Update the `graph_log` df with an action
  graph$graph_log <-
    add_action_to_log(
      graph_log = graph$graph_log,
      version_id = nrow(graph$graph_log) + 1,
      function_used = "trav_in",
      time_modified = time_function_start,
      duration = graph_function_duration(time_function_start),
      nodes = nrow(graph$nodes_df),
      edges = nrow(graph$edges_df))

  # Write graph backup if the option is set
  if (graph$graph_info$write_backups) {
    save_graph_as_rds(graph = graph)
  }

  return(graph)
}
