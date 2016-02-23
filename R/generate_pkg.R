#' HTTP API package generator
#'
#' @export
#' @param pkg_path (character) Path to the new package, where last part will be
#' the package name
#' @param template_path (character) path to your yaml template file. by default,
#' we use a demo template yaml file
#' @examples \dontrun{
#' generate_pkg(pkg_path = "mypkg")
#' }
generate_pkg <- function(pkg_path, template_path = NULL) {
  create_pkg(path = pkg_path)
  path <- normalizePath(pkg_path, winslash = "/", mustWork = TRUE)
  write_helpers(file.path(path, "R/http-helpers.R"))
  write_fxns(template_path, outfile = file.path(path, "R/http-fxns.R"))
}
