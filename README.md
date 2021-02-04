## Source code supplement &mdash; Transparency to hybrid open access through publisher-provided metadata: An article-level study of Elsevier

[![Binder](http://mybinder.org/badge_logo.svg)](http://mybinder.org/v2/gh/njahn82/elsevier_hybrid_invoicing/master?urlpath=rstudio)


### Overview

This repository provides data and code used for the submitted manuscript

Najko Jahn, Lisa Matthias, Mikael Laakso, 2021, *Transparency to hybrid open access through publisher-provided metadata: An article-level study of Elsevier*. arXiv.

This repository is organized as a [research compendium](https://doi.org/10.7287/peerj.preprints.3192v2). A research compendium contains data, code, and text associated with it. 

Folder structure:

- The R Markdown files in the [`analysis/`](analysis/) directory provide details about the data analysis, including preliminary data exploration, data gathering and the underlying analytical code for the submitted manuscript. 
- The [`data/`](data/) directory contains data used. 
- The [`data-raw/`](data-raw/) directory provides R scripts used to clean up version of raw data gathered from external sources
- The [`R/`](R/) directory contains R functions used to parse Elsevier full-texts

### Analysis files

#### Main analysis

The [`analysis/`](analysis/) directory contains the manuscript written in R Markdown:

[`analysis/manuscript.Rmd`](analysis/manuscript.Rmd)

The R Markdown is rendered to a Latex document, which was imported to Overleaf for final collaborative proofs.

#### Data gathering

- [`analysis/001_jn_list.Rmd`](analysis/001_jn_list.Rmd) checks Elsevier APC Journal list information and analysed APC pricing variations. (Rendered version in GitHub markdown: [`analysis/001_jn_list.md`](analysis/001_jn_list.md))
- [`analysis/002_cr_els_matching.Rmd`](analysis/002_cr_els_matching.Rmd) tracks how we obtained a subset of article-level metadata published in Elsevier hybrid journals from Crossref. Import and parsing of the Crossref dump to a Google BigQuery database is documented through a separated [GitHub repo](https://github.com/njahn82/cr_dump). (Rendered version in GitHub markdown: [`analysis/002_cr_els_matching.md`](analysis/002_cr_els_matching.md)).
- [`analysis/003_cr_xml_fetch.Rmd`](analysis/003_cr_xml_fetch.Rmd) shows how we obtained open access status information and invoicing data from Elsevier full-texts. NB: This data gathering process did take a couple of hours.
- [`analysis/005_article_volume.Rmd`](analysis/005_article_volume.Rmd) tracks how we obtained the article volume of regular issues excluding paratext using  our Google BigQuery database using SQL and R. (Rendered version in GitHub markdown: [`analysis/005_article_volume.md`](analysis/005_article_volume.md))
- [`analysis/006_license.Rmd`](analysis/006_license.Rmd) tracks license aggregation by OA type using our Google BigQuery database using SQL and R. (Rendered version in GitHub markdown: [`analysis/006_license.md`](analysis/006_license.md))
- [`008_subject_exploration.Rmd`](analysis/008_subject_exploration.Rmd) presents merging with Scopus AJSC classification. (Rendered version in GitHub markdown: [`008_subject_exploration.md`](analysis/008_subject_exploration.md))

#### Misc

Other R Markdown starting with `0*`and `analysis/results.Rmd` presents some pre-liminary data exploration steps. You can ignore them.

### Data files

In the manuscript, the following datasets contained in the repository were used:

#### Journal-level data

- [`data/els_historic_jns.csv`](data/els_historic_jns.csv) Historic price list Elsevier journals since 2014 captured from 
Lisa Matthias. (2020). Publisher OA Portfolios 2.0 (Version 2.0) [Data set]. Zenodo. <http://doi.org/10.5281/zenodo.3841568>. 

- [`data/jn_subjects.csv`](data/jn_subjects.csv) + [`data/jn_scopus_ind_subjects.csv`](data/jn_scopus_ind_subjects.csv) Mapping with Scopus Journal Title list. See also [`008_subject_exploration.Rmd`](analysis/008_subject_exploration.Rmd)

#### Article-level data

- [`data/hybrid_articles.csv`](data/hybrid_articles.csv) article-level data about OA articles in hybrid journals. See also [`data-raw/hybrid_jns_articles.R`](data-raw/hybrid_jns_articles.R)

#### Aggregated data

- [`data/year_per_oa_type_and_license.csv`](data/year_per_oa_type_and_license.csv) Publication volume per license and OA type. See also [`analysis/006_license.Rmd`](analysis/006_license.Rmd)

- [`data/hybrid_oa_volume.csv`](data/hybrid_oa_volume.csv) (OA-)Article volume per journal. See also [`data-raw/hybrid_oa_volume.R`](data-raw/hybrid_oa_volume.R).

- [`data/jn_scopus_ind_subjects.csv`](data/jn_scopus_ind_subjects.csv) Journals article volume by year mapped to Scopus AJSC classification. See also  [`008_subject_exploration.Rmd`](analysis/008_subject_exploration.Rmd).

- [`data/x_journals_volume.csv`](data/x_journals_volume.csv) Article counts mirror journals. See also [`analysis/006_license.Rmd`](analysis/006_license.Rmd).

#### Funding body categorisation

- [`data/curated_invoicing_data.csv`](data/curated_invoicing_data.csv) result of the intellectual classification of funding bodies. 

#### Open APC data snapshot

- [`data/o_apc.csv`](data/o_apc.csv) Open APC data snapshot. See also [`data-raw/oapc_data.R`](data-raw/oapc_data.R)

### Reproducibility notes

This repository is Binder-ready. Binder provides an executable environment in the cloud. Using Binder, wou will be able to replicate the manuscript including all Figures and Tables using RStudio.

How it works:

- To launch Binder, click on the button [![Binder](http://mybinder.org/badge_logo.svg)](http://mybinder.org/v2/gh/njahn82/elsevier_hybrid_invoicing/master?urlpath=rstudio). Now, all computational dependencies will be installed and RStudio launched.
- After RStudio was launched, open `analysis/manuscript.Rmd` and click the "Knit" button.
- All code embedded in the RMarkdown file will be executed. The resulting .tex file will be rendered to PDF. 

Note that we imported the LaTex file to Overleaf for a few final collaborative proofs.

### License

We assert no claims of ownership for data acquired through the use of the Crossref, Scopus and Elsevier XML full-texts.  

Source Code: MIT (Najko Jahn, 2021)

### Contributors

- [Najko Jahn](https://twitter.com/najkoja), [Lisa Matthias](https://twitter.com/l_matthia), [Mikael Laakso](https://twitter.com/mikaellaakso)

### Contributing

This data analytics works has been developed using open tools. There are a number of ways you can help make it better:

- If you don’t understand something, please let me know and [submit an issue](https://github.com/njahn82/elsevier_hybrid_invoicing/issues).

Feel free to add new features or fix bugs by sending a pull request.

### Code of Conduct
  
Please note that the elsevier_hybrid_invoicing project is released with a [Contributor Code of Conduct](https://contributor-covenant.org/version/2/0/CODE_OF_CONDUCT.html). By contributing to this project, you agree to abide by its terms.

### Contact

Najko Jahn, Data Analyst, SUB Göttingen. najko.jahn@sub.uni-goettingen.de






