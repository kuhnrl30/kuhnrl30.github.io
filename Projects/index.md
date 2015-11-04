---
layout: default
title: Projects
Resume: passive
Projects: active
blog: passive
moocs: passive
contact: passive
description: Projects for Ryan Kuhn, Finance Professional.
---

### Projects and Competitions  
- **Analysis of Credit Approval Data**  
This was the final project of the Advanced Topics in Audit Analytics course at Rutgers University. The course was part of the Masters of Accountancy curriculum and included topics ranging from basic descriptive statistics to apriori algorithms. I used this project as an opportunity to apply association rules using the arule package. I found these association rules were effecive in understanding the data but it wschallenging to vectorize them to predict values missing values. The data was downloaded from the UCI Machine Learning Repository. The analysis was documented in a report format and can be accessed <a href="../writeups/creditanalysis.html"> here</a>.  
[R Code](https://github.com/kuhnrl30/RProjects/tree/master/CreditAnalysis), 
[Data source](http://archive.ics.uci.edu/ml/datasets.html?format=&task=&att=&area=bus&numAtt=&numIns=&type=&sort=nameUp&view=table). 

  
- **Walmart- Sales in Stormy Weather**  
When I found out about this Kaggle competition, there was only a few days left before it ended. Therefore, this was an exercise in rapid development. The model I developed was simple yet quite effective; I finished in the 51st percentile  
[R Code](https://github.com/kuhnrl30/RProjects/blob/master/Walmart/Walmart.R), 
[Competition page](https://www.kaggle.com/c/walmart-recruiting-sales-in-stormy-weather)
  
- **Random Acts of Pizza**  
Reddit had a discussion group where people can ask others to buy them pizza. The goal of this competition is to predict whether a request would be successful and someone would buy the requester pizza. This competition afforded me the opportunity to learn how to work with JSON formatted data and how to use Classification And Regression Trees (CART). I found this new method is incredibly effective for classification problems provided the model is properly tuned. I started documenting my analysis <a href="../writeups/RAOP.html">here</a> but its still a work in progress. I hope to finish it soon.  
[R Code](https://github.com/kuhnrl30/RProjects/blob/master/RAOP/RAOP.Rmd), 
[Competition page](http://www.kaggle.com/c/random-acts-of-pizza) 
  
- **Predicting dropouts in MOOC**  
The objective of the KDD Cup 2015 was to predict if a student would drop out from a MOOC in the next 10 days. The dataset included distinct datapoints on course resources from multiple MOOCs and a log file showing when a student accessed the course resource.  I had never setup parallel processing before so I used this competition to work with the doParrallel package.  
[R Code](https://github.com/kuhnrl30/RProjects/tree/master/Mooc), 
[Competition page](https://kddcup2015.com/submission-rank.html)

- **Africa Soil Property Prediction**  
The objective of this Kaggle was to predict numerical soil properties from spectrometer readings. The dataset had several hundred variables to predict 4 estimands so I used this competition to work with dimension reduction techniques. I was able to implement both Support Vector Machines (SVM) and Principle Component Analysis (PCA) methods in my models. Unfortunately, pure motivation wasn't enough in this challenge; it required domain knowledge to be successful. I still can't understand the soil science behind this competition but it was fun to work with!  
[Competition page](http://www.kaggle.com/c/afsis-soil-properties)  
    
- **Titanic: Machine Learning from Disaster**  
This was my first machine learning competition where I cut my teeth with R. The competition was hosted by Kaggle. Kaggle provides tutorials on how to complete this competition with both R and Python. Since it was such a project to learn R, I've decided to return to the tutorials to learn Python.  
[Competion page](http://www.kaggle.com/c/titanic-gettingStarted)
    
- **New Jersey State Employee Payroll**   
This project was my first experience in designing a Shiny application and to work with CSS. The project was started to meet the requirements of a course in the Data Science Specialization on coursera. The application is hosted on Shinyapps.io and can be found <a href="https://kuhnrl30.shinyapps.io/ShinyProject" target="_blank"> here</a>.