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

[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/sckott/apipkgen?branch=master&svg=true)](https://ci.appveyor.com/project/sckott/apipkgen)
[![Travis-CI Build Status](https://travis-ci.org/sckott/apipkgen.svg?branch=master)](https://travis-ci.org/)
 [![codecov](https://codecov.io/gh/sckott/apipkgen/branch/master/graph/badge.svg)](https://codecov.io/gh/sckott/apipkgen)
[![rstudio mirror downloads](http://cranlogs.r-pkg.org/badges/apipkgen?color=blue)](https://github.com/metacran/cranlogs.app)


```r
remotes::install_github("sckott/apipkgen")
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


### Example 1

Get a spec, in this case from the Province of British Columbia <https://github.com/bcgov/api-specs>


```r
bc_spec <- 
  "https://raw.githubusercontent.com/bcgov/api-specs/master/bcgnws/bcgnws.json"
bc_spec_path <- "bcgov_bcgnws.yaml"
download.file(bc_spec, bc_spec_path)
```

Generate the package, and install it


```r
generate_pkg(
  pkg_path = "bcgov/", 
  template_path = bc_spec_path
)
devtools::document("bcgov")
#> Writing NAMESPACE
#> Writing NAMESPACE
#> Writing bcgov-package.Rd
#> Writing names_search.Rd
#> Writing names_official_search.Rd
#> Writing names_notOfficial_search.Rd
#> Writing names_inside.Rd
#> Writing names_near.Rd
#> Writing names_decisions_recent.Rd
#> Writing names_decisions_year.Rd
#> Writing names_changes.Rd
#> Writing names_nameId.outputFormat.Rd
#> Writing features_featureId.Rd
#> Writing featureClasses.Rd
#> Writing featureCategories.Rd
#> Writing featureTypes.Rd
#> Writing nameAuthorities.Rd
devtools::install_local("bcgov", force = TRUE, quiet = TRUE)
```

Restart R ...

Get man page for a function


```r
?bcgov::nameAuthorities
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

cleanup


```r
unlink("bcgov", TRUE, TRUE)
unlink(bc_spec_path, TRUE)
remove.packages("bcgov")
```

### Example 2

An example with the [Directory of Open Access Journals](https://doaj.org/)


```r
doaj_spec <- "https://doaj.org/api/v1/swagger.json"
doaj_spec_path <- "doaj.json"
download.file(doaj_spec, doaj_spec_path)
```

Generate the package, and install it


```r
generate_pkg(
  pkg_path = "doaj/", 
  template_path = doaj_spec_path,
  base_url = "https://doaj.org"
)
devtools::document("doaj")
#> Writing NAMESPACE
#> Writing NAMESPACE
#> Writing doaj-package.Rd
#> Writing api_v1_applications_application_id.Rd
#> Writing api_v1_articles_article_id.Rd
#> Writing api_v1_journals_journal_id.Rd
#> Writing api_v1_search_applications_search_query.Rd
#> Writing api_v1_search_articles_search_query.Rd
#> Writing api_v1_search_journals_search_query.Rd
devtools::install_local("doaj", force = TRUE, quiet = TRUE)
```

Run a function


```r
doaj::api_v1_search_journals_search_query("cellular")
#> [1] "{\"last\": \"https://doaj.org/api/v1/search/journals/cellular?page=4&pageSize=10\", \"pageSize\": 10, \"timestamp\": \"2019-0306T17:59:07Z\", \"results\": [{\"admin\": {\"ticked\": true, \"seal\": true}, \"last_updated\": \"2018-05-10T09:57:58Z\", \"id\": \"0a1162bd5eb04ffb98e6f5209659f65a\", \"bibjson\": {\"allows_fulltext_indexing\": true, \"archiving_policy\": {\"url\": \"http://www.pagepress.org/publishing-services/digital-preservation.html\", \"known\": [\"Portico\"]}, \"persistent_identifier_scheme\": [\"DOI\"], \"keywords\": [\"MAP kinases\", \"biological functions\", \"cellular processes\"], \"deposit_policy\": [\"Sherpa/Romeo\"], \"article_statistics\": {\"url\": \"http://www.pagepressjournals.org/index.php/mk/pages/view/stats\", \"statistics\": true}, \"title\": \"MAP Kinase\", \"publication_time\": 10, \"provider\": \"OJS\", \"subject\": [{\"code\": \"QH301-705.5\", \"term\": \"Biology (General)\", \"scheme\": \"LCC\"}], \"format\": [\"PDF\", \"XML\"], \"plagiarism_detection\": {\"detection\": true, \"url\": \"http://www.pagepressjournals.org/index.php/mk/pages/view/plagiarism\"}, \"apc_url\": \"http://www.pagepressjournals.org/index.php/mk/pages/view/payments\", \"link\": [{\"url\": \"http://www.mapkinase.org\", \"type\": \"homepage\"}, {\"url\": \"http://www.pagepress.org/publications/authors_fee.html\", \"type\": \"waiver_policy\"}, {\"url\": \"http://www.pagepressjournals.org/index.php/mk/pages/view/eb\", \"type\": \"editorial_board\"}, {\"url\": \"http://www.pagepressjournals.org/index.php/mk/about/editorialPolicies#focusAndScope\", \"type\": \"aims_scope\"}, {\"url\": \"http://www.pagepressjournals.org/index.php/mk/about/submissions#authorGuidelines\", \"type\": \"author_instructions\"}, {\"url\": \"http://www.pagepress.org/open-access.html\", \"type\": \"oa_statement\"}], \"active\": true, \"oa_start\": {\"year\": 2012}, \"editorial_review\": {\"process\": \"Blind peer review\", \"url\": \"http://www.pagepressjournals.org/index.php/mk/about/editorialPolicies#peerReviewProcess\"}, \"author_copyright\": {\"url\": \"http://www.pagepressjournals.org/index.php/mk/about/submissions#copyrightNotice\", \"copyright\": \"True\"}, \"publisher\": \"PAGEPress Publications\", \"language\": [\"EN\"], \"license\": [{\"open_access\": true, \"embedded\": true, \"title\": \"CC BY-NC\", \"url\": \"http://www.pagepressjournals.org/index.php/mk/about/submissions#copyrightNotice\", \"NC\": true, \"ND\": false, \"embedded_example_url\": \"http://www.pagepressjournals.org/index.php/mk/article/view/5700\", \"SA\": false, \"type\": \"CC BY-NC\", \"BY\": true}], \"alternative_title\": \"MK\", \"country\": \"IT\", \"submission_charges_url\": \"http://www.pagepressjournals.org/index.php/mk/pages/view/payments\", \"author_publishing_rights\": {\"url\": \"http://www.pagepressjournals.org/index.php/mk/about/submissions#copyrightNotice\", \"publishing_rights\": \"True\"}, \"identifier\": [{\"type\": \"eissn\", \"id\": \"2235-4956\"}]}, \"created_date\": \"2016-02-02T10:13:15Z\"}, {\"admin\": {\"ticked\": true, \"seal\": true}, \"last_updated\": \"2018-06-25T10:06:29Z\", \"id\": \"0bc2ff6a53704d259752f6ff11aac7d1\", \"bibjson\": {\"allows_fulltext_indexing\": true, \"archiving_policy\": {\"url\": \"http://www.frontiersin.org/Cellular_and_Infection_Microbiology/about\", \"known\": [\"PMC/Europe PMC/PMC Canada\"]}, \"persistent_identifier_scheme\": [\"DOI\"], \"keywords\": [\"microbiology\", \"microbes\", \"immune responses\", \"cell biology\"], \"apc\": {\"currency\": \"USD\", \"average_price\": 2950}, \"subject\": [{\"code\": \"QR1-502\", \"term\": \"Microbiology\", \"scheme\": \"LCC\"}], \"article_statistics\": {\"url\": \"http://journal.frontiersin.org/Journal/10.3389/fcimb.2014.00127/impact#impact\", \"statistics\": true}, \"title\": \"Frontiers in Cellular and Infection Microbiology\", \"publication_time\": 14, \"format\": [\"PDF\", \"HTML\", \"XML\"], \"plagiarism_detection\": {\"detection\": true, \"url\": \"http://www.frontiersin.org/Cellular_and_Infection_Microbiology/reviewguidelines\"}, \"apc_url\": \"http://home.frontiersin.org/about/publishing-fees\", \"link\": [{\"url\": \"http://www.frontiersin.org/Cellular_and_Infection_Microbiology\", \"type\": \"homepage\"}, {\"url\": \"http://home.frontiersin.org/about/publishing-fees\", \"type\": \"waiver_policy\"}, {\"url\": \"http://www.frontiersin.org/Cellular_and_Infection_Microbiology/editorialboard\", \"type\": \"editorial_board\"}, {\"url\": \"http://www.frontiersin.org/Cellular_and_Infection_Microbiology/about\", \"type\": \"aims_scope\"}, {\"url\": \"http://www.frontiersin.org/Cellular_and_Infection_Microbiology/authorguidelines\", \"type\": \"author_instructions\"}, {\"url\": \"http://www.frontiersin.org/Cellular_and_Infection_Microbiology/about\", \"type\": \"oa_statement\"}], \"oa_start\": {\"year\": 2011}, \"editorial_review\": {\"process\": \"Blind peer review\", \"url\": \"http://www.frontiersin.org/Cellular_and_Infection_Microbiology/reviewguidelines\"}, \"author_copyright\": {\"url\": \"http://journal.frontiersin.org/journal/cellular-and-infection-microbiology#about\", \"copyright\": \"True\"}, \"publisher\": \"Frontiers Media S.A.\", \"language\": [\"EN\"], \"license\": [{\"open_access\": true, \"embedded\": false, \"title\": \"CC BY\", \"url\": \"http://journal.frontiersin.org/journal/cellular-and-infection-microbiology#about\", \"NC\": false, \"ND\": false, \"embedded_example_url\": \"\", \"SA\": false, \"type\": \"CC BY\", \"BY\": true}], \"country\": \"CH\", \"submission_charges_url\": \"http://home.frontiersin.org/about/publishing-fees\", \"author_publishing_rights\": {\"url\": \"http://journal.frontiersin.org/journal/cellular-and-infection-microbiology#about\", \"publishing_rights\": \"True\"}, \"identifier\": [{\"type\": \"eissn\", \"id\": \"2235-2988\"}]}, \"created_date\": \"2016-01-21T19:36:21Z\"}, {\"admin\": {\"ticked\": true, \"seal\": true}, \"last_updated\": \"2018-03-12T14:36:20Z\", \"id\": \"0c30df10df9b4d8882f1a890a05d8a5d\", \"bibjson\": {\"allows_fulltext_indexing\": true, \"archiving_policy\": {\"url\": \"https://www.hindawi.com/journals/misy/ai/\", \"known\": [\"LOCKSS\", \"Portico\"]}, \"persistent_identifier_scheme\": [\"DOI\"], \"keywords\": [\"mobile computing\", \"tablets\", \"cellular phone\", \"mobile telecommunications\", \"mobile network\", \"mobile information systems\"], \"apc\": {\"currency\": \"USD\", \"average_price\": 1250}, \"deposit_policy\": [\"Sherpa/Romeo\"], \"article_statistics\": {\"url\": \"\", \"statistics\": false}, \"title\": \"Mobile Information Systems \", \"publication_time\": 48, \"subject\": [{\"code\": \"TK5101-6720\", \"term\": \"Telecommunication\", \"scheme\": \"LCC\"}], \"format\": [\"PDF\", \"HTML\", \"ePUB\"], \"plagiarism_detection\": {\"detection\": true, \"url\": \"https://www.hindawi.com/journals/misy/ethics/\"}, \"apc_url\": \"https://www.hindawi.com/journals/misy/apc/\", \"link\": [{\"url\": \"https://www.hindawi.com/journals/misy/\", \"type\": \"homepage\"}, {\"url\": \"https://www.hindawi.com/journals/misy/apc/\", \"type\": \"waiver_policy\"}, {\"url\": \"https://www.hindawi.com/journals/misy/editors/\", \"type\": \"editorial_board\"}, {\"url\": \"https://www.hindawi.com/journals/misy/aims/\", \"type\": \"aims_scope\"}, {\"url\": \"https://www.hindawi.com/journals/misy/guidelines/\", \"type\": \"author_instructions\"}, {\"url\": \"https://www.hindawi.com/journals/misy/\", \"type\": \"oa_statement\"}], \"oa_start\": {\"year\": 2005}, \"editorial_review\": {\"process\": \"Blind peer review\", \"url\": \"https://www.hindawi.com/journals/misy/workflow/\"}, \"author_copyright\": {\"url\": \"https://www.hindawi.com/journals/misy/guidelines/\", \"copyright\": \"True\"}, \"publisher\": \"Hindawi Limited\", \"language\": [\"EN\"], \"license\": [{\"open_access\": true, \"embedded\": true, \"title\": \"CC BY\", \"url\": \"https://www.hindawi.com/journals/misy/guidelines/\", \"NC\": false, \"ND\": false, \"embedded_example_url\": \"https://www.hindawi.com/journals/misy/2015/372315/\", \"SA\": false, \"type\": \"CC BY\", \"BY\": true}], \"country\": \"GB\", \"submission_charges_url\": \"https://www.hindawi.com/journals/misy/apc/\", \"author_publishing_rights\": {\"url\": \"https://www.hindawi.com/journals/misy/guidelines/\", \"publishing_rights\": \"True\"}, \"identifier\": [{\"type\": \"pissn\", \"id\": \"1574-017X\"}, {\"type\": \"eissn\", \"id\": \"1875-905X\"}]}, \"created_date\": \"2015-03-25T19:20:17Z\"}, {\"admin\": {\"ticked\": true, \"seal\": false}, \"last_updated\": \"2018-05-10T09:59:07Z\", \"id\": \"180d5313996244e6a34e962887bceca3\", \"bibjson\": {\"allows_fulltext_indexing\": true, \"archiving_policy\": {\"url\": \"http://www.smartscitech.com/index.php/MCE/about/editorialPolicies#archiving\", \"known\": [\"LOCKSS\", \"PMC/Europe PMC/PMC Canada\"]}, \"persistent_identifier_scheme\": [\"DOI\"], \"keywords\": [\"Epilepsy\"], \"apc\": {\"currency\": \"USD\", \"average_price\": 1280}, \"deposit_policy\": [\"Sherpa/Romeo\"], \"article_statistics\": {\"url\": \"\", \"statistics\": false}, \"title\": \"Molecular & Cellular Epilepsy\", \"publication_time\": 6, \"provider\": \"OJS\", \"subject\": [{\"code\": \"R\", \"term\": \"Medicine\", \"scheme\": \"LCC\"}], \"format\": [\"PDF\"], \"plagiarism_detection\": {\"detection\": true, \"url\": \"http://www.smartscitech.com/index.php/MCE/about/editorialPolicies#custom-1\"}, \"apc_url\": \"http://www.smartscitech.com/index.php/MCE/about/editorialPolicies#custom-8\", \"link\": [{\"url\": \"http://www.smartscitech.com/index.php/MCE/index\", \"type\": \"homepage\"}, {\"url\": \"http://www.smartscitech.com/index.php/MCE/about/editorialTeam\", \"type\": \"editorial_board\"}, {\"url\": \"http://www.smartscitech.com/index.php/MCE/about/editorialPolicies#focusAndScope\", \"type\": \"aims_scope\"}, {\"url\": \"http://www.smartscitech.com/index.php/MCE/about/submissions#authorGuidelines\", \"type\": \"author_instructions\"}, {\"url\": \"http://www.smartscitech.com/index.php/MCE/about/editorialPolicies#openAccessPolicy\", \"type\": \"oa_statement\"}], \"oa_start\": {\"year\": 2014}, \"editorial_review\": {\"process\": \"Peer review\", \"url\": \"http://www.smartscitech.com/index.php/MCE/about/editorialPolicies#peerReviewProcess\"}, \"author_copyright\": {\"url\": \"http://www.smartscitech.com/index.php/MCE/about/submissions#copyrightNotice\", \"copyright\": \"True\"}, \"publisher\": \"Smart Science & Technology LLC\", \"language\": [\"EN\"], \"license\": [{\"open_access\": true, \"embedded\": true, \"title\": \"CC BY\", \"url\": \"http://www.smartscitech.com/index.php/MCE/about/submissions#copyrightNotice\", \"NC\": false, \"ND\": false, \"embedded_example_url\": \"http://www.smartscitech.com/index.php/MCE/article/view/524\", \"SA\": false, \"type\": \"CC BY\", \"BY\": true}], \"country\": \"US\", \"submission_charges_url\": \"http://www.smartscitech.com/index.php/MCE/about/editorialPolicies#custom-8\", \"author_publishing_rights\": {\"url\": \"http://www.smartscitech.com/index.php/MCE/about/submissions#copyrightNotice\", \"publishing_rights\": \"True\"}, \"identifier\": [{\"type\": \"eissn\", \"id\": \"2330-3891\"}]}, \"created_date\": \"2016-02-23T10:21:16Z\"}, {\"admin\": {\"ticked\": true, \"seal\": false}, \"last_updated\": \"2018-05-10T09:59:20Z\", \"id\": \"1b134158ab904c83ad88870715fbd510\", \"bibjson\": {\"allows_fulltext_indexing\": true, \"archiving_policy\": {\"url\": \"https://www.hindawi.com/journals/acp/ai/\", \"known\": [\"PMC/Europe PMC/PMC Canada\"], \"nat_lib\": \"Koninklijke Bibliotheek\"}, \"persistent_identifier_scheme\": [\"DOI\"], \"keywords\": [\"cytopathology\", \"cytology\", \"pathology\"], \"apc\": {\"currency\": \"USD\", \"average_price\": 1250}, \"deposit_policy\": [\"Sherpa/Romeo\"], \"is_replaced_by\": [\"1875-8606\"], \"article_statistics\": {\"url\": \"https://www.hindawi.com/journals/acp/2015/313145/\", \"statistics\": true}, \"title\": \"Analytical Cellular Pathology\", \"publication_time\": 16, \"provider\": \"Hindawi\", \"subject\": [{\"code\": \"RC254-282\", \"term\": \"Neoplasms. Tumors. Oncology. Including cancer and carcinogens\", \"scheme\": \"LCC\"}, {\"code\": \"QH573-671\", \"term\": \"Cytology\", \"scheme\": \"LCC\"}], \"format\": [\"PDF\", \"HTML\", \"ePUB\", \"XML\"], \"plagiarism_detection\": {\"detection\": true, \"url\": \"https://www.hindawi.com/journals/acp/ethics/\"}, \"apc_url\": \"https://www.hindawi.com/journals/acp/apc/\", \"link\": [{\"url\": \"https://www.hindawi.com/journals/acp/\", \"type\": \"homepage\"}, {\"url\": \"https://www.hindawi.com/journals/acp/apc/\", \"type\": \"waiver_policy\"}, {\"url\": \"https://www.hindawi.com/journals/acp/editors/\", \"type\": \"editorial_board\"}, {\"url\": \"https://www.hindawi.com/journals/acp/aims/\", \"type\": \"aims_scope\"}, {\"url\": \"https://www.hindawi.com/journals/acp/guidelines/\", \"type\": \"author_instructions\"}, {\"url\": \"https://www.hindawi.com/journals/acp/\", \"type\": \"oa_statement\"}], \"oa_start\": {\"year\": 1997}, \"editorial_review\": {\"process\": \"Blind peer review\", \"url\": \"https://www.hindawi.com/journals/acp/workflow/\"}, \"author_copyright\": {\"url\": \"https://www.hindawi.com/journals/acp/guidelines/\", \"copyright\": \"True\"}, \"publisher\": \"Hindawi Limited\", \"language\": [\"EN\"], \"license\": [{\"open_access\": true, \"embedded\": true, \"title\": \"CC BY\", \"url\": \"https://www.hindawi.com/journals/acp/guidelines/\", \"NC\": false, \"ND\": false, \"embedded_example_url\": \"https://www.hindawi.com/journals/acp/2015/313145/\", \"SA\": false, \"type\": \"CC BY\", \"BY\": true}], \"country\": \"GB\", \"submission_charges_url\": \"https://www.hindawi.com/journals/acp/apc/\", \"author_publishing_rights\": {\"url\": \"https://www.hindawi.com/journals/acp/guidelines/\", \"publishing_rights\": \"True\"}, \"identifier\": [{\"type\": \"pissn\", \"id\": \"0921-8912\"}, {\"type\": \"eissn\", \"id\": \"1878-3651\"}]}, \"created_date\": \"2016-09-29T18:53:43Z\"}, {\"admin\": {\"ticked\": true, \"seal\": true}, \"last_updated\": \"2018-05-10T09:59:51Z\", \"id\": \"21ba5e42f0c0462d996660b6a5aa8ee6\", \"bibjson\": {\"allows_fulltext_indexing\": true, \"archiving_policy\": {\"url\": \"https://www.hindawi.com/journals/mi/ai/\", \"known\": [\"LOCKSS\", \"Portico\", \"PMC/Europe PMC/PMC Canada\"]}, \"persistent_identifier_scheme\": [\"DOI\"], \"keywords\": [\"cellular mediators\"], \"apc\": {\"currency\": \"USD\", \"average_price\": 2000}, \"deposit_policy\": [\"Sherpa/Romeo\"], \"article_statistics\": {\"url\": \"\", \"statistics\": false}, \"title\": \"Mediators of Inflammation\", \"publication_time\": 20, \"provider\": \"Hindawi\", \"subject\": [{\"code\": \"RB1-214\", \"term\": \"Pathology\", \"scheme\": \"LCC\"}], \"format\": [\"PDF\", \"HTML\", \"ePUB\", \"XML\"], \"plagiarism_detection\": {\"detection\": true, \"url\": \"https://www.hindawi.com/journals/mi/ethics/\"}, \"apc_url\": \"https://www.hindawi.com/journals/mi/apc/\", \"link\": [{\"url\": \"https://www.hindawi.com/journals/mi\", \"type\": \"homepage\"}, {\"url\": \"https://www.hindawi.com/journals/mi/apc/\", \"type\": \"waiver_policy\"}, {\"url\": \"https://www.hindawi.com/journals/mi/editors/\", \"type\": \"editorial_board\"}, {\"url\": \"https://www.hindawi.com/journals/mi/aims/\", \"type\": \"aims_scope\"}, {\"url\": \"https://www.hindawi.com/journals/mi/guidelines/\", \"type\": \"author_instructions\"}, {\"url\": \"https://www.hindawi.com/journals/mi/\", \"type\": \"oa_statement\"}], \"oa_start\": {\"year\": 1992}, \"editorial_review\": {\"process\": \"Blind peer review\", \"url\": \"https://www.hindawi.com/journals/mi/workflow/\"}, \"author_copyright\": {\"url\": \"https://www.hindawi.com/journals/mi/guidelines/\", \"copyright\": \"True\"}, \"publisher\": \"Hindawi Limited\", \"language\": [\"EN\"], \"license\": [{\"open_access\": true, \"embedded\": true, \"title\": \"CC BY\", \"url\": \"https://www.hindawi.com/journals/mi/guidelines/\", \"NC\": false, \"ND\": false, \"embedded_example_url\": \"https://www.hindawi.com/journals/mi/2015/569714/\", \"SA\": false, \"type\": \"CC BY\", \"BY\": true}], \"country\": \"GB\", \"submission_charges_url\": \"https://www.hindawi.com/journals/mi/apc/\", \"author_publishing_rights\": {\"url\": \"https://www.hindawi.com/journals/mi/guidelines/\", \"publishing_rights\": \"True\"}, \"identifier\": [{\"type\": \"pissn\", \"id\": \"0962-9351\"}, {\"type\": \"eissn\", \"id\": \"1466-1861\"}]}, \"created_date\": \"2002-06-21T08:43:19Z\"}, {\"admin\": {\"ticked\": true, \"seal\": false}, \"last_updated\": \"2018-05-10T09:59:54Z\", \"id\": \"22522750baed42d8b50ce95b1e1eb02e\", \"bibjson\": {\"allows_fulltext_indexing\": true, \"archiving_policy\": {\"url\": \"http://www.wileyauthors.com/openaccess\", \"known\": [\"CLOCKSS\", \"Portico\", \"PMC/Europe PMC/PMC Canada\"]}, \"author_publishing_rights\": {\"url\": \"http://stemcellsjournals.onlinelibrary.wiley.com/hub/journal/10.1002/(ISSN)2157-6580/about/information-for-authors.html\", \"publishing_rights\": \"True\"}, \"keywords\": [\"cellular therapy\", \"clinical translation\", \"regenerative medicine\", \"tissue engineering\", \"gene therapy\"], \"apc\": {\"currency\": \"USD\", \"average_price\": 1750}, \"deposit_policy\": [\"Sherpa/Romeo\"], \"article_statistics\": {\"url\": \"\", \"statistics\": false}, \"title\": \"Stem Cells Translational Medicine\", \"publication_time\": 24, \"provider\": \"Wiley Online Library\", \"subject\": [{\"code\": \"R5-920\", \"term\": \"Medicine (General)\", \"scheme\": \"LCC\"}, {\"code\": \"QH573-671\", \"term\": \"Cytology\", \"scheme\": \"LCC\"}], \"format\": [\"PDF\", \"HTML\"], \"plagiarism_detection\": {\"detection\": true, \"url\": \"http://stemcellsjournals.onlinelibrary.wiley.com/hub/journal/10.1002/(ISSN)2157-6580/about/information-for-authors.html\"}, \"apc_url\": \"http://www.wileyopenaccess.com/details/content/12f25e0654f/Publication-Charges.html\", \"link\": [{\"url\": \"http://stemcellsjournals.onlinelibrary.wiley.com/hub/journal/10.1002/(ISSN)2157-6580/\", \"type\": \"homepage\"}, {\"url\": \"http://stemcellsjournals.onlinelibrary.wiley.com/hub/journal/10.1002/(ISSN)2157-6580/editorial-board/editorial-board.html\", \"type\": \"editorial_board\"}, {\"url\": \"http://stemcellsjournals.onlinelibrary.wiley.com/hub/journal/10.1002/(ISSN)2157-6580/about/information-for-authors.html\", \"type\": \"aims_scope\"}, {\"url\": \"http://stemcellsjournals.onlinelibrary.wiley.com/hub/journal/10.1002/(ISSN)2157-6580/about/information-for-authors.html\", \"type\": \"author_instructions\"}, {\"url\": \"http://stemcellsjournals.onlinelibrary.wiley.com/hub/journal/10.1002/(ISSN)2157-6580/about/information-for-authors.html\", \"type\": \"oa_statement\"}], \"active\": true, \"oa_start\": {\"year\": 2012}, \"editorial_review\": {\"process\": \"Blind peer review\", \"url\": \"http://stemcellsjournals.onlinelibrary.wiley.com/hub/journal/10.1002/(ISSN)2157-6580/about/information-for-authors.html\"}, \"author_copyright\": {\"url\": \"http://stemcellsjournals.onlinelibrary.wiley.com/hub/journal/10.1002/(ISSN)2157-6580/about/information-for-authors.html\", \"copyright\": \"True\"}, \"institution\": \"AlphaMed Press\", \"publisher\": \"Wiley\", \"language\": [\"EN\"], \"license\": [{\"open_access\": true, \"embedded\": true, \"title\": \"CC BY-NC-ND\", \"url\": \"http://stemcellsjournals.onlinelibrary.wiley.com/hub/journal/10.1002/(ISSN)2157-6580/about/information-for-authors.html\", \"NC\": true, \"ND\": true, \"embedded_example_url\": \"http://onlinelibrary.wiley.com/enhanced/doi/10.1002/btm2.10003/\", \"SA\": false, \"type\": \"CC BY-NC-ND\", \"BY\": true}], \"country\": \"US\", \"submission_charges_url\": \"http://stemcellsjournals.onlinelibrary.wiley.com/hub/publishing-information.html\", \"persistent_identifier_scheme\": [\"DOI\"], \"identifier\": [{\"type\": \"eissn\", \"id\": \"2157-6580\"}]}, \"created_date\": \"2017-11-21T14:55:37Z\"}, {\"admin\": {\"ticked\": true, \"seal\": false}, \"last_updated\": \"2018-05-10T10:00:10Z\", \"id\": \"254b76f2f45d4d5eabfe5775e973f6ca\", \"bibjson\": {\"allows_fulltext_indexing\": false, \"persistent_identifier_scheme\": [\"DOI\"], \"keywords\": [\"translational medicine\", \"anesthesia\", \"cellular and molecular aspects of anesthesiology\"], \"subject\": [{\"code\": \"RD78.3-87.3\", \"term\": \"Anesthesiology\", \"scheme\": \"LCC\"}], \"article_statistics\": {\"url\": \"\", \"statistics\": false}, \"title\": \"Journal of Cellular and Molecular Anesthesia\", \"publication_time\": 6, \"provider\": \"OJS\", \"format\": [\"PDF\", \"XML\"], \"plagiarism_detection\": {\"detection\": false, \"url\": \"\"}, \"apc_url\": \"http://journals.sbmu.ac.ir/jcma/about/submissions#authorGuidelines\", \"link\": [{\"url\": \"http://journals.sbmu.ac.ir/jcma/index\", \"type\": \"homepage\"}, {\"url\": \"http://journals.sbmu.ac.ir/jcma/about/displayMembership/402\", \"type\": \"editorial_board\"}, {\"url\": \"http://journals.sbmu.ac.ir/jcma/about/editorialPolicies#focusAndScope\", \"type\": \"aims_scope\"}, {\"url\": \"http://journals.sbmu.ac.ir/jcma/about/submissions#authorGuidelines\", \"type\": \"author_instructions\"}, {\"url\": \"http://journals.sbmu.ac.ir/jcma/about/editorialPolicies#openAccessPolicy\", \"type\": \"oa_statement\"}], \"oa_start\": {\"year\": 2016}, \"editorial_review\": {\"process\": \"Double blind peer review\", \"url\": \"http://journals.sbmu.ac.ir/jcma/about/editorialPolicies#peerReviewProcess\"}, \"author_copyright\": {\"url\": \"http://journals.sbmu.ac.ir/jcma/about/submissions#copyrightNotice\", \"copyright\": \"True\"}, \"institution\": \"Anesthesiology Research Center\", \"publisher\": \"Shahid Beheshti University of Medical Sciences\", \"language\": [\"EN\"], \"license\": [{\"open_access\": true, \"embedded\": true, \"title\": \"CC BY\", \"url\": \"http://journals.sbmu.ac.ir/jcma/about/submissions#copyrightNotice\", \"NC\": false, \"ND\": false, \"embedded_example_url\": \"http://journals.sbmu.ac.ir/jcma/article/view/10638/8263\", \"SA\": false, \"type\": \"CC BY\", \"BY\": true}], \"country\": \"IR\", \"submission_charges_url\": \"http://journals.sbmu.ac.ir/jcma/about/submissions#authorGuidelines\", \"author_publishing_rights\": {\"url\": \"http://journals.sbmu.ac.ir/jcma/about/submissions#copyrightNotice\", \"publishing_rights\": \"True\"}, \"identifier\": [{\"type\": \"pissn\", \"id\": \"2538-2462\"}, {\"type\": \"eissn\", \"id\": \"2476-5120\"}]}, \"created_date\": \"2017-11-07T09:59:47Z\"}, {\"admin\": {\"ticked\": true, \"seal\": false}, \"last_updated\": \"2019-01-23T14:12:42Z\", \"id\": \"2d24271f34f745e0a22f2b93b592bd1e\", \"bibjson\": {\"allows_fulltext_indexing\": true, \"archiving_policy\": {\"url\": \"https://elibrary.ru/title_about.asp?id=10182\", \"other\": \"elibrary.ru\"}, \"persistent_identifier_scheme\": [\"DOI\"], \"keywords\": [\"medical biological preparations\", \"biomedical cellular products\", \"vaccine prevention\", \"immunoglobulins\", \"immunotherapy\", \"epidemiology\"], \"subject\": [{\"code\": \"TP248.13-248.65\", \"term\": \"Biotechnology\", \"scheme\": \"LCC\"}, {\"code\": \"R\", \"term\": \"Medicine\", \"scheme\": \"LCC\"}], \"article_statistics\": {\"url\": \"\", \"statistics\": false}, \"title\": \"\\u0411\\u0438\\u043e\\u043f\\u0440\\u0435\\u043f\\u0430\\u0440\\u0430\\u0442\\u044b: \\u041f\\u0440\\u043e\\u0444\\u0438\\u043b\\u0430\\u043a\\u0442\\u0438\\u043a\\u0430, \\u0434\\u0438\\u0430\\u0433\\u043d\\u043e\\u0441\\u0442\\u0438\\u043a\\u0430, \\u043b\\u0435\\u0447\\u0435\\u043d\\u0438\\u0435\", \"publication_time\": 8, \"provider\": \"elpub.ru\", \"format\": [\"PDF\"], \"plagiarism_detection\": {\"detection\": true, \"url\": \"https://www.biopreparations.ru/jour/about/editorialPolicies#custom-6\"}, \"apc_url\": \"https://www.biopreparations.ru/jour/about/editorialPolicies#custom-4\", \"link\": [{\"url\": \"https://www.biopreparations.ru\", \"type\": \"homepage\"}, {\"url\": \"https://www.biopreparations.ru/index.php/jour/pages/view/EditorialS\", \"type\": \"editorial_board\"}, {\"url\": \"https://www.biopreparations.ru/jour/about/editorialPolicies#focusAndScope\", \"type\": \"aims_scope\"}, {\"url\": \"https://www.biopreparations.ru/jour/about/submissions\", \"type\": \"author_instructions\"}, {\"url\": \"https://www.biopreparations.ru/jour/about/editorialPolicies#openAccessPolicy\", \"type\": \"oa_statement\"}], \"oa_start\": {\"year\": 2015}, \"editorial_review\": {\"process\": \"Double blind peer review\", \"url\": \"https://www.biopreparations.ru/jour/about/editorialPolicies#custom-0\"}, \"author_copyright\": {\"url\": \"https://www.biopreparations.ru/jour/about/submissions#copyrightNotice\", \"copyright\": \"True\"}, \"publisher\": \"Ministry of Health of the Russian Federation. Federal State Budgetary Institution \\u00abScientific Centre for Expert Evaluation of Medicinal Products\\u00bb \", \"language\": [\"RU\"], \"license\": [{\"open_access\": true, \"embedded\": true, \"title\": \"CC BY\", \"url\": \"https://www.biopreparations.ru/jour/about/submissions#copyrightNotice\", \"NC\": false, \"ND\": false, \"embedded_example_url\": \"https://www.biopreparations.ru/jour/article/view/171/138\", \"SA\": false, \"type\": \"CC BY\", \"BY\": true}], \"alternative_title\": \"BIOpreparations: Prevention, Diagnosis, Treatment\", \"country\": \"RU\", \"submission_charges_url\": \"https://www.biopreparations.ru/jour/about/editorialPolicies#custom-4\", \"author_publishing_rights\": {\"url\": \"https://www.biopreparations.ru/jour/about/submissions#copyrightNotice\", \"publishing_rights\": \"True\"}, \"identifier\": [{\"type\": \"pissn\", \"id\": \"2221-996X\"}, {\"type\": \"eissn\", \"id\": \"2619-1156\"}]}, \"created_date\": \"2018-11-07T19:46:46Z\"}, {\"admin\": {\"ticked\": true, \"seal\": false}, \"last_updated\": \"2018-09-25T10:45:32Z\", \"id\": \"30c1c8b253b34ae3ba616e39ac3e4c3c\", \"bibjson\": {\"allows_fulltext_indexing\": true, \"archiving_policy\": {\"url\": \"http://www.nature.com/authors/author_resources/deposition.html\", \"known\": [\"CLOCKSS\"]}, \"persistent_identifier_scheme\": [\"DOI\"], \"keywords\": [\"apoptosis\", \"cancer metabolism\", \"cellular oncogenes\", \"dna\", \"damage and repair\", \"tumour suppression\"], \"apc\": {\"currency\": \"GBP\", \"average_price\": 2600}, \"deposit_policy\": [\"Sherpa/Romeo\"], \"article_statistics\": {\"url\": \"\", \"statistics\": false}, \"title\": \"Oncogenesis\", \"publication_time\": 26, \"provider\": \"Nature.com\", \"subject\": [{\"code\": \"RC254-282\", \"term\": \"Neoplasms. Tumors. Oncology. Including cancer and carcinogens\", \"scheme\": \"LCC\"}], \"format\": [\"PDF\", \"HTML\"], \"plagiarism_detection\": {\"detection\": true, \"url\": \"http://www.nature.com/oncsis/guide_for_authors.pdf\"}, \"apc_url\": \"http://www.nature.com/oncsis/about/open_access.html\", \"link\": [{\"url\": \"http://www.nature.com/oncsis/index.html\", \"type\": \"homepage\"}, {\"url\": \"http://www.nature.com/oncsis/about/open_access.html\", \"type\": \"waiver_policy\"}, {\"url\": \"http://www.nature.com/oncsis/about/index.html\", \"type\": \"editorial_board\"}, {\"url\": \"http://www.nature.com/oncsis/about/index.html\", \"type\": \"aims_scope\"}, {\"url\": \"http://www.nature.com/oncsis/guide_for_authors.pdf\", \"type\": \"author_instructions\"}, {\"url\": \"http://www.nature.com/oncsis/about/open_access.html\", \"type\": \"oa_statement\"}], \"oa_start\": {\"year\": 2012}, \"editorial_review\": {\"process\": \"Blind peer review\", \"url\": \"http://www.nature.com/oncsis/guide_for_authors.pdf\"}, \"author_copyright\": {\"url\": \"http://www.nature.com/authors/policies/license.html\", \"copyright\": \"False\"}, \"publisher\": \"Nature Publishing Group\", \"language\": [\"EN\"], \"license\": [{\"open_access\": true, \"embedded\": true, \"title\": \"CC BY-NC-ND\", \"url\": \"http://www.nature.com/oncsis/about/open_access.html\", \"NC\": true, \"ND\": true, \"embedded_example_url\": \"http://www.nature.com/oncsis/journal/v4/n1/full/oncsis201450a.html\", \"SA\": false, \"type\": \"CC BY-NC-ND\", \"BY\": true}], \"country\": \"GB\", \"submission_charges_url\": \"http://www.nature.com/oncsis/about/open_access.html\", \"author_publishing_rights\": {\"url\": \"http://www.nature.com/authors/policies/license.html\", \"publishing_rights\": \"False\"}, \"identifier\": [{\"type\": \"eissn\", \"id\": \"2157-9024\"}]}, \"created_date\": \"2013-05-01T16:27:02Z\"}], \"next\": \"https://doaj.org/api/v1/search/journals/cellular?page=2&pageSize=10\", \"query\": \"cellular\", \"total\": 39, \"page\": 1}"
```

cleanup


```r
unlink("doaj", TRUE, TRUE)
unlink(doaj_spec_path, TRUE)
remove.packages("doaj")
```


## Citation

Get citation information for `apipkgen` in R by running: `citation(package = 'apipkgen')`

## Code of Conduct

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md).
By participating in this project you agree to abide by its terms.

