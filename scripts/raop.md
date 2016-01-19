---
layout: default
title: Random Acts of Pizza R Code
Resume: passive
Projects: passive
blog: passive
moocs: passive
contact: passive
description: R Code Used for the Random Acts of Pizza Competition
---

### Random Acts of Pizza
<pre>
# setup the environment
# load all of the libraries used during the analysis up front

library(rjson)      # read in the dataset
library(plyr)       # data manipulation
library(dplyr)      # data manipulation
library(vcd)        # plotting
library(lattice)    # plotting
library(pROC)       # scoring the training model
library(rpart)      # Create the model
library(rpart.plot) # plot classifier
library(knitr)
library(tm)
library(caTools)    #Split trainingset
library(randomForest)
setwd(paste("C:/users/",Sys.getenv("USERNAME"),"/dropbox/RProjects/RAOP",sep=""))
opts_chunk$set(cache=FALSE,fig.height=3,echo=FALSE,comment="")


# Read in the training dataset
Train.raw<- fromJSON(file="../data/train.json",method='C')

# Convert first and second level null list values to NA
Train.raw<-lapply(Train.raw,lapply,function(x) ifelse(is.null(x),NA,x)) 

Train.raw<-lapply(Train.raw,lapply,lapply,function(x) ifelse(is.null(x),NA,x))

train<-as.data.frame(matrix(unlist(Train.raw),
                            byrow=T,
                            nrow=length(Train.raw)),
                     stringsAsFactors=F)

train<- tbl_df(train)

# name the data frame columns using the names from the original list
names(train)<-names(Train.raw[[1]])

# remove the raw dataset to clear some memory
rm(Train.raw)

# Do the same to load the test set
Test.raw<- fromJSON(file="../data/test.json", method='C')
Test.raw<- lapply(Test.raw,lapply,function(x) ifelse(is.null(x),NA,x))
Test.raw<- lapply(Test.raw,lapply,lapply,function(x) ifelse(is.null(x),NA,x))
test <- data.frame(matrix(unlist(Test.raw),
                             byrow=T,
                             nrow=length(Test.raw)),
                      stringsAsFactors=F)

test<- tbl_df(test)
names(test)<- names(Test.raw[[1]])
test<-as.data.frame(lapply(test,function(x) gsub("N/A",NA,x)),stringsAsFactors=F)


# Convert all N/A to NA
train<-as.data.frame(lapply(train,function(x) gsub("N/A",NA,x)),stringsAsFactors=F)

NA.list<-ldply(lapply(train,function(x) sum(is.na(x))))
NA.df  <-data.frame(matrix(unlist(NA.list),nrow=32,byrow=F),stringsAsFactors=F)
NA.df %>%
    filter(X2>0) %>%
    mutate(Variable=X1,NACount=X2) %>%
    select(Variable,NACount) %>%
    format(justify="left") %>%
    print(row.names=F)


#remove columns not in test set
train<-train[,-c(2:4,6,7,11,13,15,17,19,21,26,28:29)]

#rearrange so target value is the last column and index values will match
train<-train[,c(1:11,13:18,12)]


train[,c(5:11,13:14)]<- apply(train[,c(5:11,13:14)],2,as.numeric)
train$requester_received_pizza<-ifelse(train$requester_received_pizza=="TRUE",1,0)


# Convert date field to POSIXct format and create field for the year
train$unix_timestamp_of_request_utc<-as.POSIXct(as.numeric(train$unix_timestamp_of_request_utc),
                                               origin= "1970-01-01",
                                               tz="UTC")
train$Year<- factor(format(train$unix_timestamp_of_request_utc,format='%Y'))

train %>%
    group_by(Year) %>%
    summarise(Count=length(Year),
              Success= sum(requester_received_pizza==1)) %>%
    mutate(Percent=paste(round(Success/Count,3)*100,"%", sep=""))


train$weekday<- factor(weekdays(train$unix_timestamp_of_request_utc))

train %>%
    group_by(weekday) %>%
    summarise(Count=length(weekday),
              Success=sum(requester_received_pizza==1)) %>%
    mutate(Percent=paste(round(Success/Count,3)*100,"%",sep="")) 


train$giver_username_if_known<- ifelse(is.na(train$giver_username_if_known),0,1)

train %>%
    group_by(giver_username_if_known) %>%
    summarise(Count=length(giver_username_if_known),
              Success= sum(requester_received_pizza==1)) %>%
    mutate(Percent=paste(round(Success/Count,3)*100,"%",sep=""))


train$Image<- ifelse(grepl("i.imgur",train$request_text),1,0)

train %>%
    group_by(Image) %>%
    summarise(Count=length(Image),
              Success= sum(requester_received_pizza==1)) %>%
    mutate(percent=paste(round(Success/Count,3)*100,"%",sep=""))


train$Acct.Age<-ifelse(train$requester_account_age_in_days_at_request>7,1,0)

train %>%
    group_by(Acct.Age) %>%
    summarise(Count=length(Acct.Age),
              Success= sum(requester_received_pizza==1)) %>%
    mutate(Percent=paste(round(Success/Count,3)*100,"%",sep=""))


train$BnRAOP<-ifelse(train$requester_number_of_comments_in_raop_at_request>8,1,0)
train %>%
    group_by(BnRAOP) %>%
    summarise(Count=length(BnRAOP),
              Success= sum(requester_received_pizza==1)) %>%
    mutate(Percent=paste(round(Success/Count,3)*100,"%",sep=""))


train$Words<- sapply(strsplit(train$request_text," ",fixed=T),length)

train<- within(train, Word.bin<- as.integer(cut(Words,
                                                      quantile(Words, probs=0:2/2), 
                                                      include.lowest=T)))
train %>%
    group_by(Word.bin) %>%
    summarise(Count=length(Word.bin),
              Success= sum(requester_received_pizza==1)) %>%
    mutate(Percent=paste(round(Success/Count,3)*100,"%",sep=""))

	
# Convert back to a dataframe
#train<-as.data.frame(train)

split<-sample.split(train$requester_received_pizza,0.75)
ttrain<-subset(train,split==TRUE)
hold<- subset(train,split==FALSE)


TrainCorpus<-Corpus(VectorSource(ttrain$request_text_edit_aware))
TrainCorpus<-tm_map(TrainCorpus,content_transformer(tolower))
TrainCorpus<-tm_map(TrainCorpus, PlainTextDocument)
TrainCorpus<-tm_map(TrainCorpus,removePunctuation)
TrainCorpus<-tm_map(TrainCorpus,removeWords, 
                    c("pizza","anyon",stopwords("english")))
TrainCorpus<-tm_map(TrainCorpus,stemDocument)
TrainCorpus<-tm_map(TrainCorpus,removeWords,c("anyon","anyth","appreci","back"))
dtmTrain<- DocumentTermMatrix(TrainCorpus)

sparseTrain<-removeSparseTerms(dtmTrain,0.90)

wordsTrain<-as.data.frame(as.matrix(sparseTrain), row.names=F)

Targets<-colnames(wordsTrain)
colnames(wordsTrain) = paste("A", colnames(wordsTrain),sep="")

TextTrain<-data.frame(wordsTrain,
                      requester_received_pizza=ttrain$requester_received_pizza, 
                      row.names=NULL)

LogMdl<-glm(requester_received_pizza~.,data=TextTrain,family=binomial)


holdCorpus<-Corpus(VectorSource(hold$request_text_edit_aware))
holdCorpus<-tm_map(holdCorpus,content_transformer(tolower))
holdCorpus<-tm_map(holdCorpus, PlainTextDocument)
holdCorpus<-tm_map(holdCorpus,removePunctuation)
holdCorpus<-tm_map(holdCorpus,stemDocument)
holdCorpus<-tm_map(holdCorpus,removeWords, 
                    c("pizza",stopwords("english")))
dtmHold<- DocumentTermMatrix(holdCorpus)

#wordsTest<-inspect(dtmTest[,colnames(dtmTest) %in% Targets])
wordsHold<-as.data.frame(as.matrix(dtmHold[,colnames(dtmHold) %in% Targets]), row.names=F)

colnames(wordsHold) = paste("A", colnames(wordsHold),sep="")
TextHold<-data.frame(wordsHold,row.names=NULL)

ttrain %>%
    summarise(N=length(requester_received_pizza),
              Success=sum(requester_received_pizza)) %>%
    mutate(Percent=paste(round(Success/N,3)*100,"%",sep=""))


train.glm<-glm(requester_received_pizza~ giver_username_if_known+BnRAOP+Word.bin+Year*weekday+Acct.Age,
               family=binomial,
               data=ttrain)


summary(train.glm)



CART<- rpart(requester_received_pizza~giver_username_if_known+Word.bin+Year+weekday+Words+Image+Acct.Age+BnRAOP, data=ttrain,
           method="class",
           na.action=na.rpart,
           control=rpart.control(xval=10,cp=0.05,minbucket=10))

CART<-prune(CART,cp=0.05)

prp(CART, 
    main= "RAOP Classification Tree",
    extra=1,
    box.col=c("pink","palegreen")[CART$frame$yval],
    leaf.round=2)

	
RFTrain<- data.frame(cbind(ttrain[,c(1,19:25)], TextTrain), row.names=NULL)
names(RFTrain)[1:8]<-names(ttrain[,c(1,19:25)])
names(RFTrain)[9:53]<-names(TextTrain)

Forest<- randomForest(factor(requester_received_pizza)~., 
                      data=RFTrain,
                      nodesize=5)

					  
					  
RFHold<- data.frame(cbind(hold[,c(1,19:25)], TextHold))
names(RFHold)[1:8]<-names(hold[,c(1,19:25)])
names(RFHold)[9:53]<-names(TextHold)


glmpred<-predict.glm(train.glm,newdata=hold, type="response")
Textpred<-predict(LogMdl,newdata=TextHold,type="response")
CARTpred<- predict(CART,newdata=hold,type="prob")
ForestPredTrain<-predict(Forest,newdata=RFHold,type="prob",metric="ROC")


Predictions<-data.frame(GLM=glmpred,Text=Textpred,CART=CARTpred[,2],Forest=ForestPredTrain[,2])
weights<-c(.3,.2,.2,.3)
Weighted<-rowSums(Predictions*weights)
table(hold$requester_received_pizza, Weighted>0.5)

score<-auc(as.numeric(hold$requester_received_pizza),Weighted)
score


# Apply the models
test[,c(5:11,13:14)] <- apply(test[,c(5:11,13:14)], 2,as.numeric)
test$giver_username_if_known<- ifelse(is.na(test$giver_username_if_known),0,1)
test$unix_timestamp_of_request_utc<-as.POSIXct(as.numeric(test$unix_timestamp_of_request_utc),
                                                origin= "1970-01-01",
                                               tz="UTC")
test$Year     <- factor(format(test$unix_timestamp_of_request_utc,format='%Y'))
test$weekday  <- factor(weekdays(test$unix_timestamp_of_request_utc))
test$Image    <- ifelse(grepl("i.imgur",test$request_text),1,0)
test$Acct.Age <-ifelse(test$requester_account_age_in_days_at_request>7,1,0)
test$BnRAOP   <- ifelse(test$requester_number_of_comments_in_raop_at_request>8,1,0)
test$Words    <- sapply(strsplit(test$request_text," ",fixed=T),length)
test$Word.bin <- ifelse(test$Words<29,1,0)


TestCorpus<-Corpus(VectorSource(test$request_text_edit_aware))
TestCorpus<-tm_map(TestCorpus,content_transformer(tolower))
TestCorpus<-tm_map(TestCorpus, PlainTextDocument)
TestCorpus<-tm_map(TestCorpus,removePunctuation)
TestCorpus<-tm_map(TestCorpus,stemDocument)
TestCorpus<-tm_map(TestCorpus,removeWords, 
                    c("pizza",stopwords("english")))

dtmTest<- DocumentTermMatrix(TestCorpus)

wordsTest<-as.data.frame(as.matrix(dtmTest[,colnames(dtmTest) %in% Targets]), row.names=F)

#wordsTest<-inspect(dtmTest[,colnames(dtmTest) %in% Targets])
colnames(wordsTest) = paste("A", colnames(wordsTest),sep="")
TextTest<-data.frame(wordsTest,row.names=NULL)

RFTest <- data.frame(cbind(test [,c(1,18:24)], TextTest ))
names(RFTest)[1:8]<-names(test[,c(1,18:24)])
names(RFTest)[9:54]<-names(TextTest)


GLMLogPred <- predict.glm(train.glm,newdata=test, type="response")
TextLogPred<- as.numeric(predict(LogMdl,newdata=TextTest,type="response"))
CARTPred   <- predict(CART,newdata=test, type="prob")
ForestPred<-predict(Forest,newdata=RFTest,type="prob",metric="ROC")

# Create the submit file
Predictions<- data.frame(GLM=GLMLogPred,Text=TextLogPred, CART=CARTPred[,2],Forest=ForestPred[,2])
weightedPred<-Predictions*weights
Temp<- rowSums(weightedPred,na.rm=T)
Submit<- data.frame(request_id=test$request_id,
                    requester_received_pizza=Temp)
write.csv(Submit,"submit.csv",row.names=F)
</pre>
