#+ setup, include=FALSE
knitr::opts_chunk$set(
  comment = "#>",
  collapse = TRUE,
  warning = FALSE,
  message = FALSE,
  echo = TRUE,
  highlight = TRUE
)
#' ## Article volume
#' 
library(tidyverse)
#'
#' Datasets:
#' 
#' - Eligible OA articles: <data/hybrid_articles.csv>
#' - Hybrid journals with at least one OA article between 2015-19, excluding reverse flips: 
#'   <data/hybrid_jns.csv>
#' - Publication volume excluding Supplements and Paratext: see <analysis/005_article_volume.Rmd>
hybrid_df <- readr::read_csv(here::here("data", "hybrid_articles.csv"))
hybrid_jns <- readr::read_csv(here::here("data", "hybrid_jns.csv"))
els_volume <- readr::read_csv(here::here("data", "article_volume_para_regular.csv"))
#'
#' Publication volume per year
#' 
hybrid_volume <- els_volume %>%
  filter(issn %in% hybrid_jns$issn)
#' OA volume per year
oa_volume <- hybrid_df %>%
  group_by(issued_year, issn) %>%
  summarise(oa = n_distinct(doi)) 
#' join
hybrid_oa_volume <- 
  left_join(hybrid_volume, oa_volume, by = c("issn", "issued_year")) %>%
  # NA to 0
  mutate_if(is.integer, ~replace(., is.na(.), 0))
readr::write_csv(hybrid_oa_volume, here::here("data", "hybrid_oa_volume.csv"))
                 
