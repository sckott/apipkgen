#' Write http helpers
#'
#' @export
#' @param outfile (character) Path to write http helpers file to
#' @examples \dontrun{
#' write_helpers()
#' }
write_helpers <- function(outfile = "http-helpers.R") {
  write_http_funs(outfile)
}
