# generate fxns from RAML spec
write_fxns_raml <- function(template_path = NULL, outfile = "http-fxns.R") {
  spec <- load_spec(template_path)
  routes <- spec[grep("/", names(spec))]

  for (i in seq_along(routes)) {
    z <- routes[[i]]
    for (j in seq_along(z[grep("get|post|put|patch|delete|head|options", names(z))])) {
      forms <- c()
      for (k in seq_along(z$get$queryParameters)) {
        forms[[k]] <- paste0(names(z$get$queryParameters)[k],
                             if (z$get$queryParameters[[k]]$required) '' else ' = NULL')
      }

      fun <- sprintf('%s <- function(%s, ...) {', sub('/', '', names(routes)[i]), paste0(forms, collapse = ", "))
      urlprep <- if (is.null(z$uriParameters)) {
        sprintf("   url <- file.path(base_url(), \"%s\")", sub('/', '', names(routes)[i]))
      } else {
        sprintf(
          "   url <- file.path(base_url(), \"%s\")\n   if (!is.null(%s)) url <- file.path(url, %s)",
          names(spec$routes)[i],
          names(z$path[1]),
          names(z$path[1])
        )
      }
      http <- sprintf(
        "   %s(url, query = ct(list(%s)), ...)",
        paste0("x", "GET"),
        paste0(paste(names(z$get$queryParameters), names(z$get$queryParameters), sep = " = "), collapse = ", ")
      )
      end <- '}\n'
      all <- paste(fun, urlprep, http, end, sep = "\n")
      cat(all, file = outfile, append = TRUE, sep = "\n")
    }
    cat("\n", file = outfile, append = TRUE)
  }
}
