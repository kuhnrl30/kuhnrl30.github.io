---
title: "Introducing the LendingClub Package"
author: "Ryan Kuhn"
output: rmarkdown::html_vignette
layout: post
htmlwidgets: false
comments: true
tags: [R, P2PLending]
vignette: >
    %\VignetteIndexEntry{LabCorp Location Data Workflow}
    %\VignetteEngine{knitr::rmarkdown}
    \usepackage[utf8]{inputenc}
---

### Introduction  
Lending Club is a peer-to-peer lending site.  Peer-to-peer lending crowd-funds loans by matching borrowers with willing investors. This LendingClub library makes it easy for you to see your investor account data such as the amount of free cash or the details on which loans you own. This package is a convenience wrapper for the Lending Club API so that you get get the data into R. You can learn more about the API by reading [Lending Club's documentation](https://www.lendingclub.com/developers/lc-api.action)


### Getting Started  

#### Creating a User Credential 
To get started, you'll need to supply the investor's account number and API key. You can find the account number from the Account Summary page the API key is located at the bottom of the Account Settings page. Here, I've loaded them from a .Renviron file but you can use whatever process you are comfortable to pass them to the MakeCredential function. If you are going to share your code, then I recommend doing something similar to what I've done here rather than put it directly in your code.

The MakeCredential() function uses the investorID and APIkey inputs and creates a <code>LC_CRED</code> object in the global environment. The other functions in this package will look for this object to process the respective API calls.


```r
library(LendingClub)

investorID<- Sys.getenv("id")
APIkey<- Sys.getenv("key")

MakeCredential(investorID, APIkey)
```

#### A Few More Function Examples 
Here are examples of other functions in the package. As mentioned above, all other functions in this package will look for the <code>LC_CRED</code> object before processing the respective API calls.  You can see a dataframe of loans currently listed using the ListedLoans() function.  


```r
Loans<- ListedLoans()
dim(Loans$content)
```

```
[1] 584 103
```

Another useful function to start with is AccountSummary(). This returns key statistics such as the available cash, total number of notes owned, and all time total interest received. You don't pass any inputs to the function but it will search the environment for the LC_CRED object. 

```r
AccountSummary()
```

```
<LendingClub API>
                  Field       Value
1            investorId 15900271.00
2         availableCash        1.60
3          accountTotal      357.46
4       accruedInterest        2.12
5      infundingBalance        0.00
6      receivedInterest        9.17
7     receivedPrincipal       25.12
8      receivedLateFees        0.00
9  outstandingPrincipal      355.86
10           totalNotes       18.00
11      totalPortfolios        2.00
```

### Conclusion  
I hope this package can be useful for R users that want to built complex filter queries or possibly use machine learning to predict default rates. I plan to improve the package documentation as time progresses.

Please feel free to leave a comment below or contact me at kuhnrl30@gmail.com if you have question or comments about the package.
