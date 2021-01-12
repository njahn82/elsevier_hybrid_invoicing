
``` r
# libraries
library(tidyverse)
library(here)
library(knitr)
```

Load hybrid article-level dataset and journal classification

``` r
jn_subjects <- read_csv(here::here("data", "jn_subjects.csv"))
hybrid_df <- readr::read_csv(here::here("data", "hybrid_articles.csv"))
subject_hybrid <- left_join(hybrid_df, jn_subjects, by = "issn") %>%
  select(doi, issn, top_level, subject_area)
```

## Subject field (top-level)

Number of Journals (full and fractional counting)

``` r
subject_hybrid %>% 
  group_by(issn, top_level) %>%
  summarise(n = n()) %>% 
  mutate(fractions = n / sum(n)) %>% 
  ungroup() %>% 
  group_by(top_level) %>% 
  summarise(journals_n = n_distinct(issn),
            journals_frac = sum(fractions)) %>% 
  arrange(desc(journals_frac))
```

<div class="kable-table">

| top\_level                                   | journals\_n | journals\_frac |
| :------------------------------------------- | ----------: | -------------: |
| Medicine                                     |         560 |         417.03 |
| Biochemistry, Genetics and Molecular Biology |         258 |         143.48 |
| Engineering                                  |         223 |         100.33 |
| Agricultural and Biological Sciences         |         165 |          96.02 |
| Social Sciences                              |         183 |          90.05 |
| Computer Science                             |         149 |          73.32 |
| Physics and Astronomy                        |         146 |          65.27 |
| Mathematics                                  |         111 |          63.87 |
| Earth and Planetary Sciences                 |          94 |          62.70 |
| Economics, Econometrics and Finance          |          94 |          61.45 |
| Materials Science                            |         137 |          56.28 |
| Environmental Science                        |         117 |          52.83 |
| Chemistry                                    |         117 |          49.13 |
| Psychology                                   |          92 |          49.13 |
| Business, Management and Accounting          |          87 |          47.57 |
| Neuroscience                                 |          82 |          43.85 |
| Nursing                                      |          67 |          43.37 |
| Pharmacology, Toxicology and Pharmaceutics   |          70 |          41.53 |
| Immunology and Microbiology                  |          79 |          39.42 |
| Chemical Engineering                         |          74 |          29.95 |
| Energy                                       |          55 |          26.40 |
| NA                                           |          22 |          22.00 |
| Arts and Humanities                          |          49 |          21.88 |
| Health Professions                           |          37 |          16.90 |
| Dentistry                                    |          21 |          14.33 |
| Veterinary                                   |          22 |          13.00 |
| Decision Sciences                            |          36 |          12.90 |
| Multidisciplinary                            |           1 |           1.00 |

</div>

Articles

``` r
subject_hybrid %>% 
  group_by(doi, top_level) %>%
  summarise(n = n()) %>% 
  mutate(fractions = n / sum(n)) %>% 
  ungroup() %>% 
  group_by(top_level) %>% 
  summarise(articles_n = n_distinct(doi),
            articles_frac = sum(fractions)) %>% 
  arrange(desc(articles_frac))
```

<div class="kable-table">

| top\_level                                   | articles\_n | articles\_frac |
| :------------------------------------------- | ----------: | -------------: |
| Medicine                                     |       23612 |        16436.9 |
| Biochemistry, Genetics and Molecular Biology |       15796 |         9080.6 |
| Environmental Science                        |        9000 |         4471.6 |
| Agricultural and Biological Sciences         |        7956 |         4127.8 |
| Physics and Astronomy                        |        5796 |         3420.6 |
| Engineering                                  |        8315 |         3395.7 |
| Neuroscience                                 |        5836 |         3379.5 |
| Earth and Planetary Sciences                 |        4532 |         3032.0 |
| Social Sciences                              |        6306 |         2977.2 |
| Pharmacology, Toxicology and Pharmaceutics   |        4075 |         2606.5 |
| Immunology and Microbiology                  |        5527 |         2404.4 |
| Materials Science                            |        4807 |         2110.9 |
| Energy                                       |        4286 |         1989.5 |
| Chemistry                                    |        4010 |         1674.9 |
| Psychology                                   |        3052 |         1559.1 |
| Computer Science                             |        3103 |         1484.1 |
| Economics, Econometrics and Finance          |        2071 |         1149.6 |
| Chemical Engineering                         |        2920 |         1138.8 |
| Mathematics                                  |        2105 |         1079.2 |
| Business, Management and Accounting          |        1751 |          851.2 |
| Nursing                                      |        1504 |          821.1 |
| Veterinary                                   |        2091 |          706.8 |
| Arts and Humanities                          |        1565 |          631.8 |
| NA                                           |         362 |          362.0 |
| Decision Sciences                            |         785 |          275.4 |
| Health Professions                           |         674 |          274.4 |
| Dentistry                                    |         288 |          164.3 |
| Multidisciplinary                            |          37 |           37.0 |

</div>

### Subject area

Number of Journals (full and fractional counting)

``` r
subject_hybrid %>% 
  group_by(issn, subject_area) %>%
  summarise(n = n()) %>% 
  mutate(fractions = n / sum(n)) %>% 
  ungroup() %>% 
  group_by(subject_area) %>% 
  summarise(journals_n = n_distinct(issn),
            journals_frac = sum(fractions)) %>% 
  arrange(desc(journals_frac))
```

<div class="kable-table">

| subject\_area     | journals\_n | journals\_frac |
| :---------------- | ----------: | -------------: |
| Physical Sciences |         707 |          580.1 |
| Health Sciences   |         632 |          504.6 |
| Life Sciences     |         533 |          364.3 |
| Social Sciences   |         371 |          283.0 |
| NA                |          22 |           22.0 |
| Multidisciplinary |           1 |            1.0 |

</div>

Articles

``` r
subject_hybrid %>% 
  group_by(doi, subject_area) %>%
  summarise(n = n()) %>% 
  mutate(fractions = n / sum(n)) %>% 
  ungroup() %>% 
  group_by(subject_area) %>% 
  summarise(articles_n = n_distinct(doi),
            articles_frac = sum(fractions)) %>% 
  arrange(desc(articles_frac))
```

<div class="kable-table">

| subject\_area     | articles\_n | articles\_frac |
| :---------------- | ----------: | -------------: |
| Physical Sciences |       29456 |          23797 |
| Life Sciences     |       31206 |          21599 |
| Health Sciences   |       25108 |          18404 |
| Social Sciences   |       11169 |           7444 |
| NA                |         362 |            362 |
| Multidisciplinary |          37 |             37 |

</div>

## Agreement only

``` r
jn_subjects <- read_csv(here::here("data", "jn_subjects.csv"))
hybrid_df <- readr::read_csv(here::here("data", "hybrid_articles.csv")) %>%
  filter(oa_sponsor_type == "FundingBody")
subject_agreement_hybrid <- left_join(hybrid_df, jn_subjects, by = "issn") %>%
  select(doi, issn, top_level, subject_area)
```

## Subject field (top-level)

Number of Journals (full and fractional counting)

``` r
subject_agreement_hybrid %>% 
  group_by(issn, top_level) %>%
  summarise(n = n()) %>% 
  mutate(fractions = n / sum(n)) %>% 
  ungroup() %>% 
  group_by(top_level) %>% 
  summarise(journals_n = n_distinct(issn),
            journals_frac = sum(fractions)) %>% 
  arrange(desc(journals_frac))
```

<div class="kable-table">

| top\_level                                   | journals\_n | journals\_frac |
| :------------------------------------------- | ----------: | -------------: |
| Medicine                                     |         391 |        274.783 |
| Biochemistry, Genetics and Molecular Biology |         233 |        131.567 |
| Engineering                                  |         209 |         94.167 |
| Agricultural and Biological Sciences         |         143 |         82.067 |
| Social Sciences                              |         157 |         77.933 |
| Computer Science                             |         132 |         66.317 |
| Physics and Astronomy                        |         135 |         60.433 |
| Earth and Planetary Sciences                 |          84 |         56.867 |
| Mathematics                                  |         100 |         56.450 |
| Materials Science                            |         126 |         51.450 |
| Environmental Science                        |         110 |         49.500 |
| Economics, Econometrics and Finance          |          73 |         48.117 |
| Chemistry                                    |         106 |         43.550 |
| Psychology                                   |          81 |         43.433 |
| Neuroscience                                 |          74 |         40.567 |
| Pharmacology, Toxicology and Pharmaceutics   |          62 |         37.617 |
| Immunology and Microbiology                  |          74 |         37.333 |
| Business, Management and Accounting          |          59 |         31.867 |
| Chemical Engineering                         |          71 |         28.867 |
| Energy                                       |          53 |         24.900 |
| Arts and Humanities                          |          41 |         18.383 |
| Nursing                                      |          34 |         17.117 |
| NA                                           |          14 |         14.000 |
| Decision Sciences                            |          30 |         10.733 |
| Health Professions                           |          22 |          9.983 |
| Veterinary                                   |          18 |          9.500 |
| Dentistry                                    |           9 |          4.500 |
| Multidisciplinary                            |           1 |          1.000 |

</div>

Articles

``` r
subject_agreement_hybrid %>% 
  group_by(doi, top_level) %>%
  summarise(n = n()) %>% 
  mutate(fractions = n / sum(n)) %>% 
  ungroup() %>% 
  group_by(top_level) %>% 
  summarise(articles_n = n_distinct(doi),
            articles_frac = sum(fractions)) %>% 
  arrange(desc(articles_frac))
```

<div class="kable-table">

| top\_level                                   | articles\_n | articles\_frac |
| :------------------------------------------- | ----------: | -------------: |
| Medicine                                     |        5905 |        3866.35 |
| Biochemistry, Genetics and Molecular Biology |        5554 |        3383.97 |
| Environmental Science                        |        3447 |        1632.68 |
| Engineering                                  |        3838 |        1575.40 |
| Neuroscience                                 |        2327 |        1299.15 |
| Agricultural and Biological Sciences         |        2461 |        1249.38 |
| Physics and Astronomy                        |        2182 |        1124.57 |
| Earth and Planetary Sciences                 |        1579 |        1102.28 |
| Social Sciences                              |        2285 |        1099.18 |
| Energy                                       |        2237 |        1036.48 |
| Materials Science                            |        2252 |        1001.55 |
| Immunology and Microbiology                  |        1869 |         880.00 |
| Chemistry                                    |        1846 |         739.45 |
| Pharmacology, Toxicology and Pharmaceutics   |        1116 |         688.48 |
| Psychology                                   |        1222 |         616.62 |
| Chemical Engineering                         |        1365 |         540.52 |
| Computer Science                             |        1116 |         524.07 |
| Mathematics                                  |         805 |         397.17 |
| Economics, Econometrics and Finance          |         679 |         388.18 |
| Arts and Humanities                          |         696 |         280.78 |
| Business, Management and Accounting          |         500 |         214.88 |
| Veterinary                                   |         524 |         173.42 |
| NA                                           |         155 |         155.00 |
| Nursing                                      |         244 |         122.55 |
| Decision Sciences                            |         209 |          75.82 |
| Health Professions                           |         165 |          60.90 |
| Dentistry                                    |          50 |          19.17 |
| Multidisciplinary                            |           2 |           2.00 |

</div>

### Subject area

Number of Journals (full and fractional counting)

``` r
subject_agreement_hybrid %>% 
  group_by(issn, subject_area) %>%
  summarise(n = n()) %>% 
  mutate(fractions = n / sum(n)) %>% 
  ungroup() %>% 
  group_by(subject_area) %>% 
  summarise(journals_n = n_distinct(issn),
            journals_frac = sum(fractions)) %>% 
  arrange(desc(journals_frac))
```

<div class="kable-table">

| subject\_area     | journals\_n | journals\_frac |
| :---------------- | ----------: | -------------: |
| Physical Sciences |         646 |          532.5 |
| Life Sciences     |         480 |          329.1 |
| Health Sciences   |         427 |          315.9 |
| Social Sciences   |         307 |          230.5 |
| NA                |          14 |           14.0 |
| Multidisciplinary |           1 |            1.0 |

</div>

Articles

``` r
subject_agreement_hybrid %>% 
  group_by(doi, subject_area) %>%
  summarise(n = n()) %>% 
  mutate(fractions = n / sum(n)) %>% 
  ungroup() %>% 
  group_by(subject_area) %>% 
  summarise(articles_n = n_distinct(doi),
            articles_frac = sum(fractions)) %>% 
  arrange(desc(articles_frac))
```

<div class="kable-table">

| subject\_area     | articles\_n | articles\_frac |
| :---------------- | ----------: | -------------: |
| Physical Sciences |       11515 |           9674 |
| Life Sciences     |       10517 |           7501 |
| Health Sciences   |        6250 |           4242 |
| Social Sciences   |        4020 |           2675 |
| NA                |         155 |            155 |
| Multidisciplinary |           2 |              2 |

</div>
