---
layout: default
title: Peer-2-Peering Loan Default R Code
Resume: passive
Projects: passive
blog: passive
moocs: passive
contact: passive
description: R Code Used analysis of P2P loans and default rates
---

### Lending Club - Loan Defaults

#### Functions  
<pre>
Prep_Loan_Data<- function(x){
  f<- read.csv(x,stringsAsFactors = F, skip=1, header=T)
  
  nulls<- which(is.na(f$loan_status))
  if(!length(nulls)==0){
    f<- f[-nulls,]
  }
  
  f$int_rate    <- as.numeric(gsub("[%\\s]","", f$int_rate))/100
  f$revol_util  <- as.numeric(gsub("[%\\s]","", f$revol_util))/100
  f$term        <- gsub("['months'|[:blank:]]","", f$term)
  f$emp_title   <- tolower(f$emp_title)
  
  col_vector<- c("earliest_cr_line", "last_credit_pull_d",
      "next_pymnt_d","issue_d","last_pymnt_d")
  
  index<- which(names(f) %in% col_vector)
  
  f[,index]<- lapply(f[,index], DateConv)
  f
  #   f$earliest_cr_line  <- as.POSIXlt(sapply(f$earliest_cr_line,DateConv))
  #   f$last_credit_pull_d<- as.POSIXlt(sapply(f$last_credit_pull_d, DateConv))
  #   f$next_pymnt_d      <- as.POSIXlt(sapply(f$next_pymnt_d, DateConv))
  #   f$issue_d           <- as.POSIXlt(sapply(f$issue_d, DateConv))
  #   f$last_pymnt_d      <- as.POSIXlt(sapply(f$last_pymnt_d, DateConv))
}


DateConv<- function(x){
  suppressWarnings(
    if(x==""){
      return(NA)
    } else{
      a<- strsplit(x, split = "-")
      b<-paste(a[[1]][2], 
               match(a[[1]][1],month.abb), 
               "01",
               sep="-")
      as.Date(b)
    }
  )
}


PCT<- function(x){
  round(x*100,2)
}



Get_Loan_Data<- function(address){
  download.file(address, destfile="LoanData.zip")
  unzip("LoanData.zip")
  unlink("LoanData.zip")
}

FillNA<- function(x,y){
  ifelse(is.na(x),y,x)
}

</pre>

#### Getting the Data
<pre>
path<- "c:/users/ryan/OneDrive/rprojects/p2plend/data/historical"
dir.create(path)
setwd(path)
source("../../scripts/0_Functions.R")

Links<- character()
  Links[1]<- "https://resources.lendingclub.com/LoanStats3a.csv.zip"
  Links[2]<- "https://resources.lendingclub.com/LoanStats3b.csv.zip"
  Links[3]<- "https://resources.lendingclub.com/LoanStats3c.csv.zip"
  Links[4]<- "https://resources.lendingclub.com/LoanStats3d.csv.zip"


lapply(Links, Get_Loan_Data)

df_list<- lapply(dir(), Prep_Loan_Data)
dat<- plyr::rbind.fill(df_list)

# Prepping the data
dat<- dat[-which(is.na(dat$loan_amnt)),]
StatusTbl<- data.frame(matrix(data=c(
  "Current",            "A",
  "Fully Paid",         "A",
  "In Grace Period",    "A",
  "Late (16-30 days)",  "B",
  "Late (31-120 days)", "B",
  "Default",            "B",
  "Charged Off",        "B",
  "",                   "B",
  "Does not meet the credit policy. Status:Charged Off", "B",
  "Does not meet the credit policy. Status:Current",     "B",
  "Does not meet the credit policy. Status:Fully Paid",  "B"),
  byrow=T, ncol=2), stringsAsFactors = F)
names(StatusTbl)<- c("Status","Class")

dat<- dplyr::left_join(dat,StatusTbl, by=c("loan_status"="Status"))

dat$Class<- as.factor(dat$Class)
dat$grade<- as.factor(dat$grade)

save(dat, file="../HistoricalLoanData.RData")

file.remove(dir())
rm(df_list, Links, path, StatusTbl)

</pre>

#### Data Cleaning  
<pre>
library(dplyr)
library(tm)
library(stringr)

ddir<- "C:/users/ryan/OneDrive/rprojects/p2plend"
source(paste(ddir,"/scripts/0_Functions.R",sep=""))
if (!exists("dat")){
  load(paste(ddir,"/data/historicalloandata.RData",sep=""))
  }


# Establish factors
dat$Class   <- factor(dat$Class)
dat$purpose <- factor(dat$purpose)
dat$term    <- factor(dat$term)
dat$home_ownership<- factor(dat$home_ownership)


dat$collections_12_mths_ex_med <- FillNA(dat$collections_12_mths_ex_med, 
                                         mean(dat$collections_12_mths_ex_med, na.rm = T))
dat$open_acc                   <- FillNA(dat$open_acc, mean(dat$open_acc, na.rm=T))
dat$inq_last_6mths             <- FillNA(dat$inq_last_6mths, mean(dat$inq_last_6mths,na.rm=T)) 
dat$annual_inc                 <- FillNA(dat$annual_inc, mean(dat$annual_inc,na.rm = T))


dat$loan_to_inc<- ifelse(dat$annual_inc==0,0,dat$loan_amnt/dat$annual_inc)
gsub("^[[:blank:]]+([[:alnum:]]|[[:blank:]]|/)+>[[:blank:]]","",dat$desc[1:5], fixed=F)
dat$wkday<- factor(weekdays(dat$issue_d))

#Text Processing ----

# Count number of comments
dat$comment_count<- str_count(dat$desc,"Borrower added on")


# Remove prefix
dat$desc<- gsub("^[[:blank:]]+([[:alnum:]]|[[:blank:]]|/)+>[[:blank:]]","",dat$desc, fixed=F)



# Re-Save data after cleaning
save(dat, file="../HistoricalLoanData.RData")


</pre>

#### Blog Post Support  
<pre>
library(dplyr)
library(ggplot2)
library(scales)
ddir<- "C:/users/ryan/OneDrive/rprojects/p2plend"
source(paste(ddir,"/scripts/0_Functions.R",sep=""))
if (!exists("dat")){
  load(paste(ddir,"/data/historicalloandata.RData",sep=""))
  }
  
 # Calculate the number of payments
newdat<- dat %>%
  filter(Class=="B") %>%
  mutate(no_pymnt= round(total_pymnt/installment,1)) %>%
  group_by(term, no_pymnt) %>%
  arrange(no_pymnt) %>%
  summarise(N=n()) %>%
  mutate(Cum=N/sum(N),
         CumSum= cumsum(Cum)) %>%
  select(-N,-Cum)

  a<- ggplot(newdat) 
a<- a + aes(x=no_pymnt, y=CumSum, group=term, colour=term)
a<- a + geom_step(size=1.5)
a<- a + labs(x="Months of Payments",
             y="% of Total Running Sum",
             title="Lending Club Loans- Number of Payments Before Default")
a<- a + scale_y_continuous(labels=percent)
a<- a + scale_x_continuous(breaks=seq(0,65,5))
a<- a + guides(colour=guide_legend(title="Loan Term"))
a<- a + theme(panel.background=element_rect(fill="white"))
a
</pre>