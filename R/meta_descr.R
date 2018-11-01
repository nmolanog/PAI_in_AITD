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

i<-"hashimoto_n"
denom<-choix[choix$var %in% i,"denom"]
z0%>%select(c("study",i,denom))%>%na.omit()->temp

temp%>%{escalc(measure = "PLO", xi =eval(parse(text=i)),
       ni = eval(parse(text=denom)), data = .,append = T)}->dat_temp

m0<-rma(yi, vi, data = dat_temp, method = "FE")

summary(m0)
1/(1+exp(-coef(m0)))
