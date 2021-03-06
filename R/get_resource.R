#' Get Data From Trello API
#'
#' Fetch resources using Trello API.
#'
#' @section Request limits:
#'
#' At maximum, the API can retrieve 1000 results in a single call. Setting
#' `limit > 1000` will activate paging. When paging is used, the request will
#' be issued repeatedly, retrieving new batch of results each time until
#' the `limit` is reached or there is nothing else to fetch. Results are fetched
#' chronologically, ie. newest results are retrieved first (eg. newest cards).
#' Use `limit = Inf` to make sure you get all.
#'
#' @section Errors:
#'
#' If the request fails, server error messages are reprinted on the console.
#' Depending on the value of `on.error`, the request call can throw an error
#' in R (this is the default), or can issue a warning/message. If the latter,
#' the function returns a data frame containing the failed URL, HTTP status
#' and an informative message (produced by the server).
#'
#' @section Results:
#'
#' The API returns JSON objects which are parsed using [jsonlite::fromJSON].
#' Non-JSON results throw an error, but these should never happen anyway. The
#' result is always a data frame, or a `tibble` if the package is installed.
#'
#' @section Filter:
#'
#' Both `filter` and `limit` exist as explicitly defined arguments, but you can
#' ignore them in favor of supplying their values as query parameters, eg.
#' `query = list(filter = "filter_value", limit = "limit_value")`.
#'
#' @param parent Parent resource, e.g. `"board"` or `NULL`.
#' @param child Child resource, eg. `"card"` or `NULL`.
#' @param id Resource ID or `NULL`.
#' @param token An object of class `"Trello_API_token"`, a path to a cache file
#'   or `NULL`.
#'
#'   * If a token, it is passed as is.
#'   * If `NULL` and a cache file called `".httr-oauth"` exists, the newest token
#'     is read from it. If the file is not found, an error is thrown.
#'   * If a character vector of length 1, it will be used as an alternative path
#'     to the cache file.
#'
#' @param query Named list of key-value pairs, see [httr::GET] for details.
#' @param url Url for the GET request. Can be `NULL` if `parent` is specified,
#'   or a combination of `parent`, `child` and `id` is provided.
#' @param filter Defaults to `"all"` which includes both open and archived cards
#'   or all action types, depending on what resource is requested.
#' @param limit Defaults to `1000`. Set to `Inf` (or 0) to get everything.
#' @param on.error Whether to `"stop"`, `"warn"` or `"message"` on API error.
#' @param retry.times How many times to re-try when a request fails. Defaults
#'   to 3.
#' @param handle The handle to use with this request, see [httr::RETRY].
#' @param verbose Set to `TRUE` for verbose output.
#' @param response,paging,bind.rows Deprecated.
#'
#' @seealso [get_token], [get_id], [httr::GET], [jsonlite::fromJSON]
#'
#' @return A data frame with API responses.
#'
#' @export
#'
#' @examples
#'
#' # No authorization is required to access public boards, so there is no need
#' # to create a token, just the board id:
#' url = "https://trello.com/b/Pw3EioMM/trellor-r-api-for-trello"
#' bid = get_id_board(url)
#'
#' # Once we have the ID, we can use it to make specific queries:
#' labels = get_board_labels(bid)                # Get all labels
#' cards = get_board_cards(bid, filter = "all")  # Get all cards, incl. archived
#'
#' # We can also call get_resource() directly:
#' lists = get_resource(parent = "board", child = "lists", id = bid)
#'
#' # As with boards, cards can be queried for particular resources:
#' card10 = cards$id[10]
#' acts10 = get_card_actions(card10)    # Get all actions performed on that card
#'
#' # To specify the number of results, use limit = number. If limit = 0, all
#' # results will be acquired eventually.
#'
#' \dontrun{
#' acts_all = get_board_actions(bid, limit = 0)
#' }
#'
#' # For private and team boards, you need a secure token:
#'
#' \dontrun{
#' key = Sys.getenv("MY_TRELLO_KEY")
#' secret = Sys.getenv("MY_TRELLO_SECRET")
#'
#' token = get_token("my_app", key = key, secret = secret,
#'                   scope = c("read", "write"))
#'
#' cards_open = get_board_cards(board_id, token, filter = "open")
#' }

get_resource = function(parent = NULL, child = NULL, id = NULL, token = NULL,
                        query = NULL, url = NULL, filter = NULL, limit = 1000,
                        on.error = c("stop", "warn", "message"),
                        retry.times = 3, handle = NULL,
                        verbose = FALSE, response, paging, bind.rows)
{

  if (!missing("paging")) {
    warning("`paging`: argument is deprecated; use `limit=Inf`",
            call. = FALSE)
    if (missing(limit) & paging) limit = 0
  }

  if (!missing("bind.rows"))
    warning("`bind.rows`: argument is deprecated", call. = FALSE)

  if (!missing("response"))
    warning("`response`: argument is deprecated", call. = FALSE)

  on.error = match.arg(on.error, several.ok = FALSE)

  if (is.null(url)) {

    url = httr::modify_url(
      url = "https://api.trello.com",
      path = c(1, parent, extract_id(id), child), #path overrides url if url includes path
      query = c(
        lapply(query, tolower_if_logical),
        list(limit = limit, filter = filter)))
  }

  if (is.null(token) && file.exists(".httr-oauth"))
    token = get_token(NULL)

  if (is_nested(url)) {

    result = get_nested(
      url,
      limit       = limit,
      token       = token,
      on.error    = on.error,
      retry.times = retry.times,
      handle      = handle,
      verbose     = verbose)

  } else if (is_search(url)) {

    result = quick_df_search(get_url(
      url,
      token       = token,
      on.error    = on.error,
      retry.times = retry.times,
      handle      = handle,
      verbose     = verbose
    ))

  } else {

    result = quick_df_single(get_url(
      url,
      token       = token,
      on.error    = on.error,
      retry.times = retry.times,
      handle      = handle,
      verbose     = verbose
    ))
  }

  if (requireNamespace("tibble", quietly = TRUE)) {
    return(tibble::as_tibble(result))
  }

  result
}

is_nested = function(url) {

  path = httr::parse_url(url)[["path"]]

  length(strsplit(path, "/")[[1]]) > 3
}

is_search = function(url) {

  path = httr::parse_url(url)[["path"]]

  identical(strsplit(path, "/")[[1]][2], "search")
}

quick_df_single = function(x) {

  structure(
    wrap_list(x),
    class     = "data.frame",
    row.names = .set_row_names(1))

}

quick_df_search = function(x) {

  search_options = x[["options"]][[1]]

  search_results = x[setdiff(names(x), "options")]

  message("Fetched ", sum(vapply(search_results, NROW, 1L)), " search results.")

  structure(
    wrap_list(c(search_options, search_results)),
    class     = "data.frame",
    row.names = .set_row_names(1))
}

wrap_list = function(x) {
  x[lengths(x) > 1] = lapply(x[lengths(x) > 1], list)
  Filter(length, x)
}
