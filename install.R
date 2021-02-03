# only packages used in manuscript.Rmd
my_packages <- c("tidyverse", "here", "cowplot", "gt", 
                 "janitor", "kableExtra", "stringr")
install.packages(my_packages, dependencies=TRUE)
