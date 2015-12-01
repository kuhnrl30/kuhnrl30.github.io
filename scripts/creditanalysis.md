---
layout: default
title: Credit Analysis R Code
Resume: passive
Projects: passive
blog: passive
moocs: passive
contact: passive
description: R Code Used for Credit Analysis Project
---

### Analysis of Credit Approval Data
<pre>
# Setup the environment
package.list<- c("knitr","ggplot2","dplyr","reshape2","ROCR","caTools","rpart", +
		"rpart.plot","arules","scales")
lapply(package.list, require, character.only = TRUE)
options(scipen=6, width=100)
setwd("C:/Users/Ryan/Google Drive/School/R-Audit Analytics II/Project")


# Download the data
myURL<- "http://archive.ics.uci.edu/ml/machine-learning-databases/credit-screening/crx.data"
if(!file.exists("Dataset.csv")){
	download.file(myURL,paste("C:/users/",
				  Sys.getenv("USERNAME"),
				  "/dropbox/RProjects/CreditAnalysis/data/Dataset.csv",
				  sep=""))
	}
rm(myURL)

	
# Load the data
Cols<- c(rep("character",2), "numeric",rep("character",4),"numeric",rep("character",2), + 
	"numeric",rep("character",3),"numeric","character")
Data<-read.csv("data/Dataset.csv",sep=",",colClasses=Cols)
rm(Cols)

# Give the columns fictitious names based on the data type.
names(Data)<-c("Male","Age","Debt","Married","BankCustomer","EducationLevel",+ 
	"Ethnicity", "YearsEmployed","PriorDefault","Employed","CreditScore", + 
	"DriversLicense","Citizen", "ZipCode","Income","Approved")

# View the structure of the data
str(Data)


# PRE PROCESS DATA ------


# Convert binary values to 1 or 0
Data$Male	<- ifelse(Data$Male=="a",1,0)
Data$Employed	<- ifelse(Data$Employed=="t",1,0)
Data$PriorDefault<-ifelse(Data$PriorDefault=="t",1,0)

# Convert credit granted to 1 or 0
Data$Approved	<-ifelse(Data$Approved=="+",1,0)
Data$Approved	<-factor(Data$Approved)

# Convert missing values to NA
Data[Data=="?"]	<-NA

Data$Age<-as.numeric(Data$Age)

# Seperate the numeric fields for seperate processing
Numeric	<- Data[,c(2:3,8,11,15)]
summary(Numeric)

# Pre-process age variable
Mean.Age<- mean(Numeric$Age,na.rm=T)
SD.Age	<-round(sd(Numeric$Age, na.rm=T),4)
SD.Age

# Use correlation to predict missing age values
round(cor(Numeric,use="complete.obs"),3)
AgeMdl<-lm(Age~YearsEmployed, data=Data,na.action=na.exclude)
AgeMdl$coefficients
Missing<-which(is.na(Data$Age))
Data$Age[Missing]<- predict(AgeMdl,newdata=Data[Missing,])

# Normalize the age variable
Data$AgeNorm<- (Data$Age-mean(Data$Age, na.rm=T))/SD.Age
rm(SD.Age, Mean.Age)

# View the distribution
par(mfrow=c(1,2), oma=c(0,0,1,0))
hist(Data$Age,main=NULL,xlab="Age",col="blue")
hist(Data$AgeNorm,main=NULL,xlab="AgeNorm",ylab=NULL,col="green")
title("Distribution of Values Before and After Normalization",outer=T)

# Create a boxplot
ggplot(Data) + 
  aes(Approved,AgeNorm) + 
  geom_boxplot(outlier.colour="red") +
  theme_bw() +
  coord_flip() +
  labs(title="Distribution of AgeNorm by Credit Approval Status")

 
# Normalize the variables
Temp<- data.frame(scale(Data[,c(3,8,11,15)],center=T,scale=T))
colnames(Temp)<-c("DebtNorm","YearsEmployedNorm","CreditScoreNorm","IncomeNorm")
Data<-cbind(Data,Temp)
rm(Temp)

# Re-plot the normalized values
par(mfrow=c(4,2),mar=c(4,4,2,2))
hist(Data$DebtNorm,main=NULL,xlab="DebtNorm",col="red",ylab="Frequency")
boxplot(DebtNorm~Approved,data=Data,horizontal=T,ylim=c(-1.5,5),xlab="DebtNorm")

hist(Data$YearsEmployedNorm,main=NULL,xlab="YearsEmployedNorm",col="green")
boxplot(YearsEmployedNorm~Approved,data=Data,horizontal=T,ylim=c(-1.5,5),xlab="YearsEmployedNorm")

hist(Data$CreditScoreNorm,main=NULL,xlab="CreditScoreNorm",col="blue")
boxplot(CreditScoreNorm~Approved,data=Data,horizontal=T,ylim=c(-1.5,5),xlab="CreditScoreNorm")

hist(Data$IncomeNorm,main=NULL,xlab="IncomeNorm",col="orange")
boxplot(IncomeNorm~Approved,data=Data,horizontal=T,ylim=c(-1.5,5),xlab="IncomeNorm")
dev.off()


# Center the log transformed data
Temp<- data.frame(scale(log(Data[,c(3,8,11,15)]+1),center=T))
names(Temp)<-c("DebtLog","YearsEmployedLog","CreditScoreLog","IncomeLog")
Data<-cbind(Data,Temp)
rm(Temp)


# Plot the log transformed data
par(mfrow=c(4,2),mar=c(4,4,2,2))
hist(Data$DebtLog,main=NULL,xlab="DebtLog",col="red",ylab="Frequency")
boxplot(DebtLog~Approved,data=Data,horizontal=T,ylim=c(-1.5,5),xlab="DebtLog")

hist(Data$YearsEmployedLog,main=NULL,xlab="YearsEmployedLog",col="green")
boxplot(YearsEmployedLog~Approved,data=Data,horizontal=T,ylim=c(-1.5,5),xlab="YearsEmployedLog")

hist(Data$CreditScoreLog,main=NULL,xlab="CreditScoreLog",col="blue")
boxplot(CreditScoreLog~Approved,data=Data,horizontal=T,ylim=c(-1.5,5),xlab="CreditScoreLog")

hist(Data$IncomeLog,main=NULL,xlab="IncomeLog",col="orange")
boxplot(IncomeLog~Approved,data=Data,horizontal=T,ylim=c(-1.5,5),xlab="IncomeLog")
dev.off()


# Simplify dataset to remove transformed points
Data<- Data[,-c(2,3,8,11,15,18:21)]


# How many male vs female applicants
table(Data$Male,useNA="ifany")


# ID the incomplete observations 
incomplete<-!complete.cases(Data)
ToImpute<-Data[incomplete,]


# Fill the incomplete observations with the variable mode
Data$Married		<-ifelse(is.na(Data$Married),"u",Data$Married)
Data$BankCustomer	<-ifelse(is.na(Data$BankCustomer),"g",Data$BankCustomer)
Data$Ethnicity		<-ifelse(is.na(Data$Ethnicity),"v",Data$Ethnicity)
Data$EducationLevel	<-ifelse(is.na(Data$EducationLevel),"c",Data$EducationLevel)
Data$ZipCode		<-ifelse(is.na(Data$ZipCode),"00000",Data$ZipCode)
Data$Male		<-ifelse(is.na(Data$Male),"b",Data$Male)


# Convert categorical variables to factors
Data[,1:10]<- lapply(Data[1:10],function(x) factor(x))
Data$Ethnicity<-relevel(Data$Ethnicity,"v")


# Generate association rules
Rules<- apriori(Data[!incomplete,1:10], 
		parameter=list(supp=0.1,
		conf=0.75,
		target='rules'))


# Visualize rules 
subRules<-head(sort(Rules, by="lift"),15)
plot(subRules,method="graph", control=list(type="items", alpha=0.8))


# ASSOCIATION RULES- USE THIS FOR AN EXAMPLE
# First, convert row to transaction set
basket<-as(Data[248,1:10],"transactions")

# Find rules wher the right hand example (rhs) equals A.  These rules imply the value in 
# column A.
Match.RHS<- subset(Rules, subset= rhs %pin% "Male")

# Of subset of rules, find those where the left hand side (lhs) is a subset of the items 
# in the target row
Match.LHS<-is.subset(Match.RHS@lhs, basket)

# View the rules
inspect(Match.RHS[Match.LHS])


# Split the data into training and test sets
set.seed(1234)
split<- sample.split(Data$Approved, SplitRatio=0.75)
Train<- subset(Data,split==TRUE)
Test <- subset(Data, split==FALSE)


# Get success rates in training set
table(Train$Approved)
rm(split)


# Create logrithmic regresion model
LogFit<- glm(Approved~AgeNorm+DebtLog+YearsEmployedLog+CreditScoreLog+IncomeLog, 
		data=Train,family=binomial)
summary(LogFit)


# Predict based on the model
LogPred<- predict(LogFit,newdata=Train, type="response")
table(Train$Approved, LogPred>0.5)


# Simplify the model
LogFit2<- glm(Approved~YearsEmployedLog+CreditScoreLog+IncomeLog, 
		data=Train,family=binomial)
summary(LogFit2)

# Rerun the prediction with the simplified model
LogPred2<- predict(LogFit2,newdata=Train, type="response")
table(Train$Approved, LogPred2>0.5)


# Use the step function to simplify the model with a function
LogFit3<- step(LogFit, trace=0)
unclass(LogFit3)$formula


# Apply the model to the test set
LogPred3<-predict(LogFit2, newdata=Test,type="response")


# Create a confusion Matrix
table(Test$Approved,LogPred3>0.5)


# Create CART model
set.seed(1234)
TreeFit<-rpart(Approved~Male+Married+BankCustomer+EducationLevel+Ethnicity+PriorDefault+Employed+DriversLicense+Citizen+AgeNorm+DebtLog+YearsEmployedLog+CreditScoreLog+IncomeLog, 
               data=Train, 
               method="class",
               control=rpart.control(xval=10,cp=0.025))
TreeFit


# Prune the tree
prp(TreeFit,main="CART model", digits=6, 
    extra=1,
    branch.col="blue",
    type=4,
    leaf.round=2,
    box.col=c("pink","palegreen")[TreeFit$frame$yval],
    ycompact=T)

# Predict the tree model on the training set
TreePred<-predict(TreeFit,newdata=Train,type="prob")
table(Train$Approved,TreePred[,2]>0.5)

# Predict on the tes set
TreePred2<-predict(TreeFit,newdata=Test,type=c("prob"))
table(Test$Approved,TreePred2[,2]>0.5)


# Combine the predictions into a single dataset, then take the average of the predictions
Combined<-cbind(TreePred2[,2],LogPred3)
FinalPred<-rowMeans(Combined)
table(Test$Approved,FinalPred>0.5)


# Chi squared test for independence in ethnicity value
tbl<-Data %>%
group_by(Ethnicity) %>%
summarise(Freq=n(),
Approved=sum(Approved==1))
tbl
chisq.test(tbl[2:3])

</pre>