---
layout: script
title: Home Depot Search Relevancy
Resume: passive
Projects: passive
blog: passive
moocs: passive
contact: passive
description: R Code Used for the Home Depot Search Relevancy Kaggle Competition
---


### Home Depot Search Relevancy
Each of these code sections was in different files to make it easier to maintain.  If you are reproducing this workflow, you may not need to save and load the datasets as frequently. 

#### Functions  

<pre>
# Function calculates the number of words in the query match the title, description 
# and brand fields. It loops through the query and adds 1 for each match. The output of 
# the function is a vector of integers. 

word_match <- function(words,title,desc, brand){
  n_title <- 0
  n_desc <- 0
  n_brand <- 0
  words <- unlist(strsplit(words," "))
  nwords <- length(words)
  for(i in 1:length(words)){
    pattern <- paste("(^| )",words[i],"($| )",sep="")
    n_title <- n_title + grepl(pattern,title,perl=TRUE,ignore.case=TRUE)
    n_desc <- n_desc + grepl(pattern,desc,perl=TRUE,ignore.case=TRUE)
    n_brand <- n_brand + grepl(pattern,brand,perl=TRUE,ignore.case=TRUE)
	}
  return(c(n_title,nwords,n_desc, n_brand))
  }

# This function prcesses the input to make it easier for the word_match function. The 
# function is to be applied to the search query, title, description, and brand fields. 
# The words in the output should be stemmed and without punctuation.  There will also 
# substitutions to standardize dfferences in pounds vs lbs for example. 

TextProcess<- function(x){
  require(tm)
  z<- tolower(x)
  z<- gsub("(  )|\\$|\\?|-", " ", z)
  z<- gsub("( x )|\\*|(by)", "xbi", z)
  z<- gsub("(inches)|(in\\.)", "in", z)
  z<- gsub("((pounds)|(lbs)|(lbs\\.))", "lb", z)
  z<- gsub("((gallon)|(gal\\.)|(gallons))", "gal", z)
  z<- gsub("((ounce)|(oz\\.)|(ounces))", "oz", z )
  z<- gsub("(centimeters)|(cm\\.)", "cm", z )
  z<- gsub("(amperes)|(ampere)|(amps)|( amp )", "amp", z )
  z<- gsub("(volts)", "volt", z )
  z<- gsub("((square)|(sq))((\\s)|(\\.))((foot)|(ft))", " SqFt", z )
  z<- gsub("((cubic)|(cu))((\\s)|(\\.))((foot)|(ft))", " CuFt", z )
  z<- gsub("([0-9])x([0-9])", "\1 xbi \2", z )
  z<- gsub(" \\ ", " ", z)
  z<-Corpus(VectorSource(z))
  z<-tm_map(z, PlainTextDocument)
  z<-tm_map(z, removePunctuation)
  z<-tm_map(z, removeWords,stopwords("english"))
  z<-tm_map(z, stemDocument)
  sapply(1:length(x), function(y) as.character(z[[y]][[1]]))
  }
</pre>

#### Make Spell Check Dictionary  
One of the competitors created a spell check dictionary and posted it to the forums.  They did this by submitting the search queries to Google search and captured Google's suggested spelling. I copied the text from the forum and saved it to a text file. This section of code reads that text and converts it to a dataframe.  Later, I will join this dataframe to the Training set and  substitute the suggested correct spellings. 

<pre>
rawdict<- readLines("data/dictionary")
rawdict<- strsplit(rawdict, split=":", fixed=T)

rawdict<-data.frame(matrix(unlist(rawdict), ncol=2, byrow=T), stringsAsFactors=F)

dict<- rawdict
dict[,1]<- gsub("(^\')|(\')$","", dict[,1])
dict[,2]<- gsub("(,)$","", dict[,2])
dict[,2]<- gsub("(^ +\')|(\')$","", dict[,2])
names(dict)<- c("Orig","New")

write.csv(dict,"data/clean-dictionary.csv", row.names=F)
</pre>

#### Clean and Prepare Data  
<pre>
# Setup the Environment
library(dplyr, quietly = T)
library(tm)
setwd("C:/users/ryan/dropbox/rprojects/homedepot")
source("scripts/0_functions.R")


Train       <- read.csv("Data/train.csv", 
                        header=T, 
                        stringsAsFactors = F)

Test        <- read.csv("Data/test.csv", 
                        header=T, 
                        stringsAsFactors = F)

Attributes  <- read.csv("Data/attributes.csv", 
                        header=T, 
                        stringsAsFactors = F)

Descriptions<- read.csv("Data/product_descriptions.csv", 
                        header=T, 
                        stringsAsFactors = F)


# Use spell check file ----
Dictionary<- read.csv("data/clean-dictionary.csv", 
                      stringsAsFactors=F,
                      header=T)

Train<- left_join(Train,Dictionary, by=c("search_term"="Orig"))
Train$New<- ifelse(is.na(Train$New), Train$search_term, Train$New)

Test<- left_join(Test, Dictionary, by=c("search_term"="Orig"))
Test$New <- ifelse(is.na(Test$New), Test$search_term, Test$New)


# Extract Brand name from attributes data
df_brand<- Attributes %>% filter(name=="MFG Brand Name") %>%dplyr::rename(brand= value)

Train<- left_join(Train, df_band)
Test<- left_join(Test, df_brand)

# Apply Text Processing functions 
print("Processing text")
Descriptions$NewDesc<- TextProcess(Descriptions$product_description)
Train$NewTitle      <- TextProcess(Train$product_title)
Train$NewSearch     <- TextProcess(Train$New)
Train$brand         <- TextProcess(Train$brand)
Test$NewSearch      <- TextProcess(Test$New)
Test$NewTitle       <- TextProcess(Test$product_title)
Test$brand          <- TextProcess(Test$brand)

Train<- left_join(Train, Descriptions)
Test<- left_join(Test, Descriptions)



# Convert word_match output to features 
print("Calc the summary stats")
train_words <- as.data.frame(t(mapply(word_match, 
                                      Train$NewSearch, 
                                      Train$NewTitle, 
                                      Train$NewDesc,
                                      Train$brand)))

Train$nmatch_title <- train_words[,1]
Train$nwords <- train_words[,2]
Train$nmatch_desc <- train_words[,3]
Train$nmatch_brand<- train_words[,4]



test_words <- as.data.frame(t(mapply(word_match, 
                                     Test$NewSearch, 
                                     Test$NewTitle, 
                                     Test$NewDesc,
                                     Test$brand)))
Test$nmatch_title <- test_words[,1]
Test$nwords <- test_words[,2]
Test$nmatch_desc <- test_words[,3]
Test$nmatch_brand <- test_words[,4]


save(Train, Test, file="data/Datasets.Rdata")
rm(train_words, test_words, Descriptions, Attributes)

</pre>

#### Prepare the Model
<pre>

# Setup the Environment
library(dplyr)
library(caret)
setwd("C:/users/ryan/dropbox/rprojects/homedepot")
load("data/datasets.Rdata")



# Setup for parallel processing
library(doParallel)
cl <- makeCluster(3)
registerDoParallel(cl)

# Train the models 
glm_ctrl<- trainControl(method="repeatedCV",
                        number=10,
                        repeats=10,
                        predictionBounds = c(1,3),
                        allowParallel = TRUE)

glm_mdl<- train(relevance~nmatch_title+nmatch_desc+nwords+nmatch_brand,
                data=Train,
                method="glm")

# ------
svm_ctrl<- trainControl(classProbs=FALSE,
                        method="repeatedcv",
                        repeats=5,
                        allowParallel = TRUE)

svm_mdl<- train(relevance~nmatch_title+nmatch_desc+nwords+nmatch_brand, 
                data=Train,
                model="svmLinear",
                tuneLength=3,
                metric="RMSE",
                trControl=svm_ctrl)

# ------
xgb_ctrl<- trainControl(allowParallel = TRUE,
                        number= 5,
                        repeats=2,
                        method="repeatedcv")

xgbGrid <- expand.grid(nrounds = 20,
                       lambda = 0,
                       alpha = 0)

xgb_mdl<- train(relevance~nmatch_title+nmatch_desc+nwords+nmatch_brand,
                data = Train,
                method = "xgbLinear",
                tuneLength = 3,
                trControl = xgb_ctrl,
                tuneGrid = xgbGrid)


stopCluster(cl)






Pred_trn<- data.frame(XGB= predict(xgb_mdl, newdata=Train),
                      SVM= predict(svm_mdl, newdata=Train),
                      GLM= predict(glm_mdl, newdata=Train))

# Get RMSE of average of 3 models
RMSE <- sqrt(mean((Train$relevance-rowMeans(Pred_trn))^2))
RMSE
# 0.4850955

# Stacked model: train a simple linear model on top of Train and output of 3 models
NewTrain<- cbind(Train, Pred_trn)
stk_mdl <- lm(relevance~nmatch_title+nmatch_desc+nwords+nmatch_brand + XGB +SVM + GLM,
             data=NewTrain)

stk_prd  <- predict(stk_mdl, newdata=NewTrain)
RMSE_stk <- sqrt(mean((Train$relevance-stk_prd)^2))
RMSE_stk
# 0.4831937- slight improvement


Pred_glm<- predict(glm_mdl, newdata=Test)
Pred_svm<- predict(svm_mdl, newdata=Test)
Pred_xgb<- predict(xgb_mdl, newdata=Test)



Pred_test<- data.frame(XGB = predict(xgb_mdl, newdata=Test),
                       SVM = predict(svm_mdl, newdata=Test),
                       GLM = predict(glm_mdl, newdata=Test))


NewTest<- data.frame(Test, Pred_test)
Predict<- predict(stk_mdl, newdata=NewTest)

# Minimal post processing
Predict<- ifelse(Predict>3, 3, Predict)
Predict<- ifelse(Predict<1, 1, Predict)

# Prepare submit file 
submit<- data.frame(id= Test$id, relevance= Predict )
write.csv(submit, file="Submit.csv", row.names=F)
</pre>