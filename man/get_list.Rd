% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_list.R
\name{get_list}
\alias{get_list}
\alias{get_list_actions}
\alias{get_list_cards}
\alias{get_list_comments}
\title{Get List}
\usage{
get_list_actions(id, ...)

get_list_cards(id, ...)

get_list_comments(id, ...)
}
\arguments{
\item{id}{Board ID}

\item{...}{Additional arguments passed to \code{\link{get_resource}}}
}
\description{
Returns a flat \code{data.frame} with list-related data.
}
\seealso{
\code{\link{get_resource}}
}
