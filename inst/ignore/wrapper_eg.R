#' Wrapper example
#'
#' @export
#' @param outfile (character) Path to write your functions to
#' @examples \dontrun{
#' wrapper_eg()
#' }
wrapper_eg <- function(outfile = "myfunction.R") {

  cat("\n", file = outfile, append = TRUE)
}
