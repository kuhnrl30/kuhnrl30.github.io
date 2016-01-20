---
title: "Fantasy Football Analytics in R - Part II"
date: 2016-01-19
layout: post
comments: true
tags: [Fantasy-Football, R]
---

## Using the Yahoo Fantasy Sports API  
This is the second post in a series performing analytics on my Yahoo Fantasy Football team using R. In the **[prior post](http://ryankuhn.net/blog/Fantasy-Football-in-R/)** I demonstrated how to connect to Yahoo Sports APIs. That post left off having connected to the API and pulled the standings for my league. I never discussed how I learned the league and game ID variables. Let's start by going through that process which will also help to understand the API structure of Collections and Resources. 


#### Reloading the Signature Credential  
In order to start from where I last left off, I first have to reload the credential. You may remember creating the credential was the purpose of the last post so I'll assume you've already done that step. I saved the <font face= "courier">sig</font> variable to an .Rmd file and will simply reload it here. 


```r
library(httr)
library(XML)
load("Fantasy.Rdata")
```

#### Getting the Game ID
The Game ID is how Yahoo defines the sport and season of the fantasy team. There is a unique ID number for each sport/season combo so the 2015 football season has a different key from the 2014 football season which is different than the 2015 basketball season. You can get this table directly from the documentation but we can also use the API.


```r
baseURL <- "http://fantasysports.yahooapis.com/fantasy/v2/"
GameQry <- "game/nfl"
GameURL <- paste(baseURL, GameQry,sep="")

page    <- GET(GameURL, sig)
XMLGames<- content(page)
xmlRoot(XMLGames)[[1]][[2]]
```

```
<game_id>348</game_id> 
```
  
#### Getting the League ID
As far as I can tell, the League ID can't be retrieved from the API. Instead, you can find it easily from your league page on Yahoo. Navigate to your league on Yahoo Fantasy and click the League link. This will open the Overview page with your league ID in large letters. You can't miss it!


<img src="/images/yahoo_sports2.png" alt="Yahoo Sports" align="center" width="750" height="500" hspace="20"> 


## Compare Actual and Projected Weekly Point Spread  

#### Extracting the Data   
Start by extracting the data from Yahoo using the API. You'll need the Game ID and League ID from above to finish out the query. Append these query parameters to the base query string from above. Next, using the GET function, pass the query string and signature to the API to receive the response from the API. The data in the response will be in XML format and can be access with list notation.

```r
library(ggplot2)
library(tidyr)
library(dplyr)

GameQry <- "team/348.l.1288584.t.5/matchups"
GameURL <- paste(baseURL, GameQry, sep="")
page    <- GET(GameURL, sig)
XML     <- content(page)
root    <- xmlRoot(XML)
```

With the data returned from the API, the next step is to extract the elements needed from the XML format and convert to a data frame. The scoring stats I'm looking for are pretty deep into the XML tree so be careful with the brackets on your way down. I'm going to extract the same data for each of the 14 weeks so it is more efficient to compose a function and loop through the list rather than repeat the same code 14 times. There are two teams in every matchup so to get the data on both team each week, I passed two variables to the query- 1 for the week and another for the team. The mapply function works similar to the other functions in the apply family and allows me to pull the data for each combination of week and team.


```r
GetPoints<- function(x,y){
  A<- xmlValue(xmlChildren(root[[1]][[13]][[x]])[10][[1]][[y]][["name"]])
  B<- xmlValue(xmlChildren(root[[1]][[13]][[x]])[10][[1]][[y]][["team_points"]][["total"]])
  C<- xmlValue(xmlChildren(root[[1]][[13]][[x]])[10][[1]][[y]][["team_projected_points"]][["total"]])
  D<- xmlValue(xmlChildren(root[[1]][[13]][[x]])[10][[1]][[y]][["team_points"]][["week"]])
  c(A, B, C, D)
}

Combos<- data.frame(x=unlist(lapply(1:15, function(x) rep(x,2))), y= 1:2)
temp  <- mapply(GetPoints, Combos[,1], Combos[,2])
Weekly.Points<- data.frame(t(temp))
names(Weekly.Points)<- c("Team", "Actual", "Projected", "Week")
```
I want to compare the predicted and actual point spread for each matchup. Here I've calculated the spread as the difference between my team's points and the opponent's score. A little more formatting and we get a long, tidy data set.  

```r
# Cleanup data and create a tidy dataset
Weekly.Points$Team<- ifelse(Weekly.Points$Team=="Ryan's Team", "My_Team", "Opponent")
Weekly.Points$Team<- factor(Weekly.Points$Team)
Weekly.Points[, c(2:4)]<- sapply(Weekly.Points[,c(2:4)], as.character)
Weekly.Points[, c(2:4)]<- sapply(Weekly.Points[,c(2:4)], as.numeric)

Tidy<- Weekly.Points %>%
  gather(Type, Points, Actual:Projected) %>%
  unite(Key, Team, Type, sep="_") %>%
  spread(Key, Points) %>%
  mutate(Actual_Spread= My_Team_Actual- Opponent_Actual,
         Projected_Spread= My_Team_Projected- Opponent_Projected)

head(Tidy)
```

```
  Week My_Team_Actual My_Team_Projected Opponent_Actual Opponent_Projected
1    2          84.62             87.35          100.74              90.42
2    3          85.00             95.08           58.38              98.95
3    4          53.84             91.51           61.94              85.39
4    5          70.26             98.13           48.20              71.38
5    6          82.40             97.12          121.80             107.51
6    7         106.74             87.90           55.60              73.10
  Actual_Spread Projected_Spread
1        -16.12            -3.07
2         26.62            -3.87
3         -8.10             6.12
4         22.06            26.75
5        -39.40           -10.39
6         51.14            14.80
```

#### Getting Ready to Plot   
The data needs to be in a long format before being passed to ggplot. 


```r
Spread<-Tidy %>%
  select(-(My_Team_Actual:Opponent_Projected)) %>%
  gather(Type, Spread, Actual_Spread:Projected_Spread) %>%
  arrange(Week)

Spread$Type<- relevel(Spread$Type, ref="Projected_Spread")
head(Spread)
```

```
  Week             Type Spread
1    2    Actual_Spread -16.12
2    2 Projected_Spread  -3.07
3    3    Actual_Spread  26.62
4    3 Projected_Spread  -3.87
5    4    Actual_Spread  -8.10
6    4 Projected_Spread   6.12
```

The last step is to prepare the plot comparing the predicted point spread and the actual point spread. This will show how accurate the predictions were and there may be other lessons to learn from the data. The actual point spread in red is the difference between my points and my opponents points at the end of the week. The projected point spread in blue is the difference between the projected points at the beginning of the week. 


```r
a<- ggplot(Spread)
a<- a + aes(x=Week, y=Spread, group= Type, fill=Type)
a<- a + geom_bar(stat="identity", position="dodge", colour="black")
a<- a + scale_fill_manual(values=c("blue","red"))
a<- a + theme(plot.background = element_rect(fill="white"),
              panel.background = element_rect(fill="white"),
              axis.line = element_line(size=.5, colour= "gray"),
              panel.grid.major = element_line(size=.5, 
                                              colour="gray", 
                                              linetype = "dotted"))
a<- a + labs(title= "Comparing Projected to Actual Point Spread")
```


<img src="/images/SpreadChart-1.png" title="plot of chunk SpreadChart" alt="plot of chunk SpreadChart" width="750px" width= '750' height= '400' style="display: block; margin: auto;" />

#### Observations from the Data  
Looking at the chart, I'm immediately drawn to week 11. The actual spread is about -75 points meaning I lost big time. Let me just explain this as the week Drew Brees had a ridiculous game- throwing 5 touchdowns. Can we chalk that up as an outlier and move on? Thanks.   

The next thing I notice is that the projected outcome seems to get more accurate as the point spread increases. If Yahoo projected that I would win by a large margin, then I probably won the week. The same thing goes for losses; if they projected I would lose by a lot of points, then its likely that I actually lost. 

Let's test the data to confirm my observation. Using the projected point spread, I created a variable to indicate if Yahoo projected I would win or lose the week and another to indicate if the actual outcome of the matchup. Next, I created a third variable to track the accuracy of the projected. If projected outcome was a win and I actually won, the the accuracy is true. If the projected and actual values are not matching, then the accuracy variable is false. Finally, I've used a box plot to compare the projection accuracy and the projected point spread. The box plot will give the mean point spread by accuracy score.   


```r
AccuracyData <- Tidy %>%
  mutate(Projected_Outcome= ifelse(Projected_Spread>0, "Win", "Loss"),
         Actual_Outcome =ifelse(Actual_Spread>0, "Win", "Loss"),
         Projection_Accuracy= factor(Projected_Outcome==Actual_Outcome))

b<- ggplot(AccuracyData)
b<- b + aes(Projection_Accuracy, abs(Projected_Spread), fill=Projection_Accuracy)
b<- b + geom_boxplot()
b<- b + labs(title= "Comparing Projected Outcome Accuracy by Point Spread",
             x= "Projection Correct",
             y= "Projected Point Spread")
```

Very quickly can see that the false accuracy scores have a lower mean projected spread. This supports the observation that projections were more accurate as the point spread increased. Thinking about this intuitively, larger point spreads give more cushion to absorb any forecasting error.  

<img src="/images/boxplot-1.png" title="plot of chunk boxplot" alt="plot of chunk boxplot" width="750px" height="2" width= '750' height= '400' style="display: block; margin: auto;" />

We can do a simple t.test and confirm statistically that the mean point spread for accurate projections is greater than incorrect projections. The p-value in the test is approximately .09 so we can say with greater than 90% confidence that the actual difference between the two sample means is greater than zero. Again, more support for the intuitive observation.

```r
t.test(abs(Projected_Spread)~Projection_Accuracy, 
       data=AccuracyData, 
       alternative="less")
```

```

	Welch Two Sample t-test

data:  abs(Projected_Spread) by Projection_Accuracy
t = -1.4328, df = 12.009, p-value = 0.08872
alternative hypothesis: true difference in means is less than 0
95 percent confidence interval:
     -Inf 2.011832
sample estimates:
mean in group FALSE  mean in group TRUE 
               8.90               17.15 
```

### The Bottom Line  
If you are projected to win or lose by a large margin, then you probably will. If the projected point spread is small, well... that's why they play the game.  

Thanks for reading and I hope to see you next time. 
