
<!-- README.md is generated from README.Rmd. Please edit that file -->

## R API for Trello

[![Build
Status](https://travis-ci.org/jchrom/trelloR.svg?branch=master)](https://travis-ci.org/jchrom/trelloR)
[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/trelloR)](https://cran.r-project.org/package=trelloR)
[![Rdoc](http://www.rdocumentation.org/badges/version/trelloR)](http://www.rdocumentation.org/packages/trelloR)

The purpose of `trelloR` is to easily interact with [Trello
API](https://developers.trello.com/) from R.

It can retrieve, create, update and delete data from Trello boards,
using functions with predictable names. The following snippet fetches
cards from a public board:

``` r
library(trelloR)
cards = get_board_cards("https://trello.com/b/Pw3EioMM/trellor-r-api-for-trello")
```

Private and team boards can be accessed using a secure token. Check the
vignettes to [get
started](https://jchrom.github.io/trelloR/articles/get-public-data.html).

### Get it from GitHub

``` r
devtools::install_github("jchrom/trelloR")
```

**CRAN (version 0.1)**

The CRAN version has been long outdated and should not be preferred. The
CRAN package will be updated when version 0.7 is released. In the
meantime, please use the development version above.

Built using [httr](https://cran.r-project.org/package=httr) and
[jsonlite](https://cran.r-project.org/package=jsonlite).

**Disclaimer:** `trelloR` is not affiliated, associated, authorized,
endorsed by or in any way officially connected to Trello, Inc.
(<http://www.trello.com>).
