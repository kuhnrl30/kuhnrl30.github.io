---
layout: default
title: NJ Employee Salary Shiny App code
Resume: passive
Projects: passive
blog: passive
moocs: passive
contact: passive
description: Code used to build a Shiny app.  The app allows users to compare their salary to that of the New Jersey State Employees
---

### UI.R
This block of code generates the user interface for the app.  It defines the input boxes, tabbed content, and the descriptive text explaining the source of the data. 
<pre>
library(shiny)

shinyUI(fluidPage(theme="journal.css",
  #pageWithSidebar
  
  #Application Title
  headerPanel("NJ State Employee Salaries"),
  
  # Sidebar with controls to select which year of data to pull and 
  # to enter the users salary. The helpText function is used to 
  # disclaim the number of datapoints used in the chart and to 
  # imply the methodology. Sepcifically, to call out that only 
  # the first 1,000 data points are used which is not a statistical
  # sample of salaries. The submitButton defers the rendering of output 
  # until the user explicitly clicks the button (rather than doing it 
  # immediately when inputs change). This is useful because the function 
  # submits an API call and then must format the data before it is 
  # presented.
  
  sidebarPanel(h3("Enter your salary and see how you stack up against the New Jersey state employees!"),
               numericInput("isalary",'Your Salary(USD)',0,min=0,max=150000,step=1),
               selectInput("year","Choose the year",choices=c("2010","2011","2012", "2013","2014")),
               helpText("Note: This function may take a few moments to load ",
                        "if you change the year because it must download the",
                        "new data from the NJ Open Data website for each update."),
               submitButton("Update View")),
  
  # The main panel presents the s chart with a gaussian
  # curve with the same characteristics as the actual
  # data.  The main panel also shows the user's salary
  # and the quantile where the user falls in the 
  # distribution.
  mainPanel(
    tabsetPanel(
      tabPanel("Chart",
               plotOutput("plot1"),
               textOutput("statement")),
      tabPanel("Documentation",
               p("Dear Reader,"),
               p("The purpose of this application is to allow the user to compare",
                 "their salary to the average salary of the New Jersey state employees.",
                 "The user inputs a numerical value from 0 through 150,0000.  Next,",
                 "the user will select the year they wish to compare their salary to.",
                 "The application takes these two inputs and creates a chart with",
                 " a normal distribution and a vertical line with the users input. ",
                 "The normal distribution has the same mean and standard deviation",
                 "as the employee salary data for the relevant year"),
               p("The salary data is obtained from the New Jersey Open Data website ",
                 "using the Socrata Open Data API (SODA) ",
                 "from https://data.nj.gov/resource/iqwc-r2w7.json. The data",
                 "is refreshed everytime the user loads the app or changes the year",
                 "input value.  The API only allows 1,000 queries through the API",
                 " without using a application key and token.  Since the code for",
                 " this app will be shared on Github, no key was used. Since the "
                 "salary data is not logically sorted when downloaded, it was naively"
                 " assumed that the compensation data was randomly distributed.  Therefore,"
                 "it is possible to statistical inference to predict the percentile and ",
                 "determine the error margins."),
               p("Thank you for using this app. If you enjoyed using this app, please",
                 "head to", tags$b(tags$a(href="http://ryankuhn.net",target="_blank","http://ryankuhn.net")),
                 " to see more of my work."),
               p("Thank you,"),
               p("Ryan"))))
))
</pre>

### server.R
This block of code is the back end which controls the data and calculations that the user interface presents. 
<pre>
library(shiny)
require(RJSONIO)
require(ggplot2)
require(scales)


  # This function is used to access the SODA API and download the data from the NJ Open
  # Data website.  The funtion takes the year as an input and downloads the first 1000
  # entries.
  GetData<- function(n){
    # Returns the dataframe from the download.  The dataframe is 1000 rows by 1 column.
    # The filters are applied by the string after the '?'.  The 'master' record type 
    # was used because it had the YTD earnings.  The alternative was to use the 
    # 'detail' record type which had current period payroll entries. 
    URL<-paste("http://data.nj.gov/resource/iqwc-r2w7.json?record_type=master&calendar_year=",n,sep="")
    RawData<-fromJSON(URL)
    
    Temp<- data.frame(salary= as.numeric(sapply(RawData,"[[","master_ytd_earnings")),
                      stringsAsFactors = F)
    L<-list(mu=mean(Temp$salary),
         SD=sd(Temp$salary),
         values=Temp$salary)
    L
  }

shinyServer(
  function(input,output){

    # Use reactive functions so the data gets re-queried whenever the year input
    # is changed by the user.
    Data<- reactive({GetData({input$year})})
    
    output$mu  <- renderText(Data()$mu)
    output$SD  <- renderText((Data()[2]))
    
    # Need to use reactive again to update these values when the data set
    # is queried.
    Norm<-reactive({
      xval<- seq(0,150000,length=10000)
      yval<- dnorm(xval,mean=as.numeric(Data()$mu), sd=as.numeric(Data()$SD))
      data.frame(x=xval,y=yval)
    })
    
    # Calculate the theoretical percentile the user's salary would
    # fall into.  Use theoretical percentile as a statistical 
    # inference of where they user would fall.
    Percentile<- reactive(pnorm(as.numeric({input$isalary}), 
                                mean=as.numeric(unlist(Data()[1])),
                                sd=as.numeric(Data()[2])
                                ))

    # Draw the plot.  The vertical line is the user's salary.
    output$plot1<- renderPlot({
      ggplot(Norm()) + 
      aes(x=x,y=y) +
        geom_line(size=1.5) +
        labs(title="Distribution of Salaries for New Jersey State Employees",
             y= element_blank())  +
        scale_x_continuous(labels=comma, limits=c(0,150000)) +
        geom_vline(xintercept={input$isalary}, colour="blue", size=2)  +
        theme(plot.title=element_text(size=rel(2)),
              axis.text.y=element_blank(),
              panel.background=element_rect(fill="white",colour="black"),
              panel.grid.major=element_blank(),
              panel.grid.minor= element_blank())
    })
    
    
    # Craft the sentence at the bottom of the chart.  The statement includes
    # a binary value indicating if the user's salary is greater than or less
    # than the mean.  It also gives the mean salary during the year.
    Bigger<-reactive({ifelse({input$isalary}< as.numeric(Data()[1]),"less","more")})
    output$statement<- renderText(paste("Your salary is ",
                                         Bigger()[1],
                                         " than the average NJ state worker salary in ",
                                         {input$year},
                                        ". The average pay that year was $",
                                        format(round(as.numeric(Data()[1]),0),big.mark = ","),
                                        " and you made more money than ",
                                        round(Percentile(),3)*100,
                                        "% of the state employees. Congrats!",
                                        sep=""))
  }
)

</pre>

