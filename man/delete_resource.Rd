% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/delete_resource.R
\name{delete_resource}
\alias{delete_resource}
\title{Delete Resources}
\usage{
delete_resource(
  resource,
  id,
  path = NULL,
  token = NULL,
  response = c("content", "headers", "status", "response"),
  on.error = c("stop", "warn", "message"),
  verbose = FALSE,
  encode = "json",
  handle = NULL
)
}
\arguments{
\item{resource, id}{Resource name (eg. \code{"card"}) and id.}

\item{path}{Path (optional).}

\item{token}{An object of class \code{"Trello_API_token"}, a path to a cache file
or \code{NULL}.
\itemize{
\item If a \code{Token}, it is passed as is.
\item If \code{NULL} and a cache file called \code{".httr-oauth"} exists, the newest token
is read from it. If the file is not found, an error is thrown.
\item If a character vector of length 1, it will be used as an alternative path
to the cache file.
}}

\item{response}{Can return \code{"content"} (the default), \code{"headers"}, \code{"status"}
or the raw \code{"response"}.}

\item{on.error}{Whether to \code{"stop"}, \code{"warn"} or \code{"message"} on http error.}

\item{verbose}{Whether to pass \link[httr:verbose]{httr::verbose} to \link[httr:PUT]{httr::PUT}.}

\item{encode, handle}{Passed to \link[httr:DELETE]{httr::DELETE}.}
}
\value{
See \code{response}.
}
\description{
Delete resources via Trello API.
}
\details{
See \href{https://developers.trello.com/v1.0/reference}{Trello API reference}
for more info about DELETE requests.
}
\examples{

\dontrun{

# Get token with write access
key = Sys.getenv("MY_TRELLO_KEY")
secret = Sys.getenv("MY_TRELLO_SECRET")

token = get_token("my_app", key = key, secret = secret,
                  scope = c("read", "write"))

# Get board ID
url = "Your board URL"
bid = get_id_board(url, token)

# Get cards and extract ID of the first one
cid = get_board_cards(bid, token)$id[1]

# Delete it
delete_resource(resource = "card", id = cid, token = token)
}
}
