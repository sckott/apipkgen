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
  cat(sprintf("\n\nbase_url <- function() \"%s\"", spec$baseurl),
      file = outfile, append = TRUE)
}
