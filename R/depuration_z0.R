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

##Some verifications
z0%>%select(c("study",colnames(z0)%>%str_subset("age"),"aitd_cases_n"))%>%inner_join(zedad,by="study")
zedad%>%group_by(study)%>%summarise(sum(n))

load("../data/Rdata/missin_ages.RData")

for(i in as.character(missin_ages$study)){
  z0[z0$study %in% i,colnames(z0)%>%str_subset("age")]<-missin_ages[missin_ages$study %in% i,colnames(missin_ages)%>%str_subset("age")]
}

z0%>%select(colnames(z0)%>%str_subset("age|study"))%>%filter(study %in% missin_ages$study)

for (i in colnames(z0)) {
z0[z0[,i] ==-1,i]  <- NA
}

z0[z0$female_n %in% "8,89:1", "aitd_cases_n"]

z0$region[z0$region %in% " asia"]<-"asia"

z0$female_n[z0$female_n %in% "8,89:1"]<-round(8.89/(1+8.89)*z0[z0$female_n %in% "8,89:1", "aitd_cases_n"],0)
z0$male_n[z0$male_n %in% "8,89:1"]<-round((1-(8.89/(1+8.89)))*z0[z0$male_n %in% "8,89:1", "aitd_cases_n"],0)

z0[z0$age_mean %in% c("52/45","47,5/47,3","13,8 f / 13,9 m"),"study"]%>%{filter(zedad,study %in% .)}
z0$age_mean[z0$age_mean %in% c("52/45","47,5/47,3","13,8 f / 13,9 m")]<-NA

for(i in c("female_n","male_n","age_mean","age_sd")){
  z0[,i]<-as.numeric(z0[,i])
}

z0%>%map(unique)

setwd("../data/Rdata")

save(z0,choix,file="DEP_data.RData")
setwd(oldir)
