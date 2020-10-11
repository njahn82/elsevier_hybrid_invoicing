Obtain Article Volume
================
Najko Jahn
7/7/2020

    ## Warning: replacing previous import 'vctrs::data_frame' by 'tibble::data_frame'
    ## when loading 'dplyr'

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

### Overall article volume per journal and year

``` sql
SELECT issued_year, issn, count(distinct(doi)) as articles
FROM `api-project-764811344545.cr_dump_march_20.els_hybrid_cr`
WHERE issued_year > 2014 and issued_year < 2020
group by issued_year, issn
```

How many articles by year?

``` r
els_vol <- article_volume %>%
  group_by(issued_year) %>%
  summarise(n = sum(articles))
els_vol
#> # A tibble: 5 x 2
#>   issued_year      n
#>         <int>  <int>
#> 1        2015 515003
#> 2        2016 541208
#> 3        2017 555822
#> 4        2018 585562
#> 5        2019 621398
```

backup

``` r
write_csv(article_volume, here::here("data", "article_volume.csv"))
```

### Article volume excluding paratext

``` sql
SELECT
        issued_year,
        issn,
        count(distinct(doi)) as articles     
    FROM
        `api-project-764811344545.cr_dump_march_20.els_hybrid_cr`      
    WHERE
        issued_year > 2014 
        and issued_year < 2020     
    AND NOT     regexp_contains(title,'^Author Index$|^Back Cover|^Contents$|^Contents:|^Cover Image|^Cover Picture|^Editorial Board|^Front Cover|^Frontispiece|^Inside Back Cover|^Inside Cover|^Inside Front Cover|^Issue Information|^List of contents|^Masthead|^Title page|^Correction$|^Corrections to|^Corrections$|^Withdrawn')    
    GROUP BY
        issued_year,
        issn
```

How many articles by year?

``` r
article_volume_para %>%
  group_by(issued_year) %>%
  summarise(articles = sum(articles)) %>%
  inner_join(els_vol, by = "issued_year") %>%
  mutate(para = n - articles) %>%
  mutate(para / n * 100)
#> # A tibble: 5 x 5
#>   issued_year articles      n  para `para/n * 100`
#>         <int>    <int>  <int> <int>          <dbl>
#> 1        2015   502570 515003 12433           2.41
#> 2        2016   528229 541208 12979           2.40
#> 3        2017   542935 555822 12887           2.32
#> 4        2018   569043 585562 16519           2.82
#> 5        2019   604692 621398 16706           2.69
```

backup

``` r
write_csv(article_volume_para, here::here("data", "article_volume_para.csv"))
```

### Article volume regular issues excluding paratext

``` sql
    SELECT
        issued_year,
        issn,
        count(distinct(doi)) as articles          
    FROM
        `api-project-764811344545.cr_dump_march_20.els_hybrid_cr`           
    WHERE
        issued_year > 2014          
        and issued_year < 2020              
        AND NOT     regexp_contains(title,'^Author Index$|^Back Cover|^Contents$|^Contents:|^Cover Image|^Cover Picture|^Editorial Board|^Front Cover|^Frontispiece|^Inside Back Cover|^Inside Cover|^Inside Front Cover|^Issue Information|^List of contents|^Masthead|^Title page|^Correction$|^Corrections to|^Corrections$|^Withdrawn')          
         AND (NOT regexp_contains(page, '^S') OR page is NULL)
    GROUP BY
        issued_year,
        issn
```

How many articles by year?

``` r
article_volume_regular %>%
  group_by(issued_year) %>%
  summarise(articles = sum(articles)) 
#> # A tibble: 5 x 2
#>   issued_year articles
#>         <int>    <int>
#> 1        2015   466350
#> 2        2016   484718
#> 3        2017   496729
#> 4        2018   518653
#> 5        2019   554542
```

backup

``` r
write_csv(article_volume_regular, here::here("data", "article_volume_para_regular.csv"))
```

### Article volume with at least one reference per journal and year

``` sql
SELECT issued_year, issn, count(distinct(doi)) as articles
FROM `api-project-764811344545.cr_dump_march_20.els_hybrid_cr`
WHERE reference_count > 0 AND (issued_year > 2014 and issued_year < 2020)
group by issued_year, issn
```

``` r
ref_article_volume %>%
  group_by(issued_year) %>%
  summarise(n = sum(articles))
#> # A tibble: 5 x 2
#>   issued_year      n
#>         <int>  <int>
#> 1        2015 388876
#> 2        2016 405995
#> 3        2017 419502
#> 4        2018 451638
#> 5        2019 486435
```

backup

``` r
write_csv(ref_article_volume, here::here("data", "ref_article_volume.csv"))
```

### Validation: Do these journals actually deposit references with Crossref

``` r
zero_ref_jns <- article_volume %>% 
  filter(!issn %in% ref_article_volume$issn) %>% 
  distinct(issn)
```

Do these journals deposit references?

``` r
library(rcrossref)
cr_jns <- rcrossref::cr_journals(zero_ref_jns$issn)
table(current = cr_jns$data$deposits_references_current, back_file =  cr_jns$data$deposits_references_backfile)
#>        back_file
#> current TRUE
#>   FALSE    3
#>   TRUE     1
```

All journals deposited references with Crossref\!
