#' Constants to zzz
#'
#' @export
#' @param template_path (character) path to your yaml template file. by default,
#' we use a demo template yaml file
#' @param outfile (character) Path to write your functions to
#' @return returns silently, after writing things to zzz.R
#' @examples \dontrun{
#' write_constants()
#' }
write_constants <- function(template_path = NULL, outfile = "zzz.R") {
  spec <- load_spec(template_path)

  if ("raml" %in% names(spec)) {
    stop("not ready yet")
  } else if (any(c("swagger", "openapi") %in% names(spec))) {
    if ("servers" %in% names(spec)) {
      bu <- unlist(spec$servers, FALSE)$url
    } else {
      bu <- sprintf("%s://%s%s", spec$schemes, spec$host, spec$basePath)
    }
    url <- sprintf("\n\nbase_url <- function() \"%s\"", bu)
    cat(url, file = outfile, append = TRUE)
  } else {
    cat(sprintf("\n\nbase_url <- function() \"%s\"", spec$baseurl),
        file = outfile, append = TRUE)
  }
}
