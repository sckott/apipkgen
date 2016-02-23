apipkgen
========

Generate a HTTP API wrapper package from a yaml template for the API

## Installation


```r
devtools::install_github("ropenscilabs/apipkgen")
```


```r
library("apipkgen")
```

## generate a package

use the function `rl_citation()`


```r
template <- system.file('examples', 'template_crossref.yml', package = "apipkgen")
apipkgen::generate_pkg("../crpkg", template_path = template)
```

Then go to the new directory, and in R/RStudio run `devtools::document()` and `devtools::install()` (or equivalent)

## your package needs functions

The package created doesn't have any exported functions, just internal functions for your to build user facing functions. 

Let's write a user facing functions. The Crossref API template above specified for the `works` route that parameters are `query` and `rows`. So let's work with those.


```r
crossref_works <- function(query = NULL, rows = NULL, ...) {
  works(query = query, rows = rows, ...)
}
```

In addition, it's a good idea to always allow users to pass in curl options. Beginners can ignore it, but power curl users will want/have to play with curl options. The function builder builds in `...` as a parameter so in the user facing function above all you have to do is add that as well for users to access.

Call the function. The package builder gives back plain text, so you have to parse it yourself.


```r
res <- crossref_works(query = "science")
jsonlite::fromJSON(res)
#> $status
#> [1] "ok"
#> 
#> $`message-type`
#> [1] "work-list"
#> 
#> $`message-version`
#> [1] "1.0.0"
#> 
#> $message
#> $message$query
#> $message$query$`search-terms`
#> [1] "science"
#> 
#> $message$query$`start-index`
#> [1] 0
#> 
#> 
#> $message$`items-per-page`
#> [1] 20
#> 
#> $message$items
#>     indexed.date-parts    indexed.date-time indexed.timestamp reference-count
#> 1        2015, 12, 27 2015-12-27T23:37:50Z      1.451259e+12               0
#> 2        2015, 12, 24 2015-12-24T22:03:23Z      1.450995e+12               0
#> 3        2015, 12, 25 2015-12-25T19:17:30Z      1.451071e+12               0
#> 4        2015, 12, 27 2015-12-27T19:35:51Z      1.451245e+12               0
```

## Meta

* Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.
