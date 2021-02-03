# only packages used in manuscript.Rmd
my_packages <- c("tidyverse", "here", "cowplot", "gt", 
                 "janitor", "kableExtra", "stringr")
install.packages(my_packages,
                 repos='https://mran.microsoft.com/snapshot/2021-01-31/', 
                 dependencies=TRUE)
