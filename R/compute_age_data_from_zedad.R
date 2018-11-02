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

gr_mean<-function(mi,sdi,ni){
  pld_mean<-sum(mi*ni)/sum(ni)
  pld_sd<- sqrt((sum(ni*sdi^2)+sum(ni*(mi-mean(mi))^2))/(sum(ni)-1))
  return(c(pld_mean=pld_mean,pld_sd=pld_sd))
}

for(i in unique(zedad$study)){
  zedad%>%filter(study %in% i)->temp_df
  temp_res<-gr_mean(temp_df$mean_age,temp_df$age_sd,temp_df$n)
  tores<-rbind(tores,data.frame(mean_age=temp_res[1],age_sd=temp_res[2],study=i))
}

tores->missin_ages
setwd("../data/Rdata")

save(missin_ages,file="missin_ages.RData")
setwd(oldir)