library(stringi)
library(httr)
library(XML)
library(plyr)
library(rvest)

source('local_functions.R')

# all series from SC database
x <- read.csv('SC-database.csv.gz', stringsAsFactors=FALSE)

# keep just the series names 
x <- x$soilseriesname

# init list to store results
l <- list()

# resest fulltext SQL file
unlink('fulltext-data.sql')
cat('DROP TABLE osd.osd_fulltext;\n', file='fulltext-data.sql', append = TRUE)
cat('CREATE TABLE osd.osd_fulltext (series text, fulltext text);\n', file='fulltext-data.sql', append = TRUE)

# for(i in x[sample(1:length(x), size = 10)]) {
for(i in x) {
  print(i)
  # result is a list
  x.parsed <- getAndParseOSD(i)
  # there are some OSDs that may not exist
  if(length(grep('Server Error', unlist(x.parsed))) > 0) 
    l[[i]] <- NULL
  else {
    # apped extracted data to our list
    l[[i]] <- extractHzData(x.parsed)
    # get rendered HTML->text and save to file
    x.text <- ConvertToFullTextRecord(i)
    # append to file
    cat(x.text, file = 'fulltext-data.sql', append = TRUE)
  }
    
}


# convert parsed series data to DF and save
d <- ldply(l)
d$seriesname <- d$.id
d$.id <- NULL

## TODO, do some basic error-checking on typos in the hue

write.csv(d, file=gzfile('parsed-data.csv.gz'), row.names=FALSE)

# ID those series that were not parsed
series.not.parsed <- setdiff(x, unique(d$seriesname))




