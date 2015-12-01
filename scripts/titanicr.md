---
layout: default
title: Titanic R Code
Resume: passive
Projects: passive
blog: passive
moocs: passive
contact: passive
description: R Code Used for Titanic- Learning from Disaster Competition
---

### Titanic- Machine Learning from Disaster (R Code)

<pre>
# Setup the environment
setwd("/Users/Owner/Documents/Analytics/RProjects/Data")
Train<- read.csv("titanic-train.csv", stringsAsFactors=FALSE)


# To visualize the survival rate by sex
plot(density(Train$Pclass,na.rm=TRUE))
counts<- table(Train$Survived, Train$Sex)
barplot(counts, xlab="Gender",ylab="No of People")
counts[2] / (counts[1] + counts[2])
counts[4] / (counts[3] + counts[4])


# To visualize the survival rate by passenger class
Pclass_survival <- table(Train$Survived, Train$Pclass)
barplot(Pclass_survival, xlab = "Cabin Class", ylab = "Number of People",
        main = "survived and deceased between male and female")

# To visualize the survival rate accross age and sex.
plot(trainData$Age,trainData$Sex, pch=20,
     col=ifelse(trainData$Survived>0,"red","black"))


# To convert sex as string values to numerical data
trainData<-Train[-c(1,9,11:12)]
trainData$Sex<- gsub("female",1,trainData$Sex)
trainData$Sex<- gsub("male",0,trainData$Sex)
trainData$Sex<-as.factor(trainData$Sex)


# Data conversion- the name field is reduced to the title (Mr. etc) for most items.  Non conforming items, such as Colonel, were left.
master.vector<- grep("Master", trainData$Name,fixed=TRUE)
miss.vector<- grep("Miss.", trainData$Name, fixed=TRUE)
mrs.vector<- grep("Mrs", trainData$Name, fixed=TRUE)
dr.vector<- grep("Dr.", trainData$Name, fixed=TRUE)
rev.vector<- grep("Rev.", trainData$Name, fixed=TRUE)
mr.vector<- grep("Mr.", trainData$Name, fixed=TRUE)

for(i in master.vector) {
  trainData$Name[i] = "Master"
  }
for(i in miss.vector) {
  trainData$Name[i] <- "Miss"
}
for(i in mrs.vector) {
  trainData$Name[i] <- "Mrs"
  }
for(i in mr.vector) {
  trainData$Name[i] <- "Mr"
  }
for(i in dr.vector) {
  trainData$Name[i] <- "Dr"
}
for(i in rev.vector) {
  trainData$Name[i] <- "Rev"
}

pat<-"Rev|Master|Mrs|Mr|Dr|Miss"
society.vector<- grep(pat, trainData$Name,invert=TRUE)
for(i in society.vector) {
  trainData$Name[i] <- "Society"
}

# Fill missing vlue for age
master.age <-round(mean(trainData$Age[trainData$Name=="Master"],na.rm=TRUE,digit=2))
miss.age <-round(mean(trainData$Age[trainData$Name=="Miss"],na.rm=TRUE,digit=2))
mister.age <-round(mean(trainData$Age[trainData$Name=="Mr"],na.rm=TRUE,digit=2))
mrs.age <-round(mean(trainData$Age[trainData$Name=="Mrs"],na.rm=TRUE,digit=2))
dr.age <-round(mean(trainData$Age[trainData$Name=="Dr"],na.rm=TRUE,digit=2))

for(i in 1:nrow(trainData)){
  if(is.na(trainData[i,5])){
    if (trainData$Name[i]=="Master"){
      trainData$Age[i] = master.age
      }   else if (trainData$Name[i]=="Miss"){
      trainData$Age[i] = miss.age
      }    else if (trainData$Name[i]=="Mr"){
      trainData$Age[i] = mister.age
      }    else if (trainData$Name[i]=="Mrs"){
      trainData$Age[i]= mrs.age
      } else if (trainData$Name[i] == "Dr"){
        trainData$Age[i]= dr.age
      }   else {
      print ("uncaught title")}
  }
}



# To create a variable to identify the passenger as a child.   Child is defined as less that age 12.
trainData$Child
for (i in 1:nrow(trainData)){
  if (trainData$Age[i] <= 12) {
    trainData$Child[i] = 1
    }   else {
    trainData$Child[i] = 2
    }
}


# To create variable for the family size.  FOr each passenger, add 
# the total siblings and parents on board plus the passenger.
trainData$Family= NA
for (i in 1:nrow(trainData)){
  trainData$Family[i]= as.numeric(trainData$SibSp[i] + trainData$Parch[i] + 1)
  trainData$Family<- as.numeric(trainData$Family)
}


# To create a variable to identify the passenger as a mother.  The assumption is that all passengers with the title "Mrs" and have a child value greater than 0.
trainData$Mother
for(i in 1:nrow(trainData)) {
  if(trainData$Name[i] == "Mrs" && trainData$Parch[i] > 0) {
    trainData$Mother[i] = 1
  } else {
    trainData$Mother[i] = 2
  }
} 


Mother_survival <- table(trainData$Survived, trainData$Mother)
barplot(Mother_survival, xlab = "Mother Status", ylab = "Number of People",
        main = "survived and deceased between mother and else")

		
		
Child_survival <- table(trainData$Survived, trainData$Child)
barplot(Mother_survival, xlab = "Child Status", ylab = "Number of People",
        main = "Survived and Deceased between Child and else")

write.csv(trainData, file="trainData formatted.csv", row.names=FALSE)


# Perform the same data cleaing on the test set
testData<- read.csv("titanic-test.csv", stringsAsFactors=FALSE)
PassengerId = testData[1]
testData = testData[-c(1, 8,10:11)]

fare.avg <-round(mean(testData$Fare[testData$Pclass=="3"],na.rm=TRUE,digit=2))

for(i in 1:nrow(testData)){
  if(is.na(testData[i,7])){
    if (testData$Pclass[i]=="3"){
       testData$Fare= fare.avg
    } else {
      print ("error")}
  }
}


testData$Sex = gsub("female", 1, testData$Sex)
testData$Sex = gsub("^male", 0, testData$Sex)

test_master_vector = grep("Master.",testData$Name)
test_miss_vector = grep("Miss.", testData$Name)
test_mrs_vector = grep("Mrs.", testData$Name)
test_mr_vector = grep("Mr.", testData$Name)
test_dr_vector = grep("Dr.", testData$Name)

for(i in test_master_vector) {
  testData[i, 2] = "Master"
}
for(i in test_miss_vector) {
  testData[i, 2] = "Miss"
}
for(i in test_mrs_vector) {
  testData[i, 2] = "Mrs"
}
for(i in test_mr_vector) {
  testData[i, 2] = "Mr"
}
for(i in test_dr_vector) {
  testData[i, 2] = "Dr"
}
pat<-"Rev|Master|Mrs|Mr|Dr|Miss"
society.vector<- grep(pat, testData$Name,invert=TRUE)
for(i in society.vector) {
  testData$Name[i] <- "Society"
}

test_master_age = round(mean(testData$Age[testData$Name == "Master"], na.rm = TRUE), digits = 2)
test_miss_age = round(mean(testData$Age[testData$Name == "Miss"], na.rm = TRUE), digits =2)
test_mrs_age = round(mean(testData$Age[testData$Name == "Mrs"], na.rm = TRUE), digits = 2)
test_mr_age = round(mean(testData$Age[testData$Name == "Mr"], na.rm = TRUE), digits = 2)
test_dr_age = round(mean(testData$Age[testData$Name == "Dr"], na.rm = TRUE), digits = 2)

for (i in 1:nrow(testData)) {
  if (is.na(testData[i,4])) {
    if (testData[i, 2] == "Master") {
      testData[i, 4] = test_master_age
    } else if (testData[i, 2] == "Miss") {
      testData[i, 4] = test_miss_age
    } else if (testData[i, 2] == "Mrs") {
      testData[i, 4] = test_mrs_age
    } else if (testData[i, 2] == "Mr") {
      testData[i, 4] = test_mr_age
    } else if (testData[i, 2] == "Dr") {
      testData[i, 4] = test_dr_age
    } else {
      print(paste("Uncaught title at: ", i, sep=""))
      print(paste("The title unrecognized was: ", testData[i,2], sep=""))
    }
  }
}

#We do a manual replacement here, because we weren't able to programmatically figure out the title.
#We figured out it was 89 because the above print statement should have warned us.
testData[89, 4] = test_miss_age

testData["Child"] = NA

for (i in 1:nrow(testData)) {
  if (testData[i, 4] <= 12) {
    testData[i, 8] = 1
  } else {
    testData[i, 8] = 1
  }
}

testData["Family"] = NA

for(i in 1:nrow(testData)) {
  testData[i, 9] = testData[i, 5] + testData[i, 6] + 1
}

testData["Mother"] = NA

for(i in 1:nrow(testData)) {
  if(testData[i, 2] == "Mrs" & testData[i, 6] > 0) {
    testData[i, 10] = 1
  } else {
    testData[i, 10] = 2
  }
}


# Build a logistic model
train.glm <- glm(Survived ~ Pclass + Sex + Age + Child + Sex*Pclass + Family + Mother, 
                 family = binomial, 
                 data = trainData)

				 
# Simplify the model
train.glm <- glm(Survived ~ Pclass + Sex, 
                 family = binomial,
                 data = trainData)

summary(train.glm)

# Predict
p.hats <- predict.glm(train.glm, newdata = testData, type = "response")

# Create a model based on the bernoulli distribution
trainData$Sex<-as.factor(trainData$Sex)
train.gbm<- gbm(Survived ~ Pclass + Sex + Age + Child + Sex*Pclass + Family + Mother,
                distribution="bernoulli",
                data=trainData,
                n.trees=50,
                interaction.dept=2,
                n.minobsinnode=10,
                cv.folds=5)
best.iter<-gbm.perf(train.gbm,method="cv")
predict.gbm<- predict(train.gbm,newdata=testData,best.iter)


# Convert the predictions to binomial
survival <- vector()
for(i in 1:length(p.hats)) {
  if(p.hats[i] > .5) {
    survival[i] <- 1
  } else {
    survival[i] <- 0
  }
}


# Prepare the submit file
kaggle.sub <- cbind(PassengerId,survival)
colnames(kaggle.sub) <- c("PassengerId", "Survived")
write.csv(kaggle.sub, file = "titanic-submit.csv", row.names = FALSE)

</pre>
