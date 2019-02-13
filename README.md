apipkgen
========



[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)

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

### Example spec

* nytimes <https://github.com/NYTimes/public_api_specs> (requires auth)
* stripe <https://github.com/stripe/openapi> (requires auth)
* Canada's BC government <https://github.com/bcgov/api-specs> (auth not required)

## Package Status and Installation

[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/ropensci/apipkgen?branch=master&svg=true)](https://ci.appveyor.com/project/ropensci/apipkgen)
[![Travis-CI Build Status](https://travis-ci.org/ropenscilabs/apipkgen.svg?branch=master)](https://travis-ci.org/)
 [![codecov](https://codecov.io/gh/ropenscilabs/apipkgen/branch/master/graph/badge.svg)](https://codecov.io/gh/ropensci/apipkgen)
[![rstudio mirror downloads](http://cranlogs.r-pkg.org/badges/apipkgen?color=blue)](https://github.com/metacran/cranlogs.app)


```r
devtools::install_github("ropenscilabs/apipkgen")
```


```r
library("apipkgen")
```

## Simple yml template (not fitting swagger/etc.)

### generate a package

use the function `generate_pkg()`


```r
template <- system.file('examples', 'template_crossref.yml',
    package = "apipkgen")
path <- file.path(tempdir(), "crpkg")
generate_pkg(path, template_path = template)
```

### your package needs functions

The package created doesn't have any exported functions, just internal functions for your to build user facing functions.

Let's write a user facing functions. The Crossref API template above specified for the `works` route that parameters are `query` and `rows`. So let's work with those.


```r
crossref_works <- function(query = NULL, rows = NULL, ...) {
  crpkg::works(query = query, rows = rows, ...)
}
```

In addition, it's a good idea to always allow users to pass in curl options. Beginners can ignore it, but power curl users will want/have to play with curl options. The function builder builds in `...` as a parameter so in the user facing function above all you have to do is add that as well for users to access.

### Install package

Go to the new directory, and in R/RStudio run `devtools::document()` and `devtools::install()` (or equivalent).

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

## Swagger/OpenAPI


Get a spec, in this case from <https://github.com/bcgov/api-specs>



```r
bc_spec <- 
  "https://raw.githubusercontent.com/bcgov/api-specs/master/bcgnws/bcgnws.json"
bc_spec_path <- "bcgov_bcgnws.yaml"
download.file(bc_spec, bc_spec_path)
```

Generate the package, and install it


```r
generate_pkg(
  "bcgov/", 
  template_path = bc_spec_path
)
devtools::install_local("bcgov", force = TRUE, quiet = TRUE)
```

Run some functions


```r
bcgov::nameAuthorities()
#> [1] "{\n \"nameAuthorities\": [\n  {\n   \"id\": \"1\",\n   \"resourceUrl\": \"apps.gov.bc.ca/pub/bcgnws/nameAuthorities/1\",\n   \"nameAuthority\": \"BC Geographical Names Office\",\n   \"webSiteUrl\": \"http://www2.gov.bc.ca/gov/content/governments/celebrating-british-columbia/historic-places/geographical-names\"},\n  {\n   \"id\": \"41\",\n   \"resourceUrl\": \"apps.gov.bc.ca/pub/bcgnws/nameAuthorities/41\",\n   \"nameAuthority\": \"Vancouver, City of\",\n   \"webSiteUrl\": \"http://vancouver.ca/\"},\n  {\n   \"id\": \"2\",\n   \"resourceUrl\": \"apps.gov.bc.ca/pub/bcgnws/nameAuthorities/2\",\n   \"nameAuthority\": \"BC Register of Historic Places\",\n   \"webSiteUrl\": \"http://www2.gov.bc.ca/gov/content/governments/celebrating-british-columbia/historic-places/provincial-federal-registers\"}],\n \"legal\": {\n  \"disclaimerURI\": \"http://www.gov.bc.ca/com/disclaimer.html\",\n  \"privacyURI\": \"http://www.gov.bc.ca/com/privacy.html\",\n  \"copyrightNotice\": \"Copyright (c) 2019, Province of British Columbia\",\n  \"copyrightLicenseURI\": \"http://www.gov.bc.ca/com/copyright.html\"}}"
```


```r
res <- bcgov::names_search(name = "Victoria")
tibble::as_tibble(jsonlite::fromJSON(res)$features)
#> # A tibble: 10 x 3
#>    type  properties$uri $name $language $status $isOfficial
#>    <chr> <chr>          <chr> <chr>     <chr>         <int>
#>  1 Feat… apps.gov.bc.c… Vict… English   adopted           1
#>  2 Feat… apps.gov.bc.c… Vict… English   adopted           1
#>  3 Feat… apps.gov.bc.c… Vict… not defi… adopted           1
#>  4 Feat… apps.gov.bc.c… Vict… not defi… adopted           1
#>  5 Feat… apps.gov.bc.c… Vict… not defi… adopted           1
#>  6 Feat… apps.gov.bc.c… Vict… not defi… adopted           1
#>  7 Feat… apps.gov.bc.c… Vict… not defi… adopted           1
#>  8 Feat… apps.gov.bc.c… Vict… not defi… adopted           1
#>  9 Feat… apps.gov.bc.c… Vict… not defi… adopted           1
#> 10 Feat… apps.gov.bc.c… Vict… not defi… adopted           1
#> # … with 24 more variables: $nameAuthority$resourceUrl <chr>, $$id <chr>,
#> #   $$nameAuthority <chr>, $$webSiteUrl <chr>, $tags <list>, $score <dbl>,
#> #   $feature$id <chr>, $$uuid <chr>, $$uri <chr>, $$mapsheets <chr>,
#> #   $$names <chr>, $changeDate <chr>, $decisionDate <chr>,
#> #   $featureCategory <int>, $featureCategoryDescription <chr>,
#> #   $featureCategoryURI <chr>, $featureType <chr>, $lonAsRecorded <int>,
#> #   $latAsRecorded <int>, $datumAsRecorded <chr>, $position <chr>,
#> #   $ntsMap <chr>, geometry$type <chr>, $coordinates <list>
```


```r
# cleanup
unlink("bcgov", TRUE, TRUE)
unlink(bc_spec_path, TRUE)
remove.packages("bcgov")
```


## Citation

Get citation information for `apipkgen` in R by running: `citation(package = 'apipkgen')`

## Code of Conduct

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md).
By participating in this project you agree to abide by its terms.


[![ropensci_footer](https://ropensci.org/public_images/github_footer.png)](https://ropensci.org)
