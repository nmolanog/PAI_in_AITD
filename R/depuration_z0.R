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

###depurations
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

###verify choix
tempcn<-data.frame(colnames(z0),choix$var,stringsAsFactors =F)
tempcn%>%filter(colnames.z0.!=choix.var)
choix$var%>%table()->a
a[a>1]

##fix colnames
colnames(z0)%>%str_replace_all("-|/","_")->colnames(z0)
choix$var<-colnames(z0)


###check for proportions denom> n
choix%>%filter(!type %in% "p" & !is.na(denom))%>%select(var)%>%unlist()->var_to_res
var_to_res%>%str_subset("age")->age_vars
var_to_res<-setdiff(var_to_res,age_vars)

list_issues<-list()
for(i in var_to_res){
  denom<-choix[choix$var %in% i,"denom"]
  z0%>%select(c("study",i,denom))%>%na.omit()->temp
  if(any(temp[,denom]<temp[,i])){
    list_issues[[i]]<-temp[temp[,denom]<temp[,i],]
  }
}

#list_issues

###fix bad prop.
#z0%>%filter(study %in% "sari2009")
z0[z0$study %in% "sari2009", "hashipolya_n"]<-5
z0[z0$study %in% "demartino2014", c("ra_n","ps_n")]<-NA
z0[z0$study %in% "taktonidou2004", c("serpolya_n")]<-58

###take out constant vars
z0%>%{map_dbl(.,~num.clas(.x))}->numcls
numcls%>%.[. %in% c("0") | is.na(.)]%>%names->constant_vars

z0%>%select(-constant_vars)->z0
choix[!choix$var %in% constant_vars,]->choix

setwd("../data/Rdata")

save(z0,choix,file="DEP_data.RData")
setwd(oldir)
