#' Write http helpers
#'
#' @export
#' @param outfile (character) Path to write http helpers file to
#' @param http_lib (character) one of `crul` (default) or `httr`
#' @examples \dontrun{
#' write_helpers()
#' }
write_helpers <- function(outfile = "http-helpers.R", http_lib = "crul") {
  write_http_funs(outfile, http_lib)
}
