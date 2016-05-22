---
title: "How to Use SQL in R"
date: 2015-11-12
layout: post
htmlwidgets: false
comments: true
tags:
- R
- Northwind
- SQL
---



SQL, short for Structured Query Language, offers a fast and consistent way to manipulate data across platforms. Thanks to ANSI standardization, the same query string can be used in Access, MySQL, or other database options. Many business analysts are familiar with SQL but may not be as comfortable with R. This post will be a quick demonstration on how to put the two together and use SQL in R. 

#### Load the data 
Demonstrations in R usually use the well known Iris, Titanic, or Diamonds datasets whereas database demos often use the Northwind database.  Northwind was created by Microsoft to demo their MS Access product and since we are working with SQL for this exercise, we'll use the Northwind database. I've extracted the tables and put them in a package called Northwind. The package is hosted on GitHub and can be freely downloaded using the code below.


```r
library(devtools)
install_github('kuhnrl30/Northwind')
library(Northwind)
data(Northwind)
```
 
#### The SELECT Query 
The SELECT query is the most common application of SQL in business intelligence. Simply stated, it reads the data from a table and returns all the values matching the criteria provided. Adding criteria allows us to drill down into the data and remove the irrelevant results. 

>**A few recommendations**  
> 
>1. Form your SQL statement as a string variable and then pass the string to the sqldf function. By doing this, you are able to more clearly organize your query statement. 
>2. Make your SQL clauses all caps. The SQLDF package isn't case sensitive towards the clauses and I think it makes the statement pick out where the next clause begins.
> 

The first example is a SELECT query which returns the first 4 companies from the Customers table. Note sqldf uses the LIMIT syntax instead TOP used in the MS Access implementation. 


```r
library(sqldf)   

sqlString1<- paste("SELECT Company",  
                   "FROM Customers",  
                   "LIMIT 4",  
                   sep=" ")  
sqldf(sqlString1)
```

```
    Company
1 Company A
2 Company B
3 Company C
4 Company D
```
    
    
That's great but it's really a simple query that doesn't really tell us much. In real application, SQL queries are much more complex and the sqldf package can handle those too. To demonstrate, we'll up the complexity by adding multiple joins and a calculated field. This next query calculates the total order price for each OrderDetails line and then sums them by the Company that placed the order. To get there we have to join the OrderDetails table to the Orders table, then perform a second join to the Customers table. Finally, the results are sorted so the OrderTotal field is in descending order.


```r
sqlString2<- paste("SELECT Company, CustomerID, ",  
                      "count(Orders.OrderID) as OrderCount,",  
                      "sum(Quantity * UnitPrice) as OrderTotal",   
                   "FROM Customers",   
                   "INNER JOIN Orders",  
                   "ON Customers.ID = Orders.CustomerID",  
                   "INNER JOIN OrderDetails",  
                   "ON Orders.OrderID= OrderDetails.OrderID",  
                   "GROUP BY CustomerID, Company",   
                   "ORDER BY OrderTotal DESC",   
                   "LIMIT 5",  
                    sep = " ")  
                    
sqldf(sqlString2)
```

```
     Company CustomerID OrderCount OrderTotal
1 Company BB         28          4    15432.5
2  Company G          7          1    13800.0
3  Company F          6          6     8007.5
4  Company D          4          7     4949.0
5  Company H          8          6     4683.0
```
  
    
Now that query was a little more interesting than a simple customer list! The result-set above shows us that Company BB is our largest customer. We might follow up with questions such as which employees are handling Customer BB's account or what items did the customer buy. 

#### SQL is similar to dplyr 
For those who already know or are familiar with SQL, the sqldf package offers an easy way to leverage that knowledge in R. If offers a simple way to extract data from multiple tables. Contrarily, if you are familiar with the popular dplyr package, you can see the similarities in syntax between dplyr and SQL. Here we accomplish the same results using the dplyr package. Both formats use the INNER JOIN and GROUP BY calls. Where they differ is that dplyr requires the additional functions mutate and summarise but SQL handles the calculations directly the SELECT statement.  (Yes, I said summarise and not summarize. That's just how Hadley spells it.)


```r
library(dplyr)

Orders %>%
inner_join(Customers,by=c("CustomerID"="ID")) %>%
inner_join(OrderDetails,by=c("OrderID"="OrderID")) %>%
mutate(OrderTtl= Quantity*UnitPrice)%>%
group_by(Company,CustomerID) %>%
summarise(OrderCount=length(OrderID),
          OrderTotal=sum(OrderTtl)) %>%
ungroup() %>%
arrange(desc(OrderTotal)) %>%
top_n(5)
```

```
Source: local data frame [5 x 4]

     Company CustomerID OrderCount OrderTotal
       (chr)      (int)      (int)      (dbl)
1 Company BB         28          4    15432.5
2  Company G          7          1    13800.0
3  Company F          6          6     8007.5
4  Company D          4          7     4949.0
5  Company H          8          6     4683.0
```

