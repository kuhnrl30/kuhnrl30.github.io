---
title: "Lending Club - Loan Defaults"
output: html_document
layout: post
date: 'April 15, 2016'
comment: true
tags: [R, P2PLending]
---

## Analysis of Default Rates By Number of Monthly Payments

I've been working with Peer-2-Peer lending data lately and want to share some interesting tidbits I've picked up along the way. For those who aren't familiar with it, Peer-2-Peer (P2P) lending connects borrowers directly with investors in a way that reduces the arbitrage costs traditional banks impose on transactions.

When a borrower applies for a loan, the P2P site breaks that loan into $25 increments and lists them on the site's marketplace for investors to purchase. The P2P site handles payment processing and takes a share of the interest payments as their fee.  The borrow benefits from interest rates generally lower than they'd get from a bank while the investors benefit from a higher return than bank equities. 

The exciting part about P2P lending data is that Prosper and Lending Club both publish their loan outcome data.  I've been working with Lending Club data and their data set goes back to 2011- 5 years worth of data!  That's a gold mine for someone like me that likes to play with new datasets.  There are over 850,000 loans to explore and build models from.  I'm working on building a model to predict whether a loan will default but for now I'm just going to share some interesting facts.




### Months of Payments  

I recently read this interesting  [post](http://andirog.blogspot.com/2013/02/lending-club-loans-months-of-payment.html) by Anil Gupta which looked at difference in default rates between 3 year and 5 years loans. Specifically, he calculated the percentage of loans that defaulted after each month- a sort of survival analysis until default. This is a critical factor for an investor because any defaulted loan will hurt your total return. The author had estimated the time until default using number of payments against the loan. The logic being that borrowers make only one payment per month.  The post was written in 2013 and, based on the data at the time, the 60 month loans were defaulting after fewer payments than the 36 month loans. I thought it would be interesting to refresh his charts with data through December 2015 and see if the insights still hold true. 




<div style="float:left;">
<img src="/images/p2plend1-1.png" title="plot of chunk p2plend1" alt="plot of chunk p2plend1" width= '475' height= '250' />

</div>

The chart compares how many months until loans defaulted for 36 and 60 month loans. In the original post, the lines did not match each other so closely allowing the author to hypothesize that the 60 month loans defaulted after fewer payments than the 36 month loans.  He also hedged against that hypothesis stating that, at that time, none of the 5 year loans had reached maturity.  Therefore, there could be loans that will eventually default but have not done so yet. 

Back in the present, there still hasn't been any 5 year-long loans that have matured. The earliest loans in the downloads were issued in December 2011 and therefore mature at the end of this year.  We do have data on those that have already defaulted but that would exclude the many of the loans that were issued and will could still default but haven't done so yet.  What we can observe from the dataset is that the gap in the number of months until default for 5 year and 3 years loans narrowed since 2013. In fact, the gap is nearly non-existent.

<br style="clear: both"/>

### Days of the Week  
<div style="float:left;">
<img src="/images/p2plend2-1.png" title="plot of chunk p2plend2" alt="plot of chunk p2plend2" width= '475' height= '250' />
</div>
Another interesting pattern I noticed was that the default rates were different based on the weekday the loan was issued. There was book written in the 70's which warned not to buy cars built on Mondays or Fridays because they had quality issues. On Mondays, the employees were still recovering from the weekend, and on Friday they were only thinking about starting their weekend. That turned out not to be true but it looks like there may be some truth for P2P loans. 

Nearly 1 in 5 loans issued on Thursday ended in default but only 1 in 30 loans issued on Tuesday defaulted. What's perplexing is that the average interest rate for a Thursday loan is less than a Tuesday loan. Investors were getting less compensation for the additional risk of default. Of course, day of the week is only 1 factor and there may be other factors driving the variance. 

I'm happy to say the Lending Club data is a rich dataset with plenty of features to keep a curious mind entertained.  If you'd like to try your own analysis on the data, here is a [link to the R code](http://ryankuhn.net/scripts/P2PLending.html) I wrote to download and prep the data. If you enjoyed reading this, please [Subscribe](http://ryankuhn.net/blog/atom.xml) or share to your favorite social network.
