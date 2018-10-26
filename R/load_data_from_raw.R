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
file_nm<-"Datos_articulos_V3 Completa"
wb <- paste0("../data/raw/",file_nm,".xlsx")
getSheetNames(wb)
z0<-read.xlsx(wb, sheet =1, colNames = TRUE,na.strings = -1)
choix<-read.xlsx(wb, sheet =2, colNames = TRUE)
remove("wb")

file_nm<-"Datos EDAD _AITD"
wb <- paste0("../data/raw/",file_nm,".xlsx")
getSheetNames(wb)
zedad<-read.xlsx(wb, sheet =1, colNames = TRUE,na.strings = -1)
remove("wb")


setwd("../data")
if(!"./Rdata" %in% list.dirs()){
  dir.create("Rdata")
}
setwd("./Rdata")

save(z0,choix,zedad,file="data_PAI_in_AITD.RData")
setwd(oldir)
