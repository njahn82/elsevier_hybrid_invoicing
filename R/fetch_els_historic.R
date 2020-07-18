library(tidyverse)
library(here)
u <- "https://raw.githubusercontent.com/lmatthia/publisher-oa-portfolios/master/elsevier_oa_and_hybrid.csv"
els_jns <- readr::read_delim(u, delim = ";")
tt <- els_jns %>%
  filter(year > 2014) 
write_csv(tt, here::here("data", "els_historic_jns.csv"))
