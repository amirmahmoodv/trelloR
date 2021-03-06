% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/create_wrappers.R
\name{add_label}
\alias{add_label}
\title{Add label}
\usage{
add_label(card, color, name = NULL, ...)
}
\arguments{
\item{card}{Card id.}

\item{color}{Label color.}

\item{name}{Label name; choosing different non-existing name will create new
label. Defaults to \code{NULL}.}

\item{...}{Additional arguments passed to \code{\link[=create_resource]{create_resource()}}.}
}
\description{
Add label to a card.
}
