results
================
Najko Jahn
7/7/2020

## Results

### Uptake

#### How many Elsevier journals supported the hybrid model? How many of them flipped to fully open access?

to do

#### What is the uptake of open access in Elsevier’s hybrid journal portfolio?

*Number and percentage of journals with at least one article*

``` r
library(tidyverse)
library(here)
els_jns_df <- readr::read_csv(here::here("data", "elsevier_apc_list.csv"))
```

To determine the number of Elsevier hybrid journals with at least one
open access article, we downloaded and parsed the publisher’s APC
pricing list from 31 May 2020. The list comprised 2,339 journals, of
which 1,982 supported the hybrid model, representing a share of 85%.

``` r
hybrid_md <- readr::read_csv(here::here("data", "hybrid_md.csv"))
els_tdm <- readr::read_csv(here::here("data", "els_tmd_links.csv"))
invoice_df <-  readr::read_csv(here::here("data", "invoice_df.csv"))

hybrid_df <- els_tdm %>% 
  select(doi, URL) %>% 
  inner_join(invoice_df, by = c("URL" = "tdm_url")) %>% 
  select(-URL) %>% 
  inner_join(hybrid_md, by = c("doi")) %>% 
  distinct()
```

Of those, 1,765 hybrid journals published at least one open access
article immediately under a Creative Commons license between 2015 and
2019, corresponding to about 89% of journal titles in Elsevier’s hybrid
journal portfolio. At the same time, 11% of hybrid journals did not
published an open access article in this period and were, thus, excluded
from further analysis.

``` r
eligible_jns <- hybrid_df %>% 
  filter(oa_archive == FALSE) %>% 
  distinct(issn)
```

*Number and percentage of open access articles per hybrid journal*

We used the Crossref index to determine the overall article volume of
Elsevier’s hybrid journal portfolio, and to related it to the number of
open access articles. Because DOIs can be also issued to abstracts
presented at scientific meetings and non-scholarly journal content
including table of contents and list of reviewers, we furthermore
distinguished between citing and non-citing articles defined by the
number of deposited references in Crossref per article, regardless of
whether they are public or not.

Table presents the high-level findings by year of publication.
illustrating a growth
