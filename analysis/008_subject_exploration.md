
``` r
# libraries
library(tidyverse)
library(here)
library(cowplot)
library(gt)
library(janitor)
```

``` r
hybrid_oa_volume <- readr::read_csv(here::here("data", "hybrid_oa_volume.csv"))
```

read in scopus journal indicators

``` r
scopus_19 <- readxl::read_excel(here::here("data", "scopus_jn.xlsx"), sheet = 2,
                                .name_repair = make_clean_names)
```

normalize scopus jn indicators

``` r
scopus_norm <- scopus_19 %>%
  separate(print_issn, c("print_issn", "print_issn_extra")) %>% 
  gather(print_issn, e_issn, print_issn_extra, key = "issn_tpye", value = "issn") %>%
  # trailing zero's missing in Excel spreadsheet
  mutate(
    issn = ifelse(nchar(issn) == 5, paste0("000", issn), issn),
    issn = ifelse(nchar(issn) == 6, paste0("00", issn), issn),
    issn = ifelse(nchar(issn) == 7, paste0("0", issn), issn)) %>%
  # missing hyphen
  mutate(issn = map_chr(issn, function(x) paste(c(substr(x, 1, 4), substr(x, 5, 8)), collapse = "-")))
```

missing journals (needs to be validated)

``` r
hybrid_oa_volume %>% 
  filter(!issn %in% scopus_norm$issn) %>% 
  distinct(issn)
#> # A tibble: 11 x 1
#>    issn     
#>    <chr>    
#>  1 1878-786X
#>  2 2387-0206
#>  3 0026-2692
#>  4 1003-5257
#>  5 2352-5800
#>  6 2352-0817
#>  7 0301-7516
#>  8 2444-3824
#>  9 1477-8424
#> 10 0020-7063
#> 11 2590-1168
```

backup

``` r
cite_score_19 <- scopus_norm %>% 
  select(issn, contains("subject"), percentile, snip, sjr)
write_csv(cite_score_19, here::here("data", "cite_score_19.csv"))
```

``` r
ajsc_mapped <- read_csv(here::here("data", "asjc_mapped.csv")) %>%
  mutate(top_level_code = as.character(top_level_code))
hybrid_subject <- left_join(hybrid_oa_volume, cite_score_19, by = c("issn" = "issn")) %>%
  mutate(top_level_code = substr(as.character(scopus_asjc_code_sub_subject_area), 1, 2)) %>%
  inner_join(ajsc_mapped, by = "top_level_code")
# back up ind
 write_csv(hybrid_subject, here::here("data", "jn_scopus_ind_subjects.csv"))
# backup subject liste
hybrid_subject %>% 
  ungroup() %>% 
  distinct(issn, subject_area, top_level = description) %>%
  write_csv(here::here("data", "jn_subjects.csv"))
```
