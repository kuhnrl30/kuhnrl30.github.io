---
layout: script
title: Africa Soil Property R Code
Resume: passive
Projects: passive
blog: passive
moocs: passive
contact: passive
description: R Code Used for the Africa Soil Property Competition
---

## Africa Soil Property Prediction  

#### Summary Plots 

<pre>
Train.raw<- read.csv("c:/users/ryan/dropbox/RProjects/africa soil/data/training.csv")

Train.CO2<-Train.raw[,2656:2670]
Train.raw<- Train.raw[,-c(2656:2670)] ##Remove CO2 bands

Wavelengths<-substr(names(Train.raw[,2:3564]),2,8)

##Find rows with max and min Calcium values to comare plot lines
which.min(Train.raw$Ca) #990
which.max(Train.raw$Ca) #585

##Plot the spectometer data for the rows with max and min Calcium values
plot(Wavelengths,Train.raw[585,2:3564],pch=20,col="red",lwd=.1,
     ylim=c(0,2.25))
par(new=TRUE)
plot(Wavelengths,Train.raw[990,2:3564],pch=20,col="blue",lwd=.1,ylim=c(0,2.25))

##Calculate the correlations with the  Calcium values.  Determine the variable
##with the largest correlation value. The result matches the spike in plots in
##the 2500 range.
Correlations<-cor(Train.raw$Ca,Train.raw[2:3564])
which.max(Correlations)  #2586
names(Train.raw[2586]) #m2514.75
plot(Ca~m2514.75,data=Train.raw,pch=20)
abline(lm(Train.raw$Ca~Train.raw$m2514.75))
</pre>

#### General Additive Model
<pre>
require(mgcv)

Train.raw<- read.csv("c:/users/ryan/dropbox/RProjects/africa soil/data/training.csv",stringsAsFactors=F)
Test.raw<- read.csv("c:/users/ryan/dropbox/RProjects/africa soil/data/test.csv",stringsAsFactors=F)

Train.Spec         <- Train.raw[,c(2:2655,2671:3579)]
Train.CO2          <- Train.raw[,c(2656:2670)]
Train.Other        <- Train.raw[,3580:3600]
Train.Properties   <- Train.raw[,3596:3600]
PIDN               <- Train.raw[,1]
soil_properties <- c("Ca", "P", "pH", "SOC", "Sand")


Test.Spec         <- Test.raw[,c(1:2655,2671:3579)]
Test.Co2          <- Test.raw[,2656:2670]
Test.Other        <- Test.raw[,3580:3595]
Test.PIDN         <- Test.raw[,1]

##########
#Scores 0.9106 in eval below
train.gam.pH  <- gam(pH~  s(EVI) +s(LSTD)+s(TMAP),data=Train.Other)
train.gam.SOC <- gam(pH~  s(TMAP)+s(ELEV),data=Train.Other)
train.gam.Sand<- gam(Sand~s(TMAP)+s(BSAN),data=Train.Other)
train.gam.P   <- gam(P~   s(TMAP)+s(BSAN),data=Train.Other)
train.gam.Ca  <- gam(Ca~  s(TMAP)+s(BSAN),data=Train.Other)


summary(train.gam.pH)
summary(train.gam.SOC)
summary(train.gam.Sand)
summary(train.gam.P)
summary(train.gam.Ca)

##########
##EVALUATION
Avg.Score<-data.frame()  
for (i in 1:500){
    Eval.index<-sample(1:1157,115)
    
    Eval.P   <-predict.gam(train.gam.P,   newdata=Train.Other[Eval.index,],type="response")
    Eval.Ca  <-predict.gam(train.gam.Ca,  newdata=Train.Other[Eval.index,],type="response")
    Eval.pH  <-predict.gam(train.gam.pH,  newdata=Train.Other[Eval.index,],type="response")
    Eval.SOC <-predict.gam(train.gam.SOC, newdata=Train.Other[Eval.index,],type="response")
    Eval.Sand<-predict.gam(train.gam.Sand,newdata=Train.Other[Eval.index,],type="response")

    Train.Pred<- data.frame(Ca=Eval.Ca,
                            P=Eval.P,
                            pH=Eval.pH,
                            SOC=Eval.SOC,
                            Sand=Eval.Sand)
    Train.Eval<- Train.Properties[Eval.index,]

    Scores<-sqrt(colMeans((Train.Eval-Train.Pred)^2))
    Summary.Scores<- c(Scores,mean(Scores))
    Avg.Score<-rbind(Avg.Score,Summary.Scores)
}
names(Avg.Score)<-c("Ca","P","pH","SOC","Sand","MCRMSE")
Eval.GAM<-round(colMeans(Avg.Score),4)
Eval.GAM
write.csv(Eval.GAM,"analytics/kaggle_challenges/africa_soil/eval-gam.csv",row.names=F)


##########
# Create Submission Set

predict.Ca  <- predict.gam(train.gam.Ca,  newdata=Test.Other,type="response")
predict.P   <- predict.gam(train.gam.P,   newdata=Test.Other,type="response")
predict.SOC <- predict.gam(train.gam.SOC, newdata=Test.Other,type="response")
predict.pH  <- predict.gam(train.gam.pH,  newdata=Test.Other,type="response")
predict.Sand<- predict.gam(train.gam.Sand,newdata=Test.Other,type="response")

submit<- data.frame(PIDN=Test.PIDN,
                    Ca=predict.Ca,
                    P=predict.P,
                    pH=predict.pH,
                    SOC=predict.SOC,
                    Sand=predict.Sand)
names(submit)<-c("PIDN","Ca","P","pH","SOC","Sand")

write.csv(submit,"analytics/kaggle_challenges/africa_soil/submit-gam.csv",row.names=F)
</pre>

#### Generalized Linear Model 
<pre>
Train.raw<- read.csv("c:/users/ryan/dropbox/RProjects/africa soil/data/training.csv")
Test.raw<- read.csv("c:/users/ryan/dropbox/RProjects/africa soil/data/test.csv",stringsAsFactors=F)
Train.raw$Depth <-  with ( Train.raw, ifelse ( ( Depth == 'Subsoil' ), 0 , 1 ) )
Test.raw$Depth <-  with ( Test.raw, ifelse ( ( Depth == 'Subsoil' ), 0 , 1 ) )

Train.Spec         <- Train.raw[,c(1:2655,2671:3579)]
Train.CO2          <- Train.raw[,c(1,2656:2670)]
Train.Other        <- Train.raw[c(1,3580:3599)]
Train.Properties   <- Train.raw[,c(1,3596:3600)]
PIDN               <- Train.raw[,1]
soil_properties <- c("Ca", "P", "pH", "SOC", "Sand")

Test.Spec         <- Test.raw[,c(1:2655,2671:3579)]
Test.Co2          <- Test.raw[,c(1,2656:2670)]
Test.Other        <- Test.raw[c(1,3580:3595)]
Test.PIDN         <- Test.raw[,1]


cor(Train.Properties[,2:5],Train.Other[sapply(Train.Other,is.numeric)])

##########
## Scores 0.936 in evaluation below
train.glm.P   <- glm(P   ~BSAV+TMAP+TMFI+LSTD,data=Train.Other)
train.glm.Ca  <- glm(Ca  ~BSAN+BSAS+BSAV+ELEV+REF7,data=Train.Other)
train.glm.pH  <- glm(pH  ~EVI+LSTD+TMAP,data=Train.Other)
train.glm.SOC <- glm(pH  ~TMAP+ELEV,data=Train.Other)
train.glm.Sand<- glm(Sand~ELEV+LSTN+REF7+TMAP,data=Train.Other)

summary(train.glm.pH)
summary(train.glm.SOC)
summary(train.glm.P)
summary(train.glm.Ca)
summary(train.glm.Sand)

##########
## Evaluation
Avg.Score<-data.frame()  
for (i in 1:500){
  Eval.index<-sample(1:1157,115)
  
  Eval.P   <-predict(train.glm.P,   newdata=Train.Other[Eval.index,],type="response")
  Eval.Ca  <-predict(train.glm.Ca,  newdata=Train.Other[Eval.index,],type="response")
  Eval.pH  <-predict(train.glm.pH,  newdata=Train.Other[Eval.index,],type="response")
  Eval.SOC <-predict(train.glm.SOC, newdata=Train.Other[Eval.index,],type="response")
  Eval.Sand<-predict(train.glm.Sand,newdata=Train.Other[Eval.index,],type="response")
  
  Train.Pred<- data.frame(Ca  =Eval.Ca,
                          P   =Eval.P,
                          pH  =Eval.pH,
                          SOC =Eval.SOC,
                          Sand=Eval.Sand)
  Train.Eval<- Train.Properties[Eval.index,]
  
  Scores<-sqrt(colMeans((Train.Eval-Train.Pred)^2))
  Summary.Scores<- c(Scores,mean(Scores))
  Avg.Score<-rbind(Avg.Score,Summary.Scores)
}
names(Avg.Score)<-c("Ca","P","pH","SOC","Sand","MCRMSE")
Eval.GLM<-round(colMeans(Avg.Score),4)
Eval.GLM
write.csv(Eval.GAM,"analytics/kaggle_challenges/africa_soil/eval-glm.csv",row.names=F)

##########
## Create Submission set

predict.P   <- predict.glm(train.glm.P,   newdata=Test.Other,type="response")
predict.Ca  <- predict.glm(train.glm.Ca,  newdata=Test.Other,type="response")
predict.pH  <- predict.glm(train.glm.pH,  newdata=Test.Other,type="response")
predict.SOC <- predict.glm(train.glm.SOC, newdata=Test.Other,type="response")
predict.Sand<- predict.glm(train.glm.Sand,newdata=Test.Other,type="response")

submit<- as.data.frame(cbind(Test.PIDN,
                             Ca=predict.Ca,
                             P=predict.P,
                             pH=predict.pH,
                             SOC=predict.SOC,
                             Sand=predict.Sand))
names(submit)<-c("PIDN","Ca","P","pH","SOC","Sand")

write.csv(submit,"analytics/kaggle_challenges/africa_soil/submit-glm.csv",row.names=F)
</pre>

#### Principal Component Analysis  

<pre>
library(caret)
library(stats)

Train.raw <- read.csv('analytics/RProjects/africa_soil/training.csv', header = TRUE)
Test.raw <- read.csv('analytics/RProjects/africa_soil/sorted_test.csv',header = TRUE)
Train.raw$Depth <-  with ( Train.raw, ifelse ( ( Depth == 'Subsoil' ), 0 , 1 ) )
Test.raw$Depth <-  with ( Test.raw, ifelse ( ( Depth == 'Subsoil' ), 0 , 1 ) )

Train.Spec         <- Train.raw[,c(2:2655,2671:3579)]
Train.CO2          <- Train.raw[,c(2656:2670)]
Train.Other        <- Train.raw[,3580:3595]
Train.Properties   <- Train.raw[,3596:3600]

Test.Spec          <- Test.raw[,c(2:2655,2671:3579)]
Test.CO2           <- Test.raw[,c(2656:2670)]
Test.Other         <- Test.raw[,3580:3595]

PCA<- prcomp(Train.Spec,scale=T)
plot(PCA$x,type="p")
screeplot(PCA,type="lines",col=3)

myData<- data.frame(Ca=Train.Properties[,"Ca"],
                      P=Train.Properties[,"P"],
                      pH=Train.Properties[,"pH"],
                      SOC=Train.Properties[,"SOC"],
                      Sand=Train.Properties[,"Sand"],
                      PCA$x[,1:2])

PrinComp<-PCA$x[,1]

indx <- createFolds(Train.Properties[,1], returnTrain = TRUE)
ctrl <- trainControl(method = "cv", index = indx)


######
##Scores 1.029 in Evaluation below 
glmTuneCa  <-train(Ca~PC1+PC2, data=myData, method="glm", trControl=ctrl)
glmTuneP   <-train(P~PC1+PC2,  data=myData, method="glm", trControl=ctrl)
glmTunepH  <-train(Ca~PC1+PC2, data=myData, method="glm", trControl=ctrl)
glmTuneSOC <-train(SOC~PC1+PC2,data=myData, method="glm", trControl=ctrl)
glmTuneSand<-train(Ca~PC1+PC2, data=myData, method="glm", trControl=ctrl)



##########
##Evaluation
Avg.Score<-data.frame()  
for (i in 1:500){
  Eval.index<-sample(1:1157,115)

  Eval.PCA <-predict(PCA,newdata=Train.Spec[Eval.index,])
  Eval.P   <-predict(glmTuneP,   newdata=data.frame(Eval.PCA),type="raw")
  Eval.Ca  <-predict(glmTuneCa,  newdata=data.frame(Eval.PCA),type="raw")
  Eval.pH  <-predict(glmTunepH,  newdata=data.frame(Eval.PCA),type="raw")
  Eval.SOC <-predict(glmTuneSOC, newdata=data.frame(Eval.PCA),type="raw")
  Eval.Sand<-predict(glmTuneSand,newdata=data.frame(Eval.PCA),type="raw")
  Train.Pred<- data.frame(Ca=Eval.Ca,
                          P=Eval.P,
                          pH=Eval.pH,
                          SOC=Eval.SOC,
                          Sand=Eval.Sand)
  Train.Eval<- Train.Properties[Eval.index,]
  
  Scores<-sqrt(colMeans((Train.Eval-Train.Pred)^2))
  Summary.Scores<- c(Scores,mean(Scores))
  Avg.Score<-rbind(Avg.Score,Summary.Scores)
}
names(Avg.Score)<-c("Ca","P","pH","SOC","Sand","MCRMSE")
Eval.PCA2<-round(colMeans(Avg.Score),4)
Eval.PCA2
write.csv(Eval.PCA2,"analytics/kaggle_challenges/africa_soil/eval-pca2.csv",row.names=F)


##########
##Create submission set
Predict.PCA<-predict(PCA,newdata=Test.Spec)
Predict.Ca<-predict(glmTuneCa,newdata=data.frame(Predict.PCA),type="raw")
Predict.P<-predict(glmTuneP,newdata=data.frame(Predict.PCA),type="raw")
Predict.pH<-predict(glmTunepH,newdata=data.frame(Predict.PCA),type="raw")
Predict.SOC<-predict(glmTuneSOC,newdata=data.frame(Predict.PCA),type="raw")
Predict.Sand<-predict(glmTuneSand,newdata=data.frame(Predict.PCA),type="raw")

testResults <- data.frame(PIDN = Test.raw[,1],
                          Ca=Predict.Ca,
                          P=Predict.P,
                          pH=Predict.pH,
                          SOC=Predict.SOC,
                          Sand=Predict.Sand)

write.csv(testResults,file = "analytics/kaggle_challenges/africa_soil/PCA2.csv",row.names = FALSE)
</pre>

#### Simple Linear Regression  
<pre>
rm(list=ls())
library(caret)

Train.raw <- read.csv('analytics/RProjects/africa_soil/training.csv', header = TRUE)
Test.raw <- read.csv('analytics/RProjects/africa_soil/sorted_test.csv',header = TRUE)
Train.raw$Depth <-  with ( Train.raw, ifelse ( ( Depth == 'Subsoil' ), 0 , 1 ) )
Test.raw$Depth <-  with ( Test.raw, ifelse ( ( Depth == 'Subsoil' ), 0 , 1 ) ) 

Xtrain <- Train.raw[,2:3595]
Ytrain <- Train.raw[,3596:3600]
Xtest <- Test.raw[,2:3595]
IDtest <- Test.raw[,1]


#delete highly correlated (>0.95) features.
tooHigh <- findCorrelation(cor(rbind(Xtrain,Xtest)), .95)

Xtrainfiltered <- Xtrain[, -tooHigh]
Xtestfiltered  <-  Xtest[, -tooHigh]

# 10 fold cv
indx <- createFolds(Ytrain[,1], returnTrain = TRUE)
ctrl <- trainControl(method = "cv", index = indx)

## Scores 0.555 in eval below
lmTuneCa   <- train(x = Xtrainfiltered, y = Ytrain$Ca,  method = "lm", trControl = ctrl)
lmTuneP    <- train(x = Xtrainfiltered, y = Ytrain$P,   method = "lm", trControl = ctrl)
lmTunepH   <- train(x = Xtrainfiltered, y = Ytrain$pH,  method = "lm", trControl = ctrl)
lmTuneSOC  <- train(x = Xtrainfiltered, y = Ytrain$SOC, method = "lm", trControl = ctrl)
lmTuneSand <- train(x = Xtrainfiltered, y = Ytrain$Sand,method = "lm", trControl = ctrl)


##########
## Evaluation
Avg.Score<-data.frame()  
for (i in 1:500){
  Eval.index<-sample(1:1157,115)
  
  Eval.P   <-predict(lmTuneP,   Xtrainfiltered[Eval.index,])
  Eval.Ca  <-predict(lmTuneCa,  Xtrainfiltered[Eval.index,])
  Eval.pH  <-predict(lmTunepH,  Xtrainfiltered[Eval.index,])
  Eval.SOC <-predict(lmTuneSOC, Xtrainfiltered[Eval.index,]) 
  Eval.Sand<-predict(lmTuneSand,Xtrainfiltered[Eval.index,])
  
  Train.Pred<- data.frame(Ca=Eval.Ca,
                          P=Eval.P,
                          pH=Eval.pH,
                          SOC=Eval.SOC,
                          Sand=Eval.Sand)
  Train.Eval<- Train.raw[Eval.index,3596:3600]
  
  Scores<-sqrt(colMeans((Train.Eval-Train.Pred)^2))
  Summary.Scores<- c(Scores,mean(Scores))
  Avg.Score<-rbind(Avg.Score,Summary.Scores)
}
names(Avg.Score)<-c("Ca","P","pH","SOC","Sand","MCRMSE")
Eval.SLR<-round(colMeans(Avg.Score),4)
Eval.SLR
write.csv(Eval.SLR,"analytics/kaggle_challenges/africa_soil/eval-slr.csv",row.names=F)


##########
## Create Submission set
predict.Ca   <- predict(lmTuneCa, Xtestfiltered)
predict.p    <- predict(lmTuneP,Xtestfiltered)
predict.pH   <- predict(lmTunepH,Xtestfiltered)
predict.SOC  <- predict(lmTuneSOC,Xtestfiltered)
predict.Sand <- predict(lmTuneSand,Xtestfiltered)

testResults<- data.frame(PIDN =IDtest,
                         Ca   =predict.Ca,
                         P    =predict.p,
                         pH   =predict.pH,
                         SOC  =predict.SOC,
                         Sand =predict.Sand)
                         
  
write.csv(testResults,file = "analytics/kaggle_challenges/africa_soil/slr.csv",row.names = FALSE)
</pre>

#### Support Vector Machines  
<pre>

rm(list=ls())
library(e1071)

Train.raw <- read.csv('analytics/RProjects/africa_soil/training.csv', header = TRUE)
Test.raw <- read.csv('analytics/RProjects/africa_soil/sorted_test.csv',header = TRUE)
Train.raw$Depth <-  with ( Train.raw, ifelse ( ( Depth == 'Subsoil' ), 0 , 1 ) )
Test.raw$Depth <-  with ( Test.raw, ifelse ( ( Depth == 'Subsoil' ), 0 , 1 ) )

Train.Spec         <- Train.raw[,c(2:2655,2671:3579)]
Train.CO2          <- Train.raw[,c(2656:2670)]
Train.Other        <- Train.raw[,3580:3595]
Train.Properties   <- Train.raw[,3596:3600]

Test.Spec          <- Test.raw[,c(2:2655,2671:3579)]
Test.CO2           <- Test.raw[,c(2656:2670)]
Test.Other         <- Test.raw[,3580:3595]

#scores.= 0.677 in eval below
SVM.P   <-svm(y=Train.Properties$P,   x=Train.raw[,2:3595],cross=12,type="eps-regression",scale=FALSE)
SVM.Ca  <-svm(y=Train.Properties$Ca,  x=Train.raw[,2:3595],cross=12,type="eps-regression",scale=FALSE)
SVM.pH  <-svm(y=Train.Properties$pH,  x=Train.raw[,2:3595],cross=12,type="eps-regression",scale=FALSE)
SVM.SOC <-svm(y=Train.Properties$SOC, x=Train.raw[,2:3595],cross=12,type="eps-regression",scale=FALSE)
SVM.Sand<-svm(y=Train.Properties$Sand,x=Train.raw[,2:3595],cross=12,type="eps-regression",scale=FALSE)

###########
#Evaluation
Avg.Score<-data.frame()  
for (i in 1:500){
  Eval.index<-sample(1:1157,115)

  Eval.P   <-predict(SVM.P,   newdata=Train.raw[Eval.index,2:3595])
  Eval.Ca  <-predict(SVM.Ca,  newdata=Train.raw[Eval.index,2:3595])
  Eval.pH  <-predict(SVM.pH,  newdata=Train.raw[Eval.index,2:3595])
  Eval.SOC <-predict(SVM.SOC, newdata=Train.raw[Eval.index,2:3595]) 
  Eval.Sand<-predict(SVM.Sand,newdata=Train.raw[Eval.index,2:3595])
  Train.Pred<- data.frame(Ca=Eval.Ca,
                          P=Eval.P,
                          pH=Eval.pH,
                          SOC=Eval.SOC,
                          Sand=Eval.Sand)
  Train.Eval<- Train.Properties[Eval.index,]

  Scores<-sqrt(colMeans((Train.Eval-Train.Pred)^2))
  Summary.Scores<- c(Scores,mean(Scores))
  Avg.Score<-rbind(Avg.Score,Summary.Scores)
}
names(Avg.Score)<-c("Ca","P","pH","SOC","Sand","MCRMSE")
Eval.SVM<-round(colMeans(Avg.Score),4)
Eval.SVM
write.csv(Eval.SVM,"analytics/kaggle_challenges/africa_soil/eval-svm.csv",row.names=F)

#########
##Make predictions
SVM.Out.P    <- predict(SVM.P,   newdata=Test.raw[,2:3595])
SVM.Out.Ca   <- predict(SVM.Ca,  newdata=Test.raw[,2:3595])
SVM.Out.pH   <- predict(SVM.pH,  newdata=Test.raw[,2:3595])
SVM.Out.SOC  <- predict(SVM.SOC, newdata=Test.raw[,2:3595])
SVM.Out.Sand <- predict(SVM.Sand,newdata=Test.raw[,2:3595])

#########
##Create submission set

Submit<-data.frame(PIDN=Test.raw[,1],
                   Ca=SVM.Out.Ca,
                   P=SVM.Out.P,
                   pH=SVM.Out.pH,
                   SOC=SVM.Out.SOC,
                   Sand=SVM.Out.Sand)

write.csv(Submit,"analytics/kaggle_challenges/Africa_Soil/SVM.csv",row.names=F)
</pre>

#### Put it all together
<pre>
#Summarize Evals
Eval.Table<-data.frame()
GAM.Eval <-read.csv("analytics/RProjects/africa_soil/eval-gam.csv")
GLM.Eval <-read.csv("analytics/RProjects/africa_soil/eval-glm.csv")
PCA2.Eval<-read.csv("analytics/RProjects/africa_soil/eval-pca2.csv")
SLR.Eval <-read.csv("analytics/RProjects/africa_soil/eval-slr.csv") 
SVM.Eval <-read.csv("analytics/RProjects/africa_soil/eval-svm.csv")

Eval.Table<-matrix(,nrow=5,ncol=5)


Eval.Table<-cbind(GAM.Eval,GLM.Eval,PCA2.Eval,SLR.Eval,SVM.Eval)
names(Eval.Table)<-c("GAM","GLM","PCA2","SLR","SVM")
row.names(Eval.Table)<- c("Ca","P","pH","SOC","Sand","mean")
write.csv(Eval.Table,"analytics/kaggle_challenges/africa_soil/eval-table.csv",row.names=T)

##########
## Create Submission Set
GAM <-read.csv("analytics/kaggle_challenges/Africa_Soil/submit-gam.csv",header=T)
GLM <-read.csv("analytics/kaggle_challenges/Africa_Soil/submit-glm.csv",header=T)
PCA2<-read.csv("analytics/kaggle_challenges/Africa_Soil/PCA2.csv",header=T)
SLR <-read.csv("analytics/kaggle_challenges/Africa_Soil/slr.csv",header=T)
SVM <-read.csv("analytics/kaggle_challenges/Africa_Soil/SVM.csv",header=T)

names(GAM)
names(GLM)
names(PCA2)
names(SLR)
names(SVM)

Fin.Sub.P<- rowMeans(cbind(GAM[,"P"],GLM[,"P"],PCA2[,"P"],SLR[,"P"],SVM[,"P"]))
Fin.Sub.pH<- rowMeans(cbind(SLR[,"P"],SVM[,"P"]))
Fin.Sub.Sand<- rowMeans(cbind(SLR[,"Sand"],SVM[,"Sand"]))
Final.Submit<-data.frame(PIDN=Test.raw[,1],
                         Ca=SLR[,"Ca"],
                         P=Fin.Sub.P,
                         pH=Fin.Sub.pH,
                         SOC=SLR[,"SOC"],
                         Sand=Fin.Sub.Sand)

write.csv(Final.Submit,"analytics/kaggle_challenges/Africa_Soil/Final-Submit.csv",row.names=F)
</pre>