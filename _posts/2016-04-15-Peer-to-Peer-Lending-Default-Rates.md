---
title: "Reducing Your Risk in Peer-2-Peer Loans"
output: html_document
layout: post
date: 'April 15, 2016'
comment: true
tags: [P2PLending]
---

## Analyzing Defaulted Loans to Reduce Downside Risk

I've been working with Peer-2-Peer lending data lately and want to share some interesting tidbits I've picked up along the way. For those who aren't familiar with it, Peer-2-Peer (P2P) lending connects borrowers directly with investors in a way that reduces the arbitrage costs traditional banks impose on transactions.

When a borrower applies for a loan, the P2P site breaks that loan into $25 increments and lists them on the site's marketplace for investors to purchase. The P2P site handles payment processing and takes a share of the interest payments as their fee.  The borrow benefits from interest rates generally lower than they'd get from a bank while the investors benefit from a higher return than bank equities. 

The exciting part about P2P lending data is that Prosper and Lending Club both publish their loan outcome data.  I've been working with Lending Club data and their published data goes back to 2011- 5 years of loan data!  That's a gold mine for someone like me that likes to play with new datasets.  There are over 850,000 loans to explore and build models from.  I'm working on building a model to predict whether a loan will default but for now I'm just going to share some interesting facts.




### Months of Payments  

I recently read this interesting  [post](http://andirog.blogspot.com/2013/02/lending-club-loans-months-of-payment.html) by Anil Gupta which looked at difference in default rates between 3 year and 5 years loans. Specifically, he calculated the percentage of loans that defaulted after each payment- a sort of survival analysis until default. 

This is critical for investors because their goal is to maximize the risk adjusted return on their investment. Eventually some of the loans are going to go sour, and when they do, you want to maximize the amount of payments you receive before then. Each payment reduces the amount of lost capital and therefore increases the total return.


The post was written in 2013 and, based on the data at the time, the 60 month loans were defaulting after fewer payments than the 36 month loans. This would imply that a 3 year loan is less risky than a 5 year loan because, on average, you'd get more principal back before its charged off.

I thought it would be interesting to refresh his charts with data through December 2015 and see if this insight still hold true. 








<div style="float:left;">
<img src="/images/p2plend1-1.png" title="plot of chunk p2plend1" alt="plot of chunk p2plend1" width= '475' height= '250' />

</div>

The chart at left compares how many months until loans defaulted for 36 and 60 month loans. In the original post, the lines did not match each other so closely allowing the author to hypothesize that the 60 month loans defaulted after fewer payments than the 36 month loans.  He also hedged against that hypothesis stating that, at that time, none of the 5 year loans had reached maturity.  Therefore, there could be loans that will eventually default but have not done so yet. 

Back in the present, there still hasn't been any 5-year loans that have matured. The earliest loans were issued in December 2011 and therefore mature at the end of this year.  We do have data on those that have already defaulted but that would exclude the many of the loans that were issued and will could still default but haven't done so yet.  

What we can observe from the chart is that the gap in payments-before-default for 5-year and 3-year loans had narrowed since 2013. In fact, the gap is nearly non-existent.  Based on the payments-before-default, these two different loan types have very similar risk profiles. This contrasts the earlier conclusion that 5 year loans may be more risky.  Avoiding 5 year loans based on the number of payments-before-default doesn't seem like a rationale strategy anymore.

<br style="clear: both"/>

### Days of the Week  
<div style="float:left;">
<img src="/images/p2plend2-1.png" title="plot of chunk p2plend2" alt="plot of chunk p2plend2" width= '475' height= '250' />
</div>
Another interesting pattern I noticed was that the default rates were different based on the weekday the loan was issued. There was book written in the 70's which warned not to buy cars built on Mondays or Fridays because they had quality issues. On Mondays, the employees were still recovering from the weekend, and on Friday they were only thinking about starting their weekend. That turned out not to be true but it looks like there may be some truth for P2P loans. 

Nearly 1 in 5 loans issued on Thursday ended in default but only 1 in 30 loans issued on Tuesday defaulted. What's perplexing is that the average interest rate for a Thursday loan is less than a Tuesday loan. Investors were getting less compensation for the additional risk of default. Of course, there may be other factors driving the variance, but I won't be investing in any Thursday loans if I can help it!

I'm happy to say the Lending Club data is a rich dataset with plenty of features to keep a curious mind entertained.  If you'd like to try your own analysis on the data, here is a [link to the R code](http://ryankuhn.net/scripts/P2PLending.html) I wrote to download and prep the data. If you enjoyed reading this, please [Subscribe](http://ryankuhn.net/blog/atom.xml) or share to your favorite social network.
