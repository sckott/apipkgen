ct <- function(l) Filter(Negate(is.null), l)

pluck <- function(x, name, type) {
  if (missing(type)) {
    lapply(x, "[[", name)
  } else {
    vapply(x, "[[", name, FUN.VALUE = type)
  }
}

strextract <- function(str, pattern) regmatches(str, regexpr(pattern, str))

# apipkg_GET <- function(path, key, ...){
#   temp <- GET(file.path(base_url(), path), query = ct(list(token = check_key(key))), ...)
#   stop_for_status(temp)
#   stopifnot(temp$headers$`content-type` == 'application/json; charset=utf-8')
#   #err_catcher(temp)
#   content(temp, as = 'text', encoding = "UTF-8")
# }

# apipkg_err_catcher <- function(x) {
#   xx <- jsonlite::fromJSON(content(x, as = 'text', encoding = "UTF-8"))
#   if (any(vapply(c("message", "error"), function(z) z %in% names(xx), logical(1)))) {
#     stop(xx[[1]], call. = FALSE)
#   }
# }

# apipkg_parse <- function(x, parse) {
#   jsonlite::fromJSON(x, parse)
# }
