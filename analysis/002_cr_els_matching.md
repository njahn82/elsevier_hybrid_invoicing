Obtain metadata from Crossref Dump
================

### Connect to database

``` r
# connect to google bg where we imported the json lines Unpaywall dump
library(DBI)
library(bigrquery)
con <- dbConnect(
  bigrquery::bigquery(),
  project = "api-project-764811344545",
  dataset = "cr_dump_march_20"
)
```

### Journals associated with Elsevier

Determined by the Crossref member id (78).

``` sql
SELECT DISTINCT(ISSN)
FROM `api-project-764811344545.cr_dump_march_20.cr_08_20_expanded` 
WHERE member = '78' AND issued_year BETWEEN 2015 AND 2019
```

### Comparision with Crossref Dump

Journals from hybrid Elsevier list not indexed in Crossref

``` r
library(tidyverse)
library(here)
els_jns_df <- readr::read_csv(here::here("data", "elsevier_apc_list.csv"))
els_jns_df %>% 
  filter(!issn %in% els_2020_jns$ISSN, oa_type == "Hybrid")
#> # A tibble: 16 x 5
#>    issn      jn_title                                                 oa_type apc_currency   apc
#>    <chr>     <chr>                                                    <chr>   <chr>        <dbl>
#>  1 0155-9982 Accounting Forum                                         Hybrid  USD           1100
#>  2 2666-4305 AJO-DO Clinical Companion                                Hybrid  USD           3000
#>  3 2352-4065 Animal Gene                                              Hybrid  USD           1590
#>  4 2590-2865 Applied Animal Science                                   Hybrid  USD           2500
#>  5 2666-5069 Apunts Sports Medicine                                   Hybrid  USD           3000
#>  6 0846-5371 Canadian Association of Radiologists Journal             Hybrid  USD           1700
#>  7 1001-9294 Chinese Medical Sciences Journal                         Hybrid  USD           3000
#>  8 1881-8366 Engineering in Agriculture, Environment and Food         Hybrid  USD           3000
#>  9 2666-2256 Forensic Imaging                                         Hybrid  USD           2500
#> 10 2666-2817 Forensic Science International: Digital Investigation    Hybrid  USD           2750
#> 11 2590-2415 French Journal of Psychiatry                             Hybrid  EUR           1740
#> 12 2214-1677 JCRS Online Case Reports                                 Hybrid  USD           3000
#> 13 2589-9791 Journal of Behavioral and Cognitive Therapy              Hybrid  USD           3000
#> 14 1934-1482 PM&R                                                     Hybrid  USD           3000
#> 15 2590-0307 Techniques and Innovations in Gastrointestinal Endoscopy Hybrid  USD           2500
#> 16 0022-5347 The Journal of Urology                                   Hybrid  USD           3000
```

Possible reasons:

1)  Journal transfer including metadata ownership. Example: Canadian
    Association of Radiologists Journal (transferred from Elsevier to
    SAGE Publications as of 2020)

<!-- end list -->

``` sql
SELECT member, publisher, COUNT(DISTINCT(doi)) as articles
FROM `api-project-764811344545.cr_dump_march_20.cr_08_20_expanded` 
WHERE container_title = 'Canadian Association of Radiologists Journal'
GROUP BY member, publisher
```

<div class="knitsql-table">

| member | publisher         | articles |
| :----- | :---------------- | -------: |
| 179    | SAGE Publications |      833 |

1 records

</div>

However, there are cases, where metadata ownership was not fully
transferred. Example: Acta Mathematica Scientia (transferred to Springer
Nature as of 2019)

``` sql
SELECT member, publisher, COUNT(DISTINCT(doi)) as articles
FROM `api-project-764811344545.cr_dump_march_20.cr_08_20_expanded` 
WHERE container_title = 'Acta Mathematica Scientia'
GROUP BY member, publisher
```

<div class="knitsql-table">

| member | publisher                               | articles |
| :----- | :-------------------------------------- | -------: |
| 78     | Elsevier BV                             |     1596 |
| 297    | Springer Science and Business Media LLC |      142 |

2 records

</div>

2)  Journal started in 2020

### Create Crossref Elsevier subset in BQ

Upload list of Elsevier hybrid journals to BQ.

``` r
els_jns_df <- readr::read_csv(here::here("data", "elsevier_apc_list.csv"))
els_jn_hybrid <- els_jns_df %>% 
  filter(oa_type == "Hybrid")
if(!bq_table_exists("api-project-764811344545.cr_dump_march_20.elshybrid")) {
bq_els <- bq_table_create(
  "api-project-764811344545.cr_dump_march_20.elshybrid",
  fields =  els_jn_hybrid,
  friendly_name = "Elsevier hybrid journals May 2020",
  description = "The data was extracted from Elsevier APC pricing list, 
    downloaded 30 May 2020"
)
bq_table_upload(bq_els, els_jn_hybrid)
} else {
  NULL
}
#> NULL
```

Create table with Crossref metadata for these journals since 2008.

``` sql
CREATE OR REPLACE TABLE `api-project-764811344545.cr_dump_march_20.els_hybrid_cr` AS
SELECT * FROM `api-project-764811344545.cr_dump_march_20.cr_08_20_expanded` as cr
WHERE EXISTS ( 
  SELECT 1 FROM `api-project-764811344545.cr_dump_march_20.elshybrid` as els_hybrid 
  WHERE (cr.issn = els_hybrid.issn)
  )
```

Descriptive:

By members

``` sql
SELECT  member, publisher, COUNT(DISTINCT(doi)) as articles
FROM `api-project-764811344545.cr_dump_march_20.els_hybrid_cr`
WHERE issued_year > 2014 and issued_year < 2020
GROUP BY member, publisher
ORDER BY articles DESC
```

<div class="knitsql-table">

| member | publisher                                                 | articles |
| :----- | :-------------------------------------------------------- | -------: |
| 78     | Elsevier BV                                               |  2804186 |
| 1747   | American Dairy Science Association                        |     4789 |
| 311    | Wiley                                                     |     2740 |
| 276    | Ovid Technologies (Wolters Kluwer Health)                 |     2604 |
| 297    | Springer Science and Business Media LLC                   |     2551 |
| 3285   | Ubiquity Press, Ltd.                                      |     1261 |
| 23476  | Asian Agricultural and Biological Engineering Association |      265 |
| 10543  | Chinese Medical Sciences Journal                          |      219 |
| 219    | World Scientific Pub Co Pte Lt                            |      175 |
| 179    | SAGE Publications                                         |      122 |

Displaying records 1 - 10

</div>

License prevalence

``` sql
SELECT REGEXP_REPLACE(license.URL, "http://|https://", "") as license_url, COUNT(DISTINCT(doi)) as articles
FROM `api-project-764811344545.cr_dump_march_20.els_hybrid_cr`, unnest(license) as license
WHERE issued_year > 2014 and issued_year < 2020 AND license.content_version = 'vor'
GROUP BY license_url
ORDER BY articles DESC
```

<div class="knitsql-table">

| license\_url                                                       | articles |
| :----------------------------------------------------------------- | -------: |
| www.elsevier.com/open-access/userlicense/1.0/                      |   183223 |
| creativecommons.org/licenses/by-nc-nd/4.0/                         |    65971 |
| creativecommons.org/licenses/by/4.0/                               |    30557 |
| onlinelibrary.wiley.com/termsAndConditions\#vor                    |     2010 |
| creativecommons.org/licenses/by-nc-nd/3.0/                         |     1292 |
| creativecommons.org/licenses/by/3.0/                               |      838 |
| creativecommons.org/licenses/by-nc-sa/3.0/                         |      198 |
| www.nationalarchives.gov.uk/doc/open-government-licence/version/3/ |      101 |
| creativecommons.org/licenses/by-nc-nd/3.0/igo/                     |       75 |
| creativecommons.org/licenses/by-nc-sa/4.0/                         |       74 |

Displaying records 1 - 10

</div>

License prevalence by days with delay

``` sql
SELECT 
  REGEXP_REPLACE(license.URL, "http://|https://", "") as license_url,
  license.delay_in_days,
  COUNT(DISTINCT(doi)) as articles
FROM `api-project-764811344545.cr_dump_march_20.els_hybrid_cr`, unnest(license) as license
WHERE issued_year > 2014 and issued_year < 2020 AND license.content_version = 'vor'
GROUP BY license_url, license.delay_in_days
ORDER BY articles DESC
```

Immediate Licenses

``` r
els_license_delay %>%
  filter(delay_in_days == 0)
#> # A tibble: 12 x 3
#>    license_url                                                        delay_in_days articles
#>    <chr>                                                                      <int>    <int>
#>  1 creativecommons.org/licenses/by-nc-nd/4.0/                                     0    37752
#>  2 creativecommons.org/licenses/by/4.0/                                           0    26218
#>  3 creativecommons.org/licenses/by-nc-nd/3.0/                                     0     1164
#>  4 creativecommons.org/licenses/by/3.0/                                           0      805
#>  5 onlinelibrary.wiley.com/termsAndConditions#vor                                 0      398
#>  6 creativecommons.org/licenses/by-nc-sa/3.0/                                     0      195
#>  7 www.nationalarchives.gov.uk/doc/open-government-licence/version/3/             0       91
#>  8 creativecommons.org/licenses/by-nc-nd/3.0/igo/                                 0       65
#>  9 creativecommons.org/licenses/by/3.0/igo/                                       0       59
#> 10 creativecommons.org/licenses/by-nc-sa/4.0/                                     0       46
#> 11 creativecommons.org/licenses/by-nc/4.0/                                        0        2
#> 12 www.elsevier.com/open-access/userlicense/1.0/                                  0        2
```

A few records have a date formats without day, which is used for the
delayed calculation. We should therefore allow for a delay of up to 30
days.

``` r
els_license_delay %>%
  filter(delay_in_days < 31) 
#> # A tibble: 126 x 3
#>    license_url                                    delay_in_days articles
#>    <chr>                                                  <int>    <int>
#>  1 creativecommons.org/licenses/by-nc-nd/4.0/                 0    37752
#>  2 creativecommons.org/licenses/by/4.0/                       0    26218
#>  3 creativecommons.org/licenses/by-nc-nd/3.0/                 0     1164
#>  4 creativecommons.org/licenses/by/3.0/                       0      805
#>  5 onlinelibrary.wiley.com/termsAndConditions#vor            18      501
#>  6 onlinelibrary.wiley.com/termsAndConditions#vor             7      417
#>  7 onlinelibrary.wiley.com/termsAndConditions#vor             0      398
#>  8 onlinelibrary.wiley.com/termsAndConditions#vor            25      383
#>  9 creativecommons.org/licenses/by-nc-nd/4.0/                 3      292
#> 10 creativecommons.org/licenses/by-nc-nd/4.0/                27      272
#> # … with 116 more rows
```

But it seems that also some articles misses months. I will therefore
obtain all cc tagged articles and validate immediate oa provision via
the open archive tag

### Download open access articles in hybrid journals

``` sql
SELECT *
FROM `api-project-764811344545.cr_dump_march_20.els_hybrid_cr`, unnest(license) as license
WHERE (REGEXP_CONTAINS(license.URL, 'creativecommons') AND license.content_version = 'vor') AND 
  (issued_year BETWEEN 2015 and 2019) 
```

Dataset with TDM Links

``` r
els_tdm <- els_hybrid_articles %>%
  select(doi, link) %>%
  unnest(link) %>%
  filter(content_type == "text/xml",
         intended_application == "text-mining",
         content_version == "vor")
write_csv(els_tdm, here::here("data", "els_tmd_links.csv"))
```
