# R API for Trello

[![Build Status](https://travis-ci.org/jchrom/trellor.svg?branch=master)](https://travis-ci.org/jchrom/trellor)

The purpose of `trellor` is to provide easy access to the [Trello API](https://developers.trello.com/) from R. It can retrieve data from various levels of JSON hierarchy (e.g. cards that belong to a particular board or members assigned to a particular card).

Requests are carried out by simple functions with meaningful names, such as `get_my_boards()` or `get_card_comments()`. Automated paging makes sure that all the results will be acquired. Access to private boards is achieved by obtaining a secure token with [Trello developer keys](https://trello.com/app-key).

You can install the development version from Github:

```{r, eval=FALSE, include=TRUE}
devtools::install_github("jchrom/trellor")
```

**Note.** `trellor` is built on top of Hadley Wickham's [httr](https://cran.r-project.org/web/packages/httr/index.html) and Jeroen Ooms' [jsonlite](https://cran.r-project.org/web/packages/jsonlite/index.html).

**Disclaimer:** `trellor` is not affiliated, associated, authorized, endorsed by or in any way officially connected to Trello, Inc. (<http://www.trello.com>).

# Using R API for Trello

The first step is to open a new R project and authorize your API access. After that you can start calling Trello API to get the data you need.

## Step 1: Authorize your API access

Before you can start using the Trello API, you need to authorize an "app". An app uses a secure "token" to communicate with the Trello API. This will allow you to retrieve private data only you have the access to.

To create a token, visit <https://trello.com/app-key> and get your developer key and secret. Then, use the `trello_get_token()` function to create a token for your project. This will also trigger first-time authorization (you only have to do it once):

```{r, eval=FALSE, include=TRUE}
library(trellor)
my_token = trello_get_token(your_key, your_secret)
```

You will be prompted to confirm authorization in a browser. You will also be offered an option to store the authentication data in your working directory, in a hidden `'.httr-oauth'` file.

**NOTE.** Make sure you keep your key and secret in a **safe, non-shared** location.

## Step 2: Getting data out of Trello

### Get IDs of your boards

Once you have authorized your API access, you can start using the functions designed to retrieve data. A good starting point is the `get_my_boards()` function, which returns a `data.frame` with board names and IDs related to the user who authorized the app. Your previously created token is its only argument:

```{r, eval=FALSE, include=TRUE}
my_boards = get_my_boards(my_token)
```

IDs are important. If you want to retrieve a specific data point, you will need its ID or the ID of its parent structure.

### Available functions

#### The `get_board_` functions

You can obtain cards, labels, members, lists and action records related to a particular board ID using the family of `get_board_` functions. Each of these returns a `data.frame` with IDs and more related data. The following code retrieves all the cards from a particular board:

```{r, eval=FALSE, include=TRUE}
my_boards = get_my_boards(my_token)
board1_id = my_boards$id[1]
my_cards  = get_board_cards(board1_id, my_token)
```

#### The `get_card_` functions

Once you have an ID of a specific card, you can use another family of functions, the `get_card_` functions. They do the same things as the `get_board_` functions but for cards. The following code returns all the comments related to a particular card:

```{r, eval=FALSE, include=TRUE}
card1_id    = my_cards$id[1]
my_comments = get_card_comments(card1_id, my_token)
```

#### Function naming scheme

Every function name refers to a parent structure (the thing after the first underscore, such as `_board_`) and the child structure (such as `_actions`). This makes it easy to guess function names. If you need, say, a list of members assigned to a card, simply call `get_card_members()`.

# Things to be aware of

There are several issues you should know about. They include **handling large requests, choosing the response format** and **building custom queries.**

## Handling large requests a.k.a. *paging*

Trello limits the number of results of a single request to 1000 (which corresponds to 1000 rows in the resulting `data.frame`). This may not be sufficient when requesting larger amounts of data, e.g. all the actions related to a board ID.

To get more than 1000 results, you need to break down your request into several separate requests, each retrieving no more than 1000 results. This is called "paging", and `trellor` will do that for you without a hassle. To use paging, set `paging = TRUE`. This will make `trellor` retrieve **all** the results for given request, i.e. as many pages as needed. It will then return a `data.frame` with combined results.

```{r, eval=FALSE, include=TRUE}
my_boards  = get_my_boards(my_token)
board1_id  = my_boards$id[1]
my_actions = get_board_actions(board1_id, my_token, paging = TRUE)
```

## The format of results

The data is returned in form of a flat `data.frame` whenevr possible, so you don't have to worry about formatting the response (courtesy of the `jsonlite::fromJSON` function). However, sometimes a more complex structure is returned as a `list` which may contain more `list`s and/or `data.frame`s. Ultimately, the finest grain in the hierarchy is always a `data.frame`.

The names of variables will be the same as they are in the incomming JSON. This is not optimal in many contexts. For instance, card ID and member ID are both called "id", which is not very useful if you want to do table joins. In the immediate future, a "facelifting" function will be provided to impose a consistent naming scheme and perhaps dropping some less frequently used variables.

## Calling your own queries

All the `get_` functions call `trello_get`, which is a wrapper for `httr::GET`. This strips away complexity in the following way:

1. `httr::GET` fetches results for exactly one request; it needs a complete URL, query parameters and a token. It does the heavy lifting but leaves error handling, response formatting and paging to you.

2. `trello_get` makes the process a bit cosier: it handles error messages, formats the response and takes care of paging; but you still have to build a complete URL and query parameters.

3. Finally the `get_` functions contain prepackaged URLs and query parameters, eliminating almost all the effort. If you want to use your own URLs and queries, you can fall back to `trello_get`.

You can find out more about endpoints and query options on [Trello API reference page](https://developers.trello.com/advanced-reference).
