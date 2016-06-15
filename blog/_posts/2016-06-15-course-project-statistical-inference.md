---
title: "Statistical Analysis of Tooth Growth"
output:  html_document
layout: post
date: 'June 15, 2016'
comments: true
tags: [R, DataScienceSpecialization]
htmlwidgets: false
---

## Objective  
The purpose of this article is to demonstrate an inferential analysis using the tooth growth data set that comes with R. The dataset measures the impact of Vitamin C on tooth growth in guinea pigs and includes observations for different combinations of 2 supplements and 3 dosages. There are 10 observations for each combination of dosage and supplement for a total of 60 observations. The supplements are orange juice (OJ) or ascorbic acid (VC). This article was prepared for the Statistical Inference course offered by John Hopkins University on the Coursera platform.  The course can be [accessed here]( https://www.coursera.org/learn/statistical-inference).  

## Inferential Data Analysis  
Figure 1 below shows the range of tooth length for each combination of supplements and dosages. Each box includes a horizontal range indicated the mean value for the values. At first visual inspection, we note that there is an increasing trend in tooth length as the supplement dosage increases. We can also see that the mean value for 'VC' supplement is less than 'OJ' for smaller doses but the difference seems to diminish as the dose size increases. This is confirmed by the values in Table 1 below. 

We can use the T-test to determine if the tooth growth is statistically different between the two supplements for each dosage level. We'll do separate test for each of dosage level: 0.5 mL, 1 mL, and 2 mL. We will test our hypothesis that supplements don't have an impact on the tooth growth. After another look at Figure 1, it looks like there is difference in the two supplements at the 0.5 mL and 1 mL level but there may not be a difference at 2 mL. If the resulting p-value from these tests are less than 0.05, then we can state our conclusions with 95% confidence. Before continuing, we have to note one primary assumption is this test: that the data is paired.This is appears to be a safe assumption because for each combination, there are exactly 10 observations, but none the less, it is an assumption because I did not personally collect the data.

The p-values for the first two tests were very small as expected. I say the test values are as expected because we can see clearly from figure 1 that the mean tooth length between orange juice and ascorbic acid are not the same for the 0.5 mL and 1 mL dose. On the other hand, this is not true for the 2 mL dosage since the mean values are close together. Overall, we can conclude from these tests that teeth grow longer with orange juice over ascorbic acid when the dose is 1 mL or less. Greater than 1 mL, there does not appear to be a difference in tooth growth.




|Dosage | T.Test.p.Value|Decision      |
|:------|--------------:|:-------------|
|0.5 mL |       0.006359|Do not reject |
|1 mL   |       0.001038|Do not reject |
|2 mL   |       0.963900|Reject        |


## Supporting R Code  


```r
library(dplyr)
library(tidyr)
library(ggplot2)

Data<-ToothGrowth
Data$dose<- factor(Data$dose)
```


```r
ggplot(Data) + 
  aes(x=dose,y=len, fill= supp) +
  geom_boxplot() +
  labs(title= "Fig 1: Tooth growth by Supplement and Dose size")
```

![plot of chunk toothgrowth](/images/toothgrowth-1.png)


```r
#   The output shows the summary statistics for each of the variables. It
#   does not provide information about the combination of values. Most
#   importantly, it shows the quartile distribution of the 'len' or lenght
#   variable.
summary(Data)
```



|   |     len      |supp  | dose  |
|:--|:-------------|:-----|:------|
|   |Min.   : 4.20 |OJ:30 |0.5:20 |
|   |1st Qu.:13.07 |VC:30 |1  :20 |
|   |Median :19.25 |NA    |2  :20 |
|   |Mean   :18.81 |NA    |NA     |
|   |3rd Qu.:25.27 |NA    |NA     |
|   |Max.   :33.90 |NA    |NA     |

**Tbl 1: Mean Tooth length by combination**

```r
# Summary of means
#   The table shows the mean tooth length for each combination of 
#   suppment and dose size.
Data %>%
  group_by(supp,dose) %>%
  summarise(Mean= mean(len)) %>%
  spread(dose,Mean)
```



|supp |   0.5|     1|     2|
|:----|-----:|-----:|-----:|
|OJ   | 13.23| 22.70| 26.06|
|VC   |  7.98| 16.77| 26.14|

**T- Test for significance of impact of supplment**

```r
t.test(len~supp,Data[Data$dose=="0.5",])
```

```

	Welch Two Sample t-test

data:  len by supp
t = 3.1697, df = 14.969, p-value = 0.006359
alternative hypothesis: true difference in means is not equal to 0
95 percent confidence interval:
 1.719057 8.780943
sample estimates:
mean in group OJ mean in group VC 
           13.23             7.98 
```

```r
t.test(len~supp,Data[Data$dose=="1",])
```

```

	Welch Two Sample t-test

data:  len by supp
t = 4.0328, df = 15.358, p-value = 0.001038
alternative hypothesis: true difference in means is not equal to 0
95 percent confidence interval:
 2.802148 9.057852
sample estimates:
mean in group OJ mean in group VC 
           22.70            16.77 
```

```r
t.test(len~supp,Data[Data$dose=="2",])
```

```

	Welch Two Sample t-test

data:  len by supp
t = -0.046136, df = 14.04, p-value = 0.9639
alternative hypothesis: true difference in means is not equal to 0
95 percent confidence interval:
 -3.79807  3.63807
sample estimates:
mean in group OJ mean in group VC 
           26.06            26.14 
```
