---
title: 'Analyzing Activity Tracker Data'
output: html_document
layout: post
date: 2016-02-06
comments: true
tags: [R, DataScienceSpecialization]
---

### Course Project for Reproducible Research   
I've just finished the last course in the Data Science Specialization on Coursera. The program is offered by Drs. Jeff Leek, Roger Peng, and Brian Caffo of John Hopkins University. There are 9 courses in all, each with small project at the end. As you'd expect, the projects are targeted toward the topic of the course and not the entire data science workflow. They aren't comprehensive enough to put on my projects page but I still think they were important enough to share. I think a blog is the right place to share the project.

What follows is my write up for the [Reproducible Research](https://class.coursera.org/repdata-008) course. The goal of this project was to get familiar with using the markdown language and knitr packages in RStudio. The focus was on the tools instead of the analysis so the summaries and charts were closely directed by instructions and was graded by peers according to a defined rubric. The data set was obtained from the instructor provided link and, while I assume it hasn't been fabricated, I take no responsibility for its validity or accuracy. 


### Load the data
The first step is to download the data. The data was downloaded as a zip file so must be unzipped before being loaded.  

```r
setInternet2(use=TRUE)
myURL<- "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2Factivity.zip"
download.file(myURL,destfile="Data.zip",mode="wb")
unzip("Data.zip")
Raw.Data<-read.csv("activity.csv")
```

### Exploratory Analysis
Now that the data has been loaded into R, we can perform the basic exploratory analysis to understand what the data looks like.  My preference is to use the str() command.  Based on the output we can see that there are 17,568 rows of data and 3 variables. The date variable has 61 levels indicating we have data from 61 different dates.  The interval variable is the time of day the measurement was taken.


```r
str(Raw.Data)
```

```
'data.frame':	17568 obs. of  3 variables:
 $ steps   : int  NA NA NA NA NA NA NA NA NA NA ...
 $ date    : Factor w/ 61 levels "2012-10-01","2012-10-02",..: 1 1 1 1 1 1 1 1 1 1 ...
 $ interval: int  0 5 10 15 20 25 30 35 40 45 ...
```

```r
max(Raw.Data$interval)
```

```
[1] 2355
```

Let's create a histogram of the number of steps by date.


```r
TTL.by.Day<-aggregate(steps~date,data=Raw.Data,FUN=sum)
hist(TTL.by.Day$steps,
     main="Histogram of Total Steps per Day",
     xlab="Total Steps",
     ylab="Frequency",
     col="red")
```

![plot of chunk ReproResearch1](/images/ReproResearch1-1.png)

This shows a clear peak at the 10K - 15K step bin.  The data looks normally distributed but we'll calculate the mean and median steps per day to verify. They mean and median values are pretty close so we can accept our assumption.

```r
mean(TTL.by.Day$steps)
median(TTL.by.Day$steps)
```

```
[1] 10766.19
[1] 10765
```


### Time Series Analysis
Lets create a time series analysis to understand the activity by time of day. We'll calculate the average number of steps of at each five minute interval and chart that average.  

```r
Avg.Series<- aggregate(steps~interval, data=Raw.Data, FUN=mean)
plot(Avg.Series,type="l",axes=F,
     main="Average Steps by Time of Day")
axis(side=1, at=seq(0,2400,by=100))
axis(side=2, at=seq(0,225,by=25))
```

![plot of chunk ReproResearch2](/images/ReproResearch2-1.png)

There is a clear spike at around 8am but which interval is the actual maximum?  The which.max() function can be used in the row index to return the interval to answer that question: 8:35am.

```r
Avg.Series[which.max(Avg.Series$steps),1]
```

```
[1] 835
```
#### Handling missing values
There are several missing values in the data set. To calculate how many, we can use the complete.cases() function.  It returns a logical value- true for complete cases and false for incomplete cases.  The logical values can be counted by the sum function.


```r
sum(!complete.cases(Raw.Data$steps))
```

```
[1] 2304
```
Since the data set has missing values, we'll impute them using the average values by interval calculated in the Step 3 above.


```r
library(plyr)
New.Data<-join(Raw.Data,Avg.Series,by="interval")
New.Data[,1]<-ifelse(is.na(New.Data[,1]),New.Data[,4],New.Data[,1])
New.Data<-New.Data[,-4]
```

As a check to make sure the data hasn't been distorted, we'll regenerate the time series analysis and put it next to the original created in Step 3 above. I've used the lattice package to draw the charts and they look identical.


```r
New.Avg<-aggregate(steps~interval,data=New.Data,FUN=mean)
library(lattice)
xyplot(steps~interval|which,
       make.groups(Avg.Series=Avg.Series,New.Avg=New.Avg),
       groups=which,auto.key=T,type="l",ylab="Steps",col=c("red","blue"),
       main=list(label="Comparison of Activty levels",cex=1.25),
       strip=strip.custom(factor.levels=c("NAs Omitted","NAs Imputed")),
       layout=c(1,2),scales=list(x=list(limits=c(0,2400),tick.number=10)))
```

![plot of chunk ReproResearch3](/images/ReproResearch3-1.png)

### Comparing Weekday and Weekend Activity
The last step of this analysis is to determine if there is a difference between he activity levels on the weekend.  First, we'll use create a factor to indicate the day as weekday or weekend.  The $wday name of POSIXlt is zero indexed so it returns a value 0-6 with Sunday as 0 and Saturday as 6. We'll use the aggregate function again to calculate the means and then we'll draw the plots.


```r
New.Data$Weekday<-strptime(New.Data$date,format="%F")$wday
New.Data$Weekday<-as.factor(ifelse(New.Data$Weekday<6 & New.Data$Weekday>0,"Weekday","Weekend"))
Split.Avg<-aggregate(steps~Weekday+interval,data=New.Data,mean)

xyplot(steps~interval|factor(Weekday),data=Split.Avg,type="l",
       main=list(label="Comparison of Average Activity by Weekend and Weekdays",cex=1.25),
       ylab="Steps",xlab="Time of Day", layout=c(1,2),col="black",
       scales=list(x=list(limits=c(0,2400),tick.number=10)))
```

![plot of chunk unnamed-chunk-7](/images/unnamed-chunk-7-1.png)

In comparing the plots, we can see that the general activity patterns fairly different. The weekend activity levels are much higher throughout the day whereas the weekday activity level has a dramatic spike between 8 and 9am.  In both charts there is nearly no activity until 5am.  These patterns seem reasonable because people are generally sleeping so not moving in the morning and on weekdays may go to the gym in the morning before sitting at their desk for the rest of the day.  On weekends, people are off of work so are free to move about all day.
