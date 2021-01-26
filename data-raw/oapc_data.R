# openapc https://github.com/OpenAPC/openapc-de/releases/tag/v4.8.4-3-0
u <-
  "https://raw.githubusercontent.com/OpenAPC/openapc-de/3d2f9ba66e6dab29856cb3702a9ce8ae4da0d09b/data/apc_de.csv"
o_apc <- readr::read_csv(u)
#'
#' We also would like to add data from transformative aggrements, which is also
#' collected by the Open APC Initiative.
#' The transformative agreements data-set does not include pricing information.
#'
oa_trans <-
  readr::read_csv(
    "https://raw.githubusercontent.com/OpenAPC/openapc-de/3d2f9ba66e6dab29856cb3702a9ce8ae4da0d09b/data/transformative_agreements/transformative_agreements.csv"
  )
oapc <- oa_trans %>%
  bind_rows(o_apc) 
write_csv(oapc, here::here("data", "o_apc.csv"))
