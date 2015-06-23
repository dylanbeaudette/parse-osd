library(stringi)
library(httr)
library(XML)
library(plyr)

source('local_functions.R')

# all series from SC database
x <- read.csv('SC-database.csv.gz', stringsAsFactors=FALSE)

# keep just the series names 
x <- x$soilseriesname

# init list to store results
l <- list()

# for(i in x[sample(1:length(x), size = 1000)]) {
for(i in x) {
  print(i)
  x.parsed <- getAndParseOSD(i)
  # there are some OSDs that may not exist
  if(length(grep('Server Error', unlist(x.parsed))) > 0) 
    l[[i]] <- NULL
  else
    l[[i]] <- extractHzData(x.parsed)
}


# convert parsed series data to DF and save
d <- ldply(l)
d$seriesname <- d$.id
d$.id <- NULL

## TODO, do some basic error-checking on typos in the hue

write.csv(d, file=gzfile('parsed-data.csv.gz'), row.names=FALSE)

# ID those series that were not parsed
series.not.parsed <- setdiff(x, unique(d$seriesname))




