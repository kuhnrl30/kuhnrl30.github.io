---
layout: default
title: Predicting Success in Moocs R Code
Resume: passive
Projects: passive
blog: passive
moocs: passive
contact: passive
description: R Code Used for the Predicting Success in Moocs Competition
---

### Predicting Dropouts in Moocs  
  
<pre>
# Environment ----
setwd("C:/Users/Ryan/Dropbox/RProjects/Mooc")
package.list<- c("dplyr","tidyr","ROCR","doParallel","foreach","ggplot","caTools")
lapply(package.list, require, character.only = TRUE)


# load the data ----
train.enrollment<- read.csv("train/train/enrollment_train.csv",stringsAsFactors=F)
train.log	<- read.csv("train/train/log_train.csv",stringsAsFactors=F)
train.truth	<- read.csv("train/train/truth_train.csv",stringsAsFactors=F,header=F)
names(train.truth)	<- c("enrollment_id","drop")
object		<- read.csv("object/object.csv", stringsAsFactors=F)
test.log	<- read.csv("test/test/log_test.csv", stringsAsFactors=F)
test.enrollment <- read.csv("test/test/enrollment_test.csv",stringsAsFactors=F)


# Setup for processing -----
Courses   <- unique(object$course_id)
AUC.list  <- vector(mode=list,length=39)
Submit.df <- data.frame()


# OPTION 1: FOR LOOP  ----
for (i in 1:length(Courses)){
  courseid  <- Courses[i]
  Objects   <- subset(object,course_id==courseid)
  
  enrollment    <- subset(train.enrollment,course_id=courseid)
  testEnrollment<- subset(test.enrollment, course_id=courseid)
  
  log       <- subset(train.log, object %in% Objects$module_id)
  testlog   <- subset(test.log,  object %in% Objects$module_id)
  
  log.trim<-log %>%
    filter(object %in% unique(testlog$object)) %>%
    mutate(Occurence=1) %>%
    select(enrollment_id, object,Occurence) %>%
    group_by(enrollment_id,object) %>%
    summarise(Cnt = sum(Occurence))
  
  testlog.trim<-testlog %>%
    mutate(Occurence=1) %>%
    select(enrollment_id, object,Occurence) %>%
    group_by(enrollment_id,object) %>%
    summarise(Cnt = sum(Occurence))
  
  Data    <- spread(log.trim,object,Cnt, fill = 0)
  Data    <- left_join(Data,train.truth, 
                       by=c("enrollment_id"="enrollment_id"))
  TestData<- spread(testlog.trim,object,Cnt,fill=0)
  
  Logmdl   <- glm(drop~.-enrollment_id,data=Data, family=binomial)

  TestPredict<- predict(Logmdl,newdata=TestData,type="response")
  TestPredictdf<- data.frame(enrollment_id=TestData$enrollment_id,
                           Prediction=TestPredict)
  
  Submit.df <- data.frame(rbind(Submit.df,TestPredictdf))
  
  # print the stats as a status update
  print(paste("Iteration:",i,sep=" "))
  print(nrow(TestPredictdf))
  print(nrow(Submit.df))
}


Temp<- left_join(test.enrollment,Submit.df)
Temp<- Temp[,c(1,4)]
Temp$Prediction<- ifelse(is.na(Temp$Prediction),1,Temp$Prediction)
names(Temp)<-NULL
write.csv(Temp,"Submit.csv",row.names=F)




# OPTION 2: PARALLEL PROCESSING ----

cl<- makeCluster(3)
registerDoParallel(cl)

Submit<-foreach(i=1:length(Courses), 
	.combine="rbind",
	.packages=c("dplyr","tidyr")) %dopar%{
	
  courseid  <- Courses[i]
  Objects   <- subset(object,course_id==courseid)
  enrollment    <- subset(train.enrollment,course_id=courseid)
  testEnrollment<- subset(test.enrollment, course_id=courseid)
  
  log       <- subset(train.log, object %in% Objects$module_id)
  testlog   <- subset(test.log,  object %in% Objects$module_id)
  
  log.trim<-log %>%
    filter(object %in% unique(testlog$object)) %>%
    mutate(Occurence=1) %>%
    select(enrollment_id, object,Occurence) %>%
    group_by(enrollment_id,object) %>%
    summarise(Cnt = sum(Occurence))
  
  testlog.trim<-testlog %>%
    mutate(Occurence=1) %>%
    select(enrollment_id, object,Occurence) %>%
    group_by(enrollment_id,object) %>%
    summarise(Cnt = sum(Occurence))
  
  Data    <- spread(log.trim,object,Cnt, fill = 0)
  Data    <- left_join(Data,train.truth, 
                       by=c("enrollment_id"="enrollment_id"))
  TestData<- spread(testlog.trim,object,Cnt,fill=0)
  
  Logmdl   <- glm(drop~.-enrollment_id,data=Data, family=binomial)
  
  TestPredict<- predict(Logmdl,newdata=TestData,type="response")
  TestPredict<- data.frame(enrollment_id=TestData$enrollment_id,
                           Prediction=TestPredict)
  TestPredict

# Print stats as a status update
  print(paste("Iteration:",i,sep=" "))
  print(dim(Submit.df))
  print(dim(TestPredict))
}
stopCluster(cl)
</pre>

