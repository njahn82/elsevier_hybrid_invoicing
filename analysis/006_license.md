OA Share
================

### Connect to database

``` r
# connect to google bg where we imported the json lines Unpaywall dump
library(tidyverse)
library(DBI)
library(bigrquery)
con <- dbConnect(
  bigrquery::bigquery(),
  project = "api-project-764811344545",
  dataset = "cr_dump_march_20"
)
```

### Get article-level metadata for all journals listed in Elseviers most current APC pricing list

``` sql
CREATE 
    OR REPLACE TABLE `api-project-764811344545.cr_dump_march_20.els_all_may_20` AS SELECT
        cr.*,
        els.oa_type 
    FROM
        `api-project-764811344545.cr_dump_march_20.cr_08_20_expanded` as cr 
    INNER JOIN
        `api-project-764811344545.cr_dump_march_20.elsevier_apc_list_30_May_20` as els 
            ON cr.issn = els.issn 
```

Aggregate

``` sql
SELECT
        REGEXP_REPLACE(license.URL,
        "http://|https://",
        "") as license_url,
        issued_year,
        oa_type,
        COUNT(DISTINCT(doi)) as articles 
    FROM
        `api-project-764811344545.cr_dump_march_20.els_all_may_20`,
        unnest(license) as license 
    WHERE
        issued_year > 2014 
        and issued_year < 2020 
        AND license.content_version = 'vor'         
        AND NOT     regexp_contains(title,'^Author Index$|^Back Cover|^Contents$|^Contents:|^Cover Image|^Cover Picture|^Editorial Board|^Front Cover|^Frontispiece|^Inside Back Cover|^Inside Cover|^Inside Front Cover|^Issue Information|^List of contents|^Masthead|^Title page')
        AND NOT regexp_contains(page, '^S')
    GROUP BY
        license_url,
        issued_year,
        oa_type 
    ORDER BY
        issued_year DESC
```

``` r
license_by_year <- license_agg %>%
  mutate(license_code =
           case_when(
             grepl("/by/", license_url) ~ "cc-by",
             grepl("/by-nc", license_url) ~ "cc-by-nc",
             grepl("userlicense", license_url) ~ "els-user")
  ) %>%
  group_by(license_code, oa_type, issued_year) %>%
  summarise(n = sum(articles))
```

just immediate hybrid

``` r
im_hybrid <- readr::read_csv(here::here("data", "hybrid_volume_eligible.csv"))
cc_hybrid <- im_hybrid %>%
  mutate(license_code = ifelse(grepl("/by/", URL), "cc-by", "cc-by-nc")) %>%
  group_by(license_code, issued_year) %>%
  summarise(hybrid_immediate_articles = n()) %>%
  mutate(immediate = "immediate",
         oa_type = "Hybrid") %>%
  inner_join(license_by_year, by = c("issued_year", "license_code", "oa_type")) %>%
  mutate(hybrid_delayed_articles = n - hybrid_immediate_articles) %>%
  select(-immediate, -oa_type) %>%
  pivot_longer(c(hybrid_immediate_articles, hybrid_delayed_articles), names_to = "type", values_to = "articles")
# user only open archive
els_user <- license_by_year %>%
  filter(license_code == "els-user") %>%
  mutate(type = "hybrid_delayed_articles") %>%
  group_by(issued_year, type, license_code) %>%
  summarise(articles = sum(n))
# full oa 
full_oa_df <- license_by_year %>%
  ungroup() %>%
  filter(license_code != "els-user", oa_type == "Open Access") %>%
  mutate(type = "full_oa") %>%
  rename(articles = n) %>%
  select(-oa_type)
license_growth_df <- bind_rows(cc_hybrid, els_user, full_oa_df) 

ggplot(license_growth_df, aes(issued_year, articles, fill = license_code, group = license_code)) +
  geom_area() +
  facet_wrap(~type)
```

<img src="006_license_files/figure-gfm/unnamed-chunk-5-1.png" width="70%" style="display: block; margin: auto;" />

### relative

overall article volume elsevier

``` sql
SELECT  issued_year,
        COUNT(DISTINCT(doi)) as all_articles 
    FROM
        `api-project-764811344545.cr_dump_march_20.els_all_may_20`
    WHERE
        issued_year > 2014 
        and issued_year < 2020        
        AND NOT     regexp_contains(title,'^Author Index$|^Back Cover|^Contents$|^Contents:|^Cover Image|^Cover Picture|^Editorial Board|^Front Cover|^Frontispiece|^Inside Back Cover|^Inside Cover|^Inside Front Cover|^Issue Information|^List of contents|^Masthead|^Title page') 
        AND NOT regexp_contains(page, '^S') 
    GROUP BY
        issued_year
```

``` r
year_per_oa_type_and_license <- inner_join(license_growth_df, els_yearly, by = "issued_year") %>%
  mutate(prop = articles / all_articles) 
# backup 
write_csv(year_per_oa_type_and_license, here::here("data", "year_per_oa_type_and_license.csv"))
```

plots

``` r
library(cowplot)
p_1 <- year_per_oa_type_and_license %>%
  mutate(type_plot = case_when(
    type == "full_oa" ~ "Full OA",
    type == "hybrid_immediate_articles" ~ "Hybrid OA",
    type == "hybrid_delayed_articles" ~ "Delayed OA"
  )) %>% 
  mutate(type_plot = factor(type_plot, levels = c("Hybrid OA", "Full OA", "Delayed OA"))) %>%
  ggplot(aes(gsub("20", "'", as.character(issued_year)), prop, fill = license_code, group = license_code)) +
  geom_area(stat = "identity",
            color = "white",
            alpha = 0.8,
            position = position_stack(reverse = T)) +
  facet_grid(~type_plot) +
  scale_y_continuous(
    expand = expansion(mult = c(0, 0.0005)),
    labels = scales::percent_format(accuracy = 1L),
    breaks = c(0, 0.02, 0.04, 0.06, 0.08)
  ) +
  scale_fill_manual(values = 
                      c(`cc-by` = "#0093c7",
                        `cc-by-nc` = "#B52141",
                        `els-user` = "grey80")) +
  labs(x = "Publication year", y = "OA Percentage") +
  theme_minimal_hgrid() +
  theme(legend.position = "top",
        legend.justification = "right") +
  guides(fill = guide_legend("Open content license"))
p_1
```

<img src="006_license_files/figure-gfm/unnamed-chunk-8-1.png" width="70%" style="display: block; margin: auto;" />

overall

``` r
p_2 <- year_per_oa_type_and_license %>%
  mutate(type_plot = case_when(
    type == "full_oa" ~ "Full OA",
    type == "hybrid_immediate_articles" ~ "Hybrid OA",
    type == "hybrid_delayed_articles" ~ "Delayed OA"
  )) %>% 
  mutate(type_plot = factor(type_plot, levels = c("Hybrid OA", "Full OA", "Delayed OA"))) %>%
  group_by(type_plot) %>%
  summarise(n = sum(articles)) %>%
  ggplot(aes(x = "", y = n, fill = type_plot)) +
  geom_bar(width = 1,
           stat = "identity",
           position = position_stack(reverse = TRUE),
           color = "white") +
  coord_flip() +
  scale_y_continuous(labels = function(x) format(x, big.mark = ",", scientific = FALSE),
                     limits = c(0, 350000)) +
  scale_fill_brewer("OA Type", type = "qual", palette = "Set2") +
  labs(x = NULL,
       y = "Total OA Articles") +
  theme_minimal_grid() +
  theme(plot.margin = margin(30, 30, 30, 30)) +
  theme(panel.grid.minor = element_blank()) +
  theme(axis.ticks = element_blank()) +
  theme(panel.grid.major.y = element_blank()) +
  theme(panel.border = element_blank()) +
  theme(legend.position = "bottom",
        legend.justification = "right")
p_2
```

<img src="006_license_files/figure-gfm/unnamed-chunk-9-1.png" width="70%" style="display: block; margin: auto;" />

``` r
p <- cowplot::plot_grid(
  p_1, p_2,
  labels = "AUTO", ncol = 1
)
ggsave(here::here("figure", "license_portfolio.png"), p, dpi = 300, width = 6, height = 6)
```