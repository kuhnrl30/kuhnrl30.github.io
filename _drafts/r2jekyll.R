#!/usr/bin/env Rscript
library(knitr)
setwd("c:/users/ryan/dropbox/website/_drafts")

# Get the filename 
filename <- "using-sql-in-R.Rmd"


# Check that it's a .Rmd file.
if(!grepl(".Rmd", filename)) {
  stop("You must specify a .Rmd file.")
}

# Knit and place in _posts.
dir = paste0("../_posts/", Sys.Date(), "-")
output = paste0(dir, sub('.Rmd', '.md', filename))
knit(filename, output)

# Copy .png files to the images directory.
fromdir = "{{ site.url }}/images"
todir = "../images"

pics = list.files(fromdir, ".png")
pics = sapply(pics, function(x) paste(fromdir, x, sep="/"))
file.copy(pics, todir)