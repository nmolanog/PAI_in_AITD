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
load("../data/Rdata/new_data.RData")

znew%>%colnames%>%{!. %in% colnames(z0)}

znew$aps_n<-NULL

cbind(colnames(z0),colnames(znew))
colnames(znew)<-colnames(z0)

z1<-rbind(z0,znew)
z0<-z1
setwd("../data")
if(!"./Rdata" %in% list.dirs()){
  dir.create("Rdata")
}
setwd("./Rdata")

save(z0,choix,file="merged_data.RData")
setwd(oldir)
