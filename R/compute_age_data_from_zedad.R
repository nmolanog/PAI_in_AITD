#######################
###load data
#######################
rm(list=ls())
options(max.print=999999)
library(here)
library(openxlsx)
library(tidyverse)
library(bueri)
library(metafor)
oldir<-getwd()

list.files("../data/Rdata")%>%str_subset(".RData")

load("../data/Rdata/data_PAI_in_AITD.RData")
zedad[zedad == -1]<-NA

zedad<-na.omit(zedad)
tores<-NULL

for(i in unique(zedad$study)){
  zedad%>%filter(study %in% i)->temp_df
  temp_df%>%{escalc(measure = "MN", mi =mean_age, sdi=age_sd,ni = n, data = .,append = T)}->dat_temp
  m0<-rma(yi,vi, data = dat_temp, measure = "MN", method="FE")
  tores<-rbind(tores,data.frame(mean_age=m0$beta,age_sd=m0$se,study=i))
}

tores->missin_ages
setwd("../data/Rdata")

save(missin_ages,file="missin_ages.RData")
setwd(oldir)