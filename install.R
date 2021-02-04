# only packages used in manuscript.Rmd
my_packages <- c("tidyverse", "here", "cowplot", "gt", 
                 "janitor", "kableExtra", "stringr", "tinytex")
install.packages(my_packages, dependencies=TRUE)
tinytex::install_tinytex()
