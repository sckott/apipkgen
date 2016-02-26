#' API template format
#'
#' @name template-format
#' @section baseurl:
#' \itemize{
#'  \item required: TRUE
#'  \item type: character string
#'  \item description: the base url should be the base url, on to which any
#'  routes are added (e.g., base url of 'http://stuff.com', and the route 'things'
#'  would make a url of 'http://stuff.com/things')
#' }
#'
#' @section data:
#' \itemize{
#'  \item required: TRUE
#'  \item type: character string
#'  \item description: one of \code{json} or \code{xml} (only json supported right now)
#' }
#'
#' @section routes:
#' \itemize{
#'  \item required: TRUE
#'  \item type: array
#'  \item description: any number of routes, see route below for description
#' }
#'
#' @section a single route:
#' \itemize{
#'  \item required: TRUE
#'  \item type: array
#'  \item description: Follows the following pattern:
#'  name:
#'    path:
#'      id:
#'        options: NULL
#'        class: character
#'        required: FALSE
#'    params:
#'      query:
#'        options: NULL
#'        class: character
#'        required: FALSE
#' }
NULL
