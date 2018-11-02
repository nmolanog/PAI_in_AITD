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

load("../data/Rdata/DEP_data.RData")

choix%>%filter(!type %in% "p" & !is.na(denom))%>%select(var)%>%unlist()->var_to_res
var_to_res%>%str_subset("age")->age_vars
var_to_res<-setdiff(var_to_res,age_vars)

res_df<-NULL
list_mod<-list()
for(i in var_to_res){
  denom<-choix[choix$var %in% i,"denom"]
  z0%>%select(c("study",i,denom))%>%na.omit()->temp
  temp[temp[,denom]!=0,]->temp
  
  temp%>%{escalc(measure = "PLO", xi =eval(parse(text=i)),
                 ni = eval(parse(text=denom)), data = .,append = T)}->dat_temp
  
  m0<-rma(yi, vi, data = dat_temp, method = "FE")
  list_mod[[i]]<-m0
  res_df<-rbind(res_df,
                data.frame(var=i,n_studies=nrow(dat_temp),denom=denom,N=sum(dat_temp[,denom]),n=sum(dat_temp[,i]),
                           prop=1/(1+exp(-coef(m0))),ci95.lb=1/(1+exp(-m0$ci.lb)),ci95.ub=1/(1+exp(-m0$ci.ub))))
}

###age at onset
denom<-choix[choix$var %in% "age_mean","denom"]
z0%>%select(c("study",age_vars,denom))%>%na.omit()->z0_age
z0_age%>%{escalc(measure = "MN", mi =age_mean,sdi=age_sd,
               ni = eval(parse(text=denom)), data = .,append = T)}->dat_age
m0_age<-rma(yi, vi, data = dat_age, method = "FE")

res_age<-data.frame(var="age",n_studies=nrow(dat_age),denom=denom,N=sum(dat_age[,denom]),mean=coef(m0_age),ci95.lb=m0_age$ci.lb,ci95.ub=m0_age$ci.ub)

setwd("..")
if(!"./outputs" %in% list.dirs()){
  dir.create("outputs")
}
setwd("./outputs")

write.csv2(res_df,"descriptive.csv",row.names =F)
write.csv2(res_age,"descriptive_age.csv",row.names =F)

setwd(oldir)
