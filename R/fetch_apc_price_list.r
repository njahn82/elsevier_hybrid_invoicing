#' libraries
require(tidyverse)
require(tabulizer)
#' parse APC pricing list from Elsevier
#' https://www.elsevier.com/__data/promis_misc/j.custom97.pdf
els_jns <- extract_tables("https://www.elsevier.com/__data/promis_misc/j.custom97.pdf")
#' transform to tibble
els_jns_df <- map_df(els_jns, as_tibble) %>%
  slice(-1) %>%
  rename(issn = V1, jn_title = V2, oa_type = V3, apc_currency = V4, apc = V5) %>% 
  # there are two case where the title is broken down into two rows, remove these case
  filter(!issn == "")
#' backup
write_csv(els_jns_df, "data/elsevier_apc_list.csv")
