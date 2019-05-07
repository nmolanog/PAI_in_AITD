#######################
###load data
#######################
rm(list=ls())
options(max.print=999999)
library(here)
library(openxlsx)
library(tidyverse)
library(bueri)
oldir<-getwd()


list.files("../data/raw")%>%str_subset(".xlsx")
file_nm<-"new_data"
wb <- paste0("../data/raw/",file_nm,".xlsx")
getSheetNames(wb)
znew<-read.xlsx(wb, sheet =1, colNames = TRUE,na.strings = -1)
remove("wb")

for(i in colnames(znew)){
  znew[znew[,i] %in% -1,i]<-NA
}


setwd("../data")
if(!"./Rdata" %in% list.dirs()){
  dir.create("Rdata")
}
setwd("./Rdata")

save(znew,file="new_data.RData")
setwd(oldir)
