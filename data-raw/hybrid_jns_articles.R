#+ setup, include=FALSE
knitr::opts_chunk$set(
  comment = "#>",
  collapse = TRUE,
  warning = FALSE,
  message = FALSE,
  echo = TRUE,
  highlight = TRUE
)
#' ## Obtain eligible articles and hybrid journals
#' 
#' ### Definition
#' Journal inclusion criteria:
#' - tagged as hybrid in Elsevier APC Pricing list from 30 May 2020
#' - Elsevier has not changed the OA business model from full OA to hybrid between 2015-19 
#'
#' Article inclusion criteria:
#' - immediate OA publication indicated by `oa_archive == FALSE`
#' - not a paratext / journal matter
#' - published in a regular issue, i.e. excluding supplemental issues as indicated by the pattern S in the pages
#' 
#' 
#' Libraries used
library(tidyverse)
library(here)
#' 
#' ### Required datasets
#' 
#' #### Journal level
#' 
#' Elsevier journal list
els_jns <- readr::read_csv(here::here("data", "els_historic_jns.csv")) 
#' I exclude reverse-flip journals, i.e. journals changing the OA business model 
#' from full OA to hybrid between 2015-19 under the courtesy of Elsevier.
#' 
flipped_jns <- els_jns %>%
distinct(issn, oa_model) %>%
  group_by(issn) %>%
  filter(n() > 1)
#' hybrid metadata obtained from Crossref
hybrid_md <- readr::read_csv(here::here("data", "hybrid_md.csv"))
#' invoicing metadata obtained from mining Elsevier full-texts
invoice_df <-  readr::read_csv(here::here("data", "invoice_df.csv"))
#' matching table between Crossref and invoicing metadata
els_tdm <- readr::read_csv(here::here("data", "els_tmd_links.csv"))
#' patterns used to exclude paratext
para <- c('^Author Index$|^Back Cover|^Contents$|^Contents:|^Cover Image|^Cover Picture|^Editorial Board|^Front Cover|^Frontispiece|^Inside Back Cover|^Inside Cover|^Inside Front Cover|^Issue Information|^List of contents|^Masthead|^Title page|^Correction$|^Corrections to|^Corrections$|^Withdrawn')
#'
#' join tables
hybrid_df <- els_tdm %>% 
  select(doi, URL) %>% 
  inner_join(invoice_df, by = c("URL" = "tdm_url")) %>% 
  select(-URL) %>% 
  inner_join(hybrid_md, by = c("doi")) %>% 
   # /*  exclude para text and supplements */
  filter(!grepl(para, title),  !grepl("^S", page)) %>%
   # /* exclude flipped jns */
  filter(!issn %in% flipped_jns$issn) %>%
   # /* some duplicates because of a very few multiple fulltext pdf links */
  distinct(doi, .keep_all = TRUE) %>%
   # /*  exclude oa archive */
  filter(oa_archive == FALSE)
#'
hybrid_df
#' hybrid journals with at least one oa article between 2015-19
hybrid_jns <- hybrid_df %>%
  distinct(issn)
#'
hybrid_jns
#' ## backup
#' 
#' ## Article-level data
write_csv(hybrid_df, here::here("data", "hybrid_articles.csv"))
#'
#' ## Unique journals
write_csv(hybrid_jns, here::here("data", "hybrid_jns.csv"))
