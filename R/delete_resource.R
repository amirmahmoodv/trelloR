#' Delete Resources
#'
#' Delete resources via Trello API.
#'
#' See [Trello API reference](https://developers.trello.com/v1.0/reference)
#' for more info about DELETE requests.
#'
#' @param resource,id Resource name (eg. `"card"`) and id.
#' @param path Path (optional).
#' @param token An object of class `"Trello_API_token"`, a path to a cache file
#'   or `NULL`.
#'
#'   * If a `Token`, it is passed as is.
#'   * If `NULL` and a cache file called `".httr-oauth"` exists, the newest token
#'     is read from it. If the file is not found, an error is thrown.
#'   * If a character vector of length 1, it will be used as an alternative path
#'     to the cache file.
#'
#' @param verbose Whether to pass [httr::verbose] to [httr::PUT].
#' @param response Can return `"content"` (the default), `"headers"`, `"status"`
#'   or the raw `"response"`.
#' @param on.error Whether to `"stop"`, `"warn"` or `"message"` on http error.
#' @param encode,handle Passed to [httr::DELETE].
#'
#' @return See `response`.
#'
#' @export
#' @examples
#'
#' \dontrun{
#'
#' # Get token with write access
#' key = Sys.getenv("MY_TRELLO_KEY")
#' secret = Sys.getenv("MY_TRELLO_SECRET")
#'
#' token = get_token("my_app", key = key, secret = secret,
#'                   scope = c("read", "write"))
#'
#' # Get board ID
#' url = "Your board URL"
#' bid = get_id_board(url, token)
#'
#' # Get cards and extract ID of the first one
#' cid = get_board_cards(bid, token)$id[1]
#'
#' # Delete it
#' delete_resource(resource = "card", id = cid, token = token)
#' }

delete_resource = function(resource, id, path = NULL, token = NULL,
                           response = c("content", "headers", "status",
                                        "response"),
                           on.error = c("stop", "warn", "message"),
                           verbose = FALSE,
                           encode   = "json", handle = NULL) {

  url = httr::modify_url(
    url = "https://api.trello.com",
    path = c(1, paste0(resource, "s"), id, path)
  )

  message(
    "Request URL:\n", url, "\n"
  )

  on.error = match.arg(on.error, several.ok = FALSE)

  response = match.arg(response, several.ok = FALSE)

  if (!inherits(token, "Trello_API_token")) {
    token = read_cached_token(token)
  }

  if (verbose) {

    res = httr::DELETE(
      url = url,
      httr::config(token = token),
      httr::verbose(),
      httr::user_agent("https://github.com/jchrom/trelloR"))

  } else {

    res = httr::DELETE(
      url = url,
      httr::config(token = token),
      httr::user_agent("https://github.com/jchrom/trelloR"))
  }

  switch(
    on.error,
    message = httr::message_for_status(res),
    warn    = httr::warn_for_status(res),
    httr::stop_for_status(res)
  )

  if (!on.error == "message" && !httr::status_code(res) >= 300)
    httr::message_for_status(res)

  switch(
    response,
    content = httr::content(res),
    headers = httr::headers(res),
    status  = httr::status_code(res),
    res
  )
}
