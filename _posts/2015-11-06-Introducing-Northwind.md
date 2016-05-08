---
title: "Introducing the Northwind package"
date: 2015-11-06
layout: post
comments: true
htmlwidgets: false
tags:
- R
- Northwind
---

## Datasets from a business information system

Northwind is a new package with datasets from the well-known Northwind database. The datasets consist of relational tables that are perfect for demonstrating the sqldf package or business analytics techniques. After one too many R tutorials using the Iris dataset I decided we needed an alternative. I decided this would be how I'd make my first R package. You can download the package like this:


```r
library(devtools)
install_github("kuhnrl30/Northwind")
library(Northwind)
data(Northwind)
```

### Available tables
If you are familiar with accounting, then you'll appreciate that the tables involve the revenue and expenditure cycles. There are tables related to making money and spending money.  Here's a few of the major tables available in the package:

- Customers
- Orders
- Inventory
- Suppliers
- Purchases

### Lessons Learned 
If there's one thing I learned from the process is that RStudio makes building a package easy.  In my first attempts to compile the package I used a sort of make-file that I had cobbled together from bits of code from blog posts. It was awkward and never seemed to work all the way through. Later I found that if I created a package project, then RStudio offers build and check features at the click of a button. It's so much easier than my old make-file method.

I hope you enjoy the package and stay tuned for tutorials on business analytics and introductions to SQL!
