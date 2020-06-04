---
title: "Obtain metadata from Crossref Dump"
output: html_notebook
---



### Connect to database


```r
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


```sql
SELECT DISTINCT(ISSN)
FROM `api-project-764811344545.cr_dump_march_20.cr_08_20_expanded` 
WHERE member = '78' AND issued_year BETWEEN 2015 AND 2019
```

### Comparision with Crossref Dump

Journals from hybrid Elsevier list not indexed in Crossref


```r
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

Possible reason:

a) Journal transfer including metadata ownership. Example: Canadian Association of Radiologists Journal (transferred from Elsevier to SAGE Publications as of 2020)


```sql
SELECT member, publisher, COUNT(DISTINCT(doi)) as articles
FROM `api-project-764811344545.cr_dump_march_20.cr_08_20_expanded` 
WHERE container_title = 'Canadian Association of Radiologists Journal'
GROUP BY member, publisher
```




|member |publisher         | articles|
|:------|:-----------------|--------:|
|179    |SAGE Publications |      833|

However, there are cases, where metadata ownership was not fully transferred. Example: Acta Mathematica Scientia (transferred to Springer Nature as of 2019)


```sql
SELECT member, publisher, COUNT(DISTINCT(doi)) as articles
FROM `api-project-764811344545.cr_dump_march_20.cr_08_20_expanded` 
WHERE container_title = 'Acta Mathematica Scientia'
GROUP BY member, publisher
```




|member |publisher                               | articles|
|:------|:---------------------------------------|--------:|
|297    |Springer Science and Business Media LLC |      142|
|78     |Elsevier BV                             |     1596|

b) Journal started in 2020
