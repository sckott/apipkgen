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
    z <- routes[[i]]
    for (j in seq_along(z[grep("get|post|put|patch|delete|head|options", names(z))])) {

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

      if (is.null(forms)) {
        fun <- sprintf("%s <- function(...) {",
          sw_stand_route(names(routes)[i]))
        http <- sprintf("   %s(url, ...)", paste0("x", "GET"))
      } else {
        fun <- sprintf(
          "%s <- function(%s, ...) {",
          sw_stand_route(names(routes)[i]),
          paste0(forms, collapse = ", "))
        param_names <- vapply(z$get$parameters, "[[", "", "name")
        http <- sprintf(
          "   %s(url, query = ct(list(%s)), ...)",
          paste0("x", "GET"),
          paste0(paste(param_names, param_names, sep = " = "), collapse = ", ")
        )
      }

      ## URL
      urlprep <- sprintf("   url <- file.path(base_url(), \"%s\")",
                         sub("/", "", names(routes)[i]))

      end <- "}\n"
      all <- paste(fun, urlprep, http, end, sep = "\n")
      cat(all, file = outfile, append = TRUE, sep = "\n")
    }
    cat("\n", file = outfile, append = TRUE)
  }
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
  gsub("\\{|\\}", "", gsub("/", "_", sub('^/', '', x)))
}
