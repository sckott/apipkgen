# generate fxns from Swagger spec
write_fxns_swagger <- function(template_path = NULL, outfile = "http-fxns.R") {
  spec <- load_spec(template_path)
  routes <- spec$paths

  ## check for api key required
  sec_param_name <- NULL
  if ("security" %in% names(spec) || "securityDefinitions" %in% names(spec)) {
    sec_param_name <- spec$securityDefinitions$api_key$name
  }

  for (i in seq_along(routes)) {
    if (exists("urlprep")) rm(urlprep)
    z <- routes[[i]]
    for (j in seq_along(z[grep("get|post|put|patch|delete|head|options", names(z))])) {

      ## fxn level docs
      pkg_level <- pkg_level_docs(z$get)

      ## parameters
      forms <- c()
      for (k in seq_along(z$get$parameters)) {
        pardef <- z$get$parameters[[k]]
        forms[[k]] <- paste0(
          pardef$name,
          if (!is.null(pardef$required)) {
            if (pardef$required) {
              if (!is.null(pardef$schema$default))
                sprintf(" = \"%s\"", pardef$schema$default)
              else 
                ""
            } else {
              " = NULL"
            }
          } else {
            " = NULL"
          }
        )
      }

      # add sec param if needed
      if (!is.null(sec_param_name)) {
        forms <- c(forms, sprintf("%s = NULL", sec_param_name))
      }

      # prep docs, parameter level
      param_level <- vector("character", length = length(z$get$parameters))
      for (k in seq_along(z$get$parameters)) {
        name <- z$get$parameters[[k]]$name
        desc <- z$get$parameters[[k]]$description %||% ""
        desc <- gsub("\n", " ", desc)
        if (desc != "") desc <- paste0(sub("\\.$", "", desc), ".")
        required <- z$get$parameters[[k]]$required
        if (!is.null(required)) required <- paste("Required:", required)
        schema <- z$get$parameters[[k]]$schema
        if (!is.null(schema)) {
          type <- schema$type %||% ""
          enum <- schema$enum %||% ""
          default <- schema$default %||% ""
        } else {
          type <- z$get$parameters[[k]]$type %||% ""
          enum <- ""
          default <- ""
        }
        if (type != "") type <- switch(type, string = "character", type)
        if (all(enum != "")) enum <- sprintf("Must be one of: %s.", paste0(enum, collapse = ", "))
        if (default != "") default <- sprintf("Default: %s.", default)
        param_level[[k]] <- glue::glue("#' @param {name} ({type}) {desc} {enum} {default} {required}")
      }

      # handle parameters
      if (is.null(forms)) {
        fun <- sprintf("%s <- function(...) {",
          sw_stand_route(names(routes)[i]))
        http <- sprintf("   %s(url, ...)", paste0("x", "GET"))
        urlprep <- sprintf("   url <- file.path(base_url(), \"%s\")",
          sub("/", "", names(routes)[i]))
      } else {
        fun <- sprintf(
          "%s <- function(%s, ...) {",
          sw_stand_route(names(routes)[i]),
          paste0(forms, collapse = ", "))
        # split btw query params and path params
        p_path <- Filter(function(w) w$`in` == "path", z$get$parameters)
        if (length(p_path)) {
          p_path <- vapply(p_path, "[[", "", "name")
          urlprep <- sprintf("   url <- file.path(base_url(), glue::glue(\"%s\"))", 
            sub("^/", "", names(routes)[i]))
        }

        p_query <- Filter(function(w) w$`in` == "query", z$get$parameters)
        if (length(p_query)) {
          p_query <- vapply(p_query, "[[", "", "name")
          http <- sprintf(
            "   %s(url, query = ct(list(%s)), ...)",
            paste0("x", "GET"),
            paste0(paste(p_query, p_query, sep = " = "), collapse = ", ")
          )
        } else {
          http <- "   xGET(url, ...)"
        }

        if (inherits(tryCatch(urlprep, error = function(e) e), "error")) {
          urlprep <- sprintf("   url <- file.path(base_url(), \"%s\")",
            sub("/", "", names(routes)[i]))
        }
      }

      docs <- paste0(c(pkg_level, param_level), collapse = "\n")

      end <- "}\n"
      all <- paste(docs, fun, urlprep, http, end, sep = "\n")
      cat(all, file = outfile, append = TRUE, sep = "\n")
    }
    cat("\n", file = outfile, append = TRUE)
  }
}

pkg_level_docs <- function(x) {
  pkglev_title <- x$summary %||% ""
  pkglev_descr <- x$description %||% ""
  pkglev_descr <- strsplit(pkglev_descr, "\n")[[1]]
  pkglev_keywords <- x$tags %||% ""
  if (all(pkglev_keywords != ""))
    pkglev_keywords <- paste0(pkglev_keywords, collapse = " ")
  line_prefix <- "#'"
  top <- paste(line_prefix, c(pkglev_title, "", pkglev_descr))
  pk <- ""
  if (pkglev_keywords != "") pk <- paste(line_prefix, "@keywords", pkglev_keywords)
  c(top, pk, "#' @export")
}

sw_param_get <- function(x, spec) {
  loc <- gsub("/", "$", gsub("#", "", x$`$ref`))
  eval(parse(text = paste0("spec", loc)))
}

sw_param_names <- function(x, spec) {
  locs <- vapply(x, function(z) gsub("/", "$", gsub("#", "", z$`$ref`)), "")
  unname(vapply(paste0("spec", locs), function(w) eval(parse(text = w))$name, ""))
}

sw_stand_route <- function(x) {
  gsub("[{}-]", "", gsub("/", "_", sub('^/', '', x)))
}
