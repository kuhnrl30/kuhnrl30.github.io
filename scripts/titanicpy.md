---
layout: script
title: Titanic Python Code
Resume: passive
Projects: passive
blog: passive
moocs: passive
contact: passive
description: Python Code Used for Titanic- Learning from Disaster Competition
---

### Titanic- Machine Learning from Disaster (Python Code)

<pre>
import pandas as pd
import re
import numpy as np


# Prepare Training Data -------------------------
path = "c:/users/ryan/dropbox/pythonprojects/titanic/data/titanic-train.csv"
Train = pd.read_csv(path,delimiter=",")

# Convert Sex to a binary value
Train["Sex"] = Train["Sex"].apply(lambda x: 1 if x=="female" else 0)

# Reduce the name value to the titles
Train["Name"] = Train["Name"].apply(lambda x: "Master" if re.search("Master",x) else x)
Train["Name"] = Train["Name"].apply(lambda x: "Miss" if re.search("Miss",x) else x)
Train["Name"] = Train["Name"].apply(lambda x: "Mrs" if re.search("Mrs",x) else x)
Train["Name"] = Train["Name"].apply(lambda x: "Rev" if re.search("Rev",x) else x)
Train["Name"] = Train["Name"].apply(lambda x: "Dr" if re.search("Dr",x) else x)
Train["Name"] = Train["Name"].apply(lambda x: "Mr" if re.search("Mr",x) else x)
Train["Name"] = Train["Name"].apply(lambda x: "Society" if not re.search("Dr|Mr|Master|Miss|Mrs|Rev",x) else x)

#Create new variable to designate a child
Train["Child"] = Train["Age"].apply(lambda x: 2 if x < 12 else 1)

# Create new variable 'Mother' if passenger has children
Train["Family"] = Train["SibSp"] + Train["Parch"] + 1 
Train["Mother"] = Train["Family"].apply(lambda x: 0 if x<2 else 1)

# Fill missing age values -----------------
MasterSub = Train[Train["Name"]=="Master"]
MasterMean = np.mean(MasterSub["Age"])

MrSub = Train[Train["Name"]=="Mr"]
MrMean = np.mean(MrSub["Age"])

MissSub = Train[Train["Name"]=="Miss"]
MissMean = np.mean(MissSub["Age"])

MrsSub = Train[Train["Name"]=="Mrs"]
MrsMean = np.mean(MrsSub["Age"])

RevSub = Train[Train["Name"]=="Rev"] 
RevMean = np.mean(RevSub["Age"])

SocSub = Train[Train["Name"]=="Society"]
SocMean = np.mean(SocSub["Age"])

DrSub = Train[Train["Name"]=="Dr"]
DrMean = np.mean(DrSub["Age"])

Train.loc[(Train["Name"] == "Mr") & pd.isnull(Train["Age"]) ,"Age"] = MrMean
Train.loc[(Train["Name"] == "Mrs") & pd.isnull(Train["Age"]) ,"Age"] = MrsMean
Train.loc[(Train["Name"] == "Miss") & pd.isnull(Train["Age"]) ,"Age"] = MissMean
Train.loc[(Train["Name"] == "Dr") & pd.isnull(Train["Age"]) ,"Age"] = DrMean
Train.loc[(Train["Name"] == "Rev") & pd.isnull(Train["Age"]) ,"Age"] = RevMean
Train.loc[(Train["Name"] == "Master") & pd.isnull(Train["Age"]) ,"Age"] = MasterMean
Train.loc[(Train["Name"] == "Society") & pd.isnull(Train["Age"]) ,"Age"] = SocMean

 

# Prepare Test Data ----------------------------------------
path = "c:/users/ryan/dropbox/pythonprojects/titanic/data/titanic-test.csv"
Test = pd.read_csv(path,delimiter=",")

Test["Sex"] = Test["Sex"].apply(lambda x: 1 if x=="female" else 0)

Test["Name"] = Test["Name"].apply(lambda x: "Master" if re.search("Master",x) else x)
Test["Name"] = Test["Name"].apply(lambda x: "Miss" if re.search("Miss",x) else x)
Test["Name"] = Test["Name"].apply(lambda x: "Mrs" if re.search("Mrs",x) else x)
Test["Name"] = Test["Name"].apply(lambda x: "Rev" if re.search("Rev",x) else x)
Test["Name"] = Test["Name"].apply(lambda x: "Dr" if re.search("Dr",x) else x)
Test["Name"] = Test["Name"].apply(lambda x: "Mr" if re.search("Mr",x) else x)
Test["Name"] = Test["Name"].apply(lambda x: "Society" if not re.search("Dr|Mr|Master|Miss|Mrs|Rev",x) else x)

Test["Child"] = Test["Age"].apply(lambda x: 2 if x < 12 else 1)
Test["Family"] = Test["SibSp"] + Test["Parch"] + 1 
Test["Mother"] = Test["Family"].apply(lambda x: 0 if x<2 else 1)

Test.loc[(Test["Name"] == "Mr") & pd.isnull(Test["Age"]) ,"Age"] = MrMean
Test.loc[(Test["Name"] == "Mrs") & pd.isnull(Test["Age"]) ,"Age"] = MrsMean
Test.loc[(Test["Name"] == "Miss") & pd.isnull(Test["Age"]) ,"Age"] = MissMean
Test.loc[(Test["Name"] == "Dr") & pd.isnull(Test["Age"]) ,"Age"] = DrMean
Test.loc[(Test["Name"] == "Rev") & pd.isnull(Test["Age"]) ,"Age"] = RevMean
Test.loc[(Test["Name"] == "Master") & pd.isnull(Test["Age"]) ,"Age"] = MasterMean
Test.loc[(Test["Name"] == "Society") & pd.isnull(Test["Age"]) ,"Age"] = SocMean

# Create dummy vars ---------------
dummyTitles = pd.get_dummies(Train["Name"], prefix = "Title")
dummyClass = pd.get_dummies(Train["Pclass"],prefix="Class")

KeepTrain = ["Age", "Child", "Mother", "Sex", "Family","Survived"]
TrainData = Train[KeepTrain].join(dummyTitles.ix[:,:]).join(dummyClass.ix[:,:])
TrainData["Intercept"] = 1

dummyTitles = pd.get_dummies(Test["Name"],prefix = "Title")
dummyClass = pd.get_dummies(Test["Pclass"],prefix = "Class")
KeepTest = ["Age", "Child", "Mother", "Sex", "Family"]
TestData = Test[KeepTest].join(dummyTitles.ix[:,:]).join(dummyClass.ix[:,:])
TestData["Intercept"] = 1

# Create the model ----------------
from sklearn import linear_model

y= TrainData["Survived"]
X= TrainData.ix[:,TrainData.columns != "Survived"]

model = linear_model.LogisticRegression().fit(X,y)
print(model)

predictions = model.predict(TestData)

# Convert probability scores to binary
for x in predictions:
	if x >= .5:
		x = 1
	else:
		x = 0

# Create the submission set and export
submission = pd.DataFrame({'PassengerID': Test['PassengerId'],'Survived': predictions}) 
submission.to_csv("c:/users/ryan/dropbox/pythonprojects/titanic/output/submission.csv",
		index = False)
</pre>
