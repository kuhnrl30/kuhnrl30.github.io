---
layout: default
title: Predicting Sales in Stormy Weather R Code
Resume: passive
Projects: passive
blog: passive
moocs: passive
contact: passive
description: R Code Used for Walmart- Predicting Sales in Stormy Weather Competition
---

### Walmart: Predicting Sales in Stormy Weather
<pre>
# Setup the environment
library(dplyr)
library(ggplot2)


# Load Data 
key     <- read.csv("key.csv")
weather <- read.csv("weather.csv", stringsAsFactor=F, na.strings=c("M","-"))
train   <- tbl_df(read.csv("train.csv",stringsAsFactors=F))
test    <- tbl_df(read.csv("test.csv",stringsAsFactors=F))
sample  <- read.csv("samplesubmission.csv")

# Convert the date formats
train$date <- as.POSIXct(as.character(train$date), format= "%Y-%m-%e")
test$date  <- as.POSIXct(as.character(test$date),  format= "%Y-%m-%e")
weather$date  <- as.POSIXct(as.character(weather$date),  format= "%Y-%m-%e")

train$store_nbr<-factor(train$store_nbr)
train$item_nbr<- factor(train$item_nbr)
test$store_nbr <-factor(test$store_nbr)
test$item_nbr<- factor(test$item_nbr)
test$id<- paste(test$store_nbr,test$item_nbr,test$date, sep="_")


# Set the baseline, naive model
base <- train %>%
  group_by(store_nbr,item_nbr) %>%
  summarise(units=mean(units,na.rm=T)) 

# Use the average sales by store from the training set as the prediction
basepred <- test %>%
  left_join(y=base) %>%
  select(id,units)

# Create the submission file
submit<- data.frame(cbind(ID,as.numeric(basepred$units)))
names(submit)<- c("id","units")
write.csv(submit,"submit.csv", row.names=F)

# Cleanup 
rm(base,basepred)
</pre>