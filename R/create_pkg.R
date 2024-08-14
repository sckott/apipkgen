add_fun_imports <- function(http_lib = "crul") {
  http_lib_imports <- switch(http_lib,
    crul = c("crul", "HttpClient"),
    httr = c("httr", "VERB", "stop_for_status", "content")
  )
  libs <- list(
    c("jsonlite", "fromJSON"),
    c("glue", "glue"),
    http_lib_imports
  )
  lapply(libs, \(x) usethis::use_import_from(x[1], x[-1]))
}

create_utils <- function(path) {
  txt <- "ct <- function(l) Filter(Negate(is.null), l)"
  cat(paste0(auto_gen, txt), file = file.path(path, "R/zzz.R"))
}

create_pkg <- function(path, http_lib = "crul") {
  usethis::create_package(path, open = FALSE)
  withr::with_dir(path, {
    usethis::use_mit_license()
    usethis::use_package(http_lib)
    usethis::use_package("jsonlite")
    usethis::use_package("glue")
    usethis::use_package_doc(open = FALSE)
    add_fun_imports(http_lib)
    create_utils(path)
  })
  invisible(TRUE)
}
