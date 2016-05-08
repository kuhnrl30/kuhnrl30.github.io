---
layout: default
title: Blog Make File
Resume: passive
Projects: passive
blog: passive
moocs: passive
contact: passive
description: R Code Used to make the 
---

### Use this script to build a blog post from an .Rmd file.  
<pre>
# Edit this filename for every blog post
filename <- "How-To-Use-Plotly-With-Jekyll.Rmd"


library(knitr)
library(brocks)
setwd("c:/users/ryan/dropbox/website/")
opts_chunk$set(comment = NA, fig.path = '/images/')
dir      <- paste0(getwd(), "/_posts/", Sys.Date(), "-")
output   <- paste0(dir, sub('.Rmd', '.html', filename))


# Check that it's a .Rmd file.
if(!grepl(".Rmd", filename)) {	
	stop("You must specify a .Rmd file.")
	}


knit(input= paste0("_drafts/", filename),
     output = output,
     encoding = 'UTF-8')
htmlwidgets_deps(paste0(Sys.Date(), "-", filename), always = T)

# Copy .png files to the images directory.
fromdir = "/images"
pics <- list.files(fromdir, ".png")
pics <- sapply(pics, function(x) paste(fromdir, x, sep="/"))
file.copy(pics, todir, overwrite = T)

unlink("C:/images", recursive = T)
</pre>