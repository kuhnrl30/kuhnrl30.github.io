---
title: "Fantasy Football Analytics in R- Part 1"
date: 2015-12-22
output: html_document
layout: post
comments: true
---



## Connecting to the Yahoo Sports API with R  
Fantasy sports can be fun. They are especially fun for data nerds like me who aren't necessarily sports fans. This is the first of several posts describing how to perform analytics on my Yahoo fantasy team using R. In this post I will demonstrate how to connect to the Yahoo Sports API, or Application Programing Interface, using the httr package.

### Setup the App
The first step in the process is to register an application with Yahoo  **[here](https://developer.yahoo.com/apps/create/)**. This is the doorway through which you get access to the league data.  Make sure you check the box for Fantasy Sports at the bottom of the form. Once you have your app registered, Yahoo will provide you with a consumer key and secret which you will need later.

Yahoo's  **[documentation](https://developer.yahoo.com/fantasysports/guide/)** on the API is pretty dense so I will try to distill it here. The API is based on the RESTful model and built on collections and resources.  Resources are objects within collections; each resource is itself a collection.  To illustrate, a collection of teams is composed of player resources.  In turn, the Players collection is composed player transaction resources.  

Once you have registered your app, the next step is to setup the connection to the API and create your credential. Credentials are the after-effect of requesting access to the user's data and verifying you have been granted permission to do so. You'll do this once and then pass the credential to the API with each query. I've saved my consumer key and secret from above into a text file but you could use them directly in the code if that is your preference. 

```r
# Setup the environment
library(httr)
library(XML)
```

```
Loading required package: methods
```

```r
library(httpuv)
options("httr_oob_default" = T)

# Setup the app
cKey     <- readLines("Creds.txt", warn=F)[1]
cSecret  <- readLines("Creds.txt", warn=F)[2]

yahoo    <-oauth_endpoints("yahoo")

myapp <- oauth_app("yahoo", key=cKey, secret=cSecret)
yahoo_token<- oauth2.0_token(yahoo, myapp, cache=T, use_oob = T)
sig <- sign_oauth1.0(myapp, yahoo_token$oauth_token, yahoo_token$oauth_token_secret)
```

### Query the API  
After registering your app and creating your credential, you are now ready to start pulling data. The API is based on the RESTful model so you'll pull the data by building a URL. For the sake of this demonstration, I pulled the team standings in my league. Make sure to plug in your own league ID as mine will not work for you. The default data type is xml but you change the format to JSON by adding '?format=json' to the end of the ULR. 

The League ID as I'm using it in the code is actually a composition of the Game ID and my League ID. You can read the documentation for the complete definition of Game ID but think of it as the identifier for the 2015 football season.  There is a separate identifier for each football, basketball, baseball, or hockey season. The '.l.' signifies a league collection and separates the Game ID and the League ID. 


```r
baseURL     <- "http://fantasysports.yahooapis.com/fantasy/v2/league/"
leagueID    <- "348.l.1288584"
standingsURL<-paste(baseURL, leagueID, "/standings", sep="")

page <-GET(standingsURL,sig)
XMLstandings<- content(page, as="text", encoding="utf-8")

doc<-xmlTreeParse(XMLstandings, useInternal=TRUE)
myList<- xmlToList(xmlRoot(doc))
```

### Extract the Standings (Week 13)
The final step in this demo is to convert the raw xml data into a format that is easier to read. My preference is to convert it to a list and then use the standard list notation but you could use the XML path if you prefer. Since the data I wanted was in different elements of the list, I created a simple function to extract the data for each team.


```r
# Function to extract data from different elements of the list
FromMyList<- function(x){
  A<-myList$league$standings$teams[[x]]$name
  B<-unlist(myList$league$standings$teams[[x]]$team_standings$outcome_totals)
  C<-unlist(myList$league$standings$teams[[x]]$team_standings$streak)
  names(A)<-names(B)<-names(C)<-NULL
  c(A,B,C)
  }

# Combine the data into a dataframe
Standings<- as.data.frame(matrix(unlist(lapply(1:10, function(x) FromMyList(x))), byrow=T, ncol=7))

# Apply formatting
names(Standings)<- c("Team Name", "Wins", "Losses", "Ties", "Win Pct", "Streak Type", "Streak")
kable(Standings)
```



|Team Name           |Wins |Losses |Ties |Win Pct |Streak Type |Streak |
|:-------------------|:----|:------|:----|:-------|:-----------|:------|
|Touchdown Below     |12   |1      |0    |.923    |win         |6      |
|My Team             |12   |1      |0    |.923    |win         |4      |
|Favre & Goal        |9    |4      |0    |.692    |win         |1      |
|Ryan's Team         |8    |5      |0    |.615    |win         |3      |
|Taylor's Team       |7    |6      |0    |.538    |loss        |2      |
|Travis's Team       |6    |7      |0    |.462    |loss        |1      |
|Chez's Awesome Team |4    |9      |0    |.308    |win         |2      |
|michael's Team      |3    |10     |0    |.231    |loss        |4      |
|lola's Legit Team   |2    |11     |0    |.154    |loss        |6      |
|Bob's Bold Team     |2    |11     |0    |.154    |loss        |5      |

That's how you connect to the Yahoo Sports API. There are many interesting ways to use it and I'll demonstrate a few of them in the next post so stay tuned.  If you liked this post, then feel free to share!
