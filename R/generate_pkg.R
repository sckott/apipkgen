#' HTTP API package generator
#'
#' @export
#' @param pkg_path (character) Path to the new package, where last part will be
#'   the package name
#' @param template_path (character) path to your yaml template file. by default,
#'   we use a demo template yaml file
#' @param http_lib (character) one of `crul` (default) or `httr`
#' @param base_url (character) Base URL. If `NULL`, defaults to `baseUrl` or is
#'   formed from `schemes`, `host`, `basePath` as specified in the template
#'   file.
#' @examples \dontrun{
#' generate_pkg(pkg_path = "mypkg")
#'
#' # from a Swagger spec
#' url <- "https://raw.githubusercontent.com/ropenscilabs/apispecs/master/swagger/crossref.yml"
#' # x <- paste0(readLines(url), collapse = "\n")
#' # yaml::yaml.load(string = x)
#' download.file(url, "crossref.yml")
#' generate_pkg(pkg_path = "foobar", template_path = "crossref.yml")
#' }
generate_pkg <- function(pkg_path, template_path = NULL, http_lib = "crul", 
  base_url = NULL) {

  assert(http_lib, "character")
  stopifnot(http_lib %in% c("crul", "httr"))
  create_pkg(path = pkg_path, http_lib)
  path <- normalizePath(pkg_path, winslash = "/", mustWork = TRUE)
  write_helpers(file.path(path, "R/http-helpers.R"), http_lib)
  write_fxns(template_path, outfile = file.path(path, "R/http-fxns.R"))
  write_constants(template_path, outfile = file.path(path, "R/zzz.R"), 
    base_url = base_url)
}
