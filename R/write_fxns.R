#' Function generator
#'
#' @export
#' @param template_path (character) path to your yaml template file. by default,
#' we use a demo template yaml file
#' @param outfile (character) Path to write your functions to
#' @return returns silently, after writing all functions into a single file,
#' given by \code{outfile}
#' @examples \dontrun{
#' write_fxns()
#' }
write_fxns <- function(template_path = NULL, outfile = "http-fxns.R") {
  spec <- load_spec(template_path)

  for (i in seq_along(spec$routes)) {
    z <- spec$routes[[i]]
    z$methods <- gsub("\\s", "", strsplit(z$methods, ",")[[1]])
    for (j in seq_along(z$methods)) {
      forms <- c()
      for (k in seq_along(z$params)) {
        forms[[k]] <- paste0(names(z$params)[k], if (z$params[[k]]$required) '' else ' = NULL')
      }

      if (!is.null(z$path)) {
        paths <- paste0(names(z$path[1]), if (z$path[[1]]$required) '' else ' = NULL')
        forms <- c(paths, forms)
      }

      fxn_suff <- if (length(z$methods) > 1) paste0("_", z$methods[j]) else ""
      fun <- sprintf('%s%s <- function(%s, ...) {', names(spec$routes)[i], fxn_suff, paste0(forms, collapse = ", "))
      urlprep <- if (is.null(z$path)) {
        sprintf("   url <- file.path(base_url(), \"%s\")", names(spec$routes)[i])
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
        paste0("x", z$methods[j]),
        paste0(paste(names(z$params), names(z$params), sep = " = "), collapse = ", ")
      )
      end <- '}\n'
      all <- paste(fun, urlprep, http, end, sep = "\n")
      cat(auto_gen, file = outfile, append = TRUE, sep = "\n")
      cat(all, file = outfile, append = TRUE, sep = "\n")
    }
    cat("\n", file = outfile, append = TRUE)
  }
}

# helpers -----------------------
load_spec <- function(x) {
  if (is.null(x)) x <- system.file("examples", "template.yml", package = "apipkgen")
  x <- path.expand(x)
  if (!file.exists(x)) stop("file doesn't exist, check your path", call. = FALSE)
  yaml::yaml.load_file(x)
}

write_http_funs <- function(file) {
  x <- system.file("examples", "http-functions.R", package = "apipkgen")
  cat(paste(readLines(x), collapse = "\n"), file = file, append = TRUE)
}

make_alist <- function(args) {
  res <- replicate(length(args), substitute())
  setNames(res, args)
}

# make_function2 <- function(args, env = parent.frame()) {
#   f <- function() {
#     url <- file.path(base, "APPEND")
#     res <- httr::GET(file.path(url, ...))
#     jsonlite::fromJSON(content(res, "text", encoding = "UTF-8"), FALSE)
#   }
#   formals(f) <- args
#   environment(f) <- env
#   return(f)
# }
