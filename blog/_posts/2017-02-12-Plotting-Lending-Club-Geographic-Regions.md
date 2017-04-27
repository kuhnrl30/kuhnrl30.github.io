---
title: Plotting the Lending Club Geographic Regions
output: html_document
layout: post
date: 'February 12, 2017'
comments: true
tags: [R, P2PLending]
htmlwidgets: false
description: Creating a Shapefile to Visualize Lending Club Data by Region
---

## Creating a Shapefile to Visualize Lending Club Data by Region


One of the data points in Lending Club data is a geographic identifier in the form of a truncated zip code. As an example, zip code 12345 would show as 123xx. I wanted to use this identifier to look for regional trends that could indicate a riskier loan. I might find a result such as loans in Arizona might at a higher rate and would be a riskier investment. To do this I had to modify the zip code level shapefiles I had found from the US Census. 

This post gives the code I used to create the regional shapefile for plotting. Once that is complete, we can attach any attributes created in an analysis such as number of loans by region or default rates by region and look at the geospatial relationships.


### Download the zipcode shapefile
The US Census publishes shapefiles that you can [download for free](https://www.census.gov/geo/maps-data/data/tiger-line.html). We'll start with a zip code file to form the basis for our Lending Club map. Shapefiles are a specific file type structured to draw geographic shapes. In this case, the shapes are zip code boundaries.  It's a fairly large file as you can imagine there are many data points to draw every zip code.

```r
library(dplyr)
library(maptools)
library(ggplot2)
library(scales)
library(maps)

myURL<- "http://www2.census.gov/geo/tiger/GENZ2015/shp/cb_2015_us_zcta510_500k.zip"
temp<- tempfile()
download.file(myURL, temp)
unzip(temp, exdir = tempdir())
unlink(temp)
```

### Modify the shapefile

```r
zips<- readShapePoly(paste0(tempdir(),"\\cb_2015_us_zcta510_500k.shp"))

zipIDs<- data.frame(
    index = as.character(1:nrow(zips@data)-1),
    zipcode = as.character(zips@data[,1]),
    region = paste0(substr(zips@data[,1],1,3),"xx"),
    stringsAsFactors = F)


LendingClubRegions<- zips %>%
    fortify() %>%
    left_join(zipIDs, by = c("id"="index"))

#cleanup
rm(zips, zipIDs)
```

### Attaching attributes to visualize 
Here I'm adding a randomly number variable to the dataset. When I use the map data in a future analysis, I'd attach something more interesting such as percentage of defaulted loans.  Since this is just an example I'm going with random numbers. 


```r
rn<- length(levels(factor(LendingClubRegions$region)))
rand<- data.frame(Index= levels(factor(LendingClubRegions$region)),
                  vals= rnorm(rn))

LendingClubRegions<- LendingClubRegions %>%
    left_join(rand, by = c("region"="Index"))
```

### Plotting the data  

```r
a<- ggplot(LendingClubRegions) 
a<- a + aes(x = long, y = lat, group = region, fill = vals)
a<- a + geom_polygon()
a<- a + guides(fill = FALSE)
a<- a + xlim(c(-125, -60))
a<- a + ylim(c(23,50))
a<- a + theme(axis.text = element_blank(),
              axis.title = element_blank(),
              panel.background = element_blank())
a<- a + scale_fill_gradientn(colours=rainbow(6))
a<- a + coord_map("albers",lat0 = 39, lat1 = 45)
a
```

![plot of chunk plotting](/images/plotting-1.png)
