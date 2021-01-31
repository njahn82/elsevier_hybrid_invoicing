011\_scpopus\_subject\_all.Rmd
================

``` r
library(tidyverse)
library(janitor)
```

read in scopus journal indicators

``` r
scopus_19 <- readxl::read_excel(here::here("data", "scopus_jn.xlsx"), sheet = 2,
                                .name_repair = make_clean_names)
ajsc_mapped <- read_csv(here::here("data", "asjc_mapped.csv")) %>%
  mutate(top_level_code = as.character(top_level_code))
```

normalize scopus jn indicators

``` r
scopus_norm <- scopus_19 %>%
  mutate(top_level_code = substr(as.character(scopus_asjc_code_sub_subject_area), 1, 2)) %>%
  inner_join(ajsc_mapped, by = "top_level_code")
```

## All

``` r
scopus_norm %>%
  distinct(subject_area, scopus_source_id, scholarly_output) %>%
  group_by(subject_area) %>% 
  summarise(n = sum(scholarly_output)) %>%
  mutate(prop = n / sum(n)) %>%
  arrange(desc(n))
```

<div class="kable-table">

| subject\_area     |       n |   prop |
| :---------------- | ------: | -----: |
| Physical Sciences | 5059995 | 0.4322 |
| Health Sciences   | 2610385 | 0.2230 |
| Life Sciences     | 2295527 | 0.1961 |
| Social Sciences   | 1503364 | 0.1284 |
| Multidisciplinary |  238955 | 0.0204 |

</div>

## Elsevier

``` r
scopus_norm %>%
  filter(publisher == "Elsevier") %>%
  distinct(subject_area, scopus_source_id, scholarly_output) %>%
  group_by(subject_area) %>% 
  summarise(n = sum(scholarly_output)) %>%
  mutate(prop = n / sum(n))
```

<div class="kable-table">

| subject\_area     |       n |   prop |
| :---------------- | ------: | -----: |
| Health Sciences   |  506545 | 0.2193 |
| Life Sciences     |  532467 | 0.2305 |
| Multidisciplinary |    9963 | 0.0043 |
| Physical Sciences | 1057566 | 0.4578 |
| Social Sciences   |  203417 | 0.0881 |

</div>

By oa

``` r
scopus_norm %>%
  filter(publisher == "Elsevier") %>%
  distinct(subject_area, scopus_source_id, scholarly_output, open_access) %>%
  group_by(subject_area, open_access) %>% 
  summarise(n = sum(scholarly_output))
```

<div class="kable-table">

| subject\_area     | open\_access |       n |
| :---------------- | :----------- | ------: |
| Health Sciences   | NO           |  461828 |
| Health Sciences   | YES          |   44717 |
| Life Sciences     | NO           |  507283 |
| Life Sciences     | YES          |   25184 |
| Multidisciplinary | NO           |    1842 |
| Multidisciplinary | YES          |    8121 |
| Physical Sciences | NO           | 1023559 |
| Physical Sciences | YES          |   34007 |
| Social Sciences   | NO           |  199398 |
| Social Sciences   | YES          |    4019 |

</div>
