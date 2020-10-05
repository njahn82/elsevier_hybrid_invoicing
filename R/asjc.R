library(rvest)
asjc <- read_html("https://service.elsevier.com/app/answers/detail/a_id/15181/supporthub/scopus/related/1/") %>%
  html_table() %>%
  bind_rows() %>%
  as_tibble() %>%
  janitor::clean_names() %>%
  mutate(top_level_code = map_chr(code, function(x) substr(x, 1,2)))

asjc_top_level <- tibble::tribble(
  ~description, ~subject_area,
  "Multidisciplinary", "Multidisciplinary",
  "Agricultural and Biological Sciences", "Life Sciences",
  "Arts and Humanities", "Social Sciences",
  "Biochemistry, Genetics and Molecular Biology", "Life Sciences",
  "Business, Management and Accounting", "Social Sciences",
  "Chemical Engineering", "Physical Sciences",
  "Chemistry", "Physical Sciences",
  "Computer Science", "Physical Sciences",
  "Decision Sciences", "Social Sciences",
  "Earth and Planetary Sciences", "Physical Sciences",
  "Economics, Econometrics and Finance", "Social Sciences",
  "Energy", "Physical Sciences",
  "Engineering", "Physical Sciences",
  "Environmental Science", "Physical Sciences",
  "Immunology and Microbiology", "Life Sciences",
  "Materials Science", "Physical Sciences",
  "Mathematics", "Physical Sciences",
  "Medicine", "Health Sciences",
  "Neuroscience", "Life Sciences",
  "Nursing", "Health Sciences",
  "Pharmacology, Toxicology and Pharmaceutics", "Life Sciences",
  "Physics and Astronomy", "Physical Sciences",
  "Psychology", "Social Sciences",
  "Social Sciences", "Social Sciences",
  "Veterinary", "Health Sciences",
  "Dentistry", "Health Sciences",
  "Health Professions", "Health Sciences") 
top_level_code <- tibble::tibble(top_level_code = 10:36)
asjc_mapped <- bind_cols(asjc_top_level, top_level_code)
write_csv(asjc_mapped, here::here("data", "asjc_mapped.csv"))
