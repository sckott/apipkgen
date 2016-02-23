xGET <- function(url, ...) {
  xVERB("GET", url, ...)
}

xPOST <- function(url, ..., body = NULL, encode = "json") {
  body <- ct(body)
  xVERB("POST", url, ..., body = body, encode = encode)
}

xPUT <- function(url, ...) {
  xVERB("PUT", url, ...)
}

xPATCH <- function(url, ...) {
  xVERB("PATCH", url, ...)
}

xDELETE <- function(url, ...) {
  xVERB("DELETE", url, ...)
}

xVERB <- function(verb, url, ...) {
  res <- httr::VERB(verb, url, ...)
  # No content
  if (length(res$content) == 0) {
    httr::stop_for_status(res)
    return(invisible(TRUE))
  }
  httr::stop_for_status(res)
  httr::content(res, as = "text", encoding = "UTF-8")
}
