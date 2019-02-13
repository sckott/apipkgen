apipkgen
========

[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)
![GitHub 0.0.1.9310](https://img.shields.io/badge/GitHub-_0.0.1.9310-blue.svg)


Generate a HTTP API wrapper package from a yaml template for the API

The internals are a little hacky, but the point is to have as few dependencies as possible, just depending on `yaml` right now.

### Steps

* Specify API in a YAML file
* Run `apipkgen::generate_pkg()` to generate a package
* Write wrapper functions in the new package
* Done!

### Features

* Package generation from a yaml template
* gives back raw text right now, will add toggles to add JSON vs. XML parsers
* specify query parameters, including options, whether required or not, and expected class
* same as previous, but for paths on the base URL

## Package Status and Installation

[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/ropensci/apipkgen?branch=master&svg=true)](https://ci.appveyor.com/project/ropensci/apipkgen)
[![Travis-CI Build Status](https://travis-ci.org/ropensci/apipkgen.svg?branch=master)](https://travis-ci.org/)
 [![codecov](https://codecov.io/gh/RMHogervorst/apipkgen/branch/master/graph/badge.svg)](https://codecov.io/gh/RMHogervorst/apipkgen)
[![rstudio mirror downloads](http://cranlogs.r-pkg.org/badges/apipkgen?color=blue)](https://github.com/metacran/cranlogs.app)

__Installation Instructions__

__Development Version__
```r
devtools::install_github("ropenscilabs/apipkgen")
```


```r
library("apipkgen")
```

## Usage
### generate a package

use the function `generate_pkg()`


```r
template <- system.file('examples', 'template_crossref.yml', package = "apipkgen")
apipkgen::generate_pkg("../crpkg", template_path = template)
```

### Use package

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

## Citation

Get citation information for `apipkgen` in R by running: `citation(package = 'apipkgen')`

## Code of Conduct

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md).
By participating in this project you agree to abide by its terms.



[![ropensci_footer](https://ropensci.org/public_images/github_footer.png)](https://ropensci.org)
