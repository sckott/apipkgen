# library("whisker")
#
# foobar <- function(..., method = "GET", url = 'http://httpbin.org') {
#   template <- '
#   function() {
#      httr::VERB("{{method}}", "{{url}}", ...)
#   }'
#
#   whisker.render(template)
# }
#
# foobar()
#
