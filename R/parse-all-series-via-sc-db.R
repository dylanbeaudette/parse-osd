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
cat('DROP TABLE osd.osd_fulltext;\n', file='fulltext-data.sql')
cat('CREATE TABLE osd.osd_fulltext (series text, fulltext text);\n', file='fulltext-data.sql', append = TRUE)

## need to adjust fields manually as we edit
c('TYPICAL PEDON:', 'TYPE LOCATION:', 'RANGE IN CHARACTERISTICS:', 'COMPETING SERIES:', 'GEOGRAPHIC SETTING:', 'GEOGRAPHICALLY ASSOCIATED SOILS:', 'DRAINAGE AND PERMEABILITY:', 'USE AND VEGETATION:', 'DISTRIBUTION AND EXTENT:', 'REMARKS:')

cat('DROP TABLE osd.osd_fulltext2;\n', file='fulltext-section-data.sql')
cat('CREATE TABLE osd.osd_fulltext2 (
series text, 
typical_pedon text,
type_location text,
ric text,
competing_series text,
geog_location text,
geog_assoc_soils text,
drainage text,
use_and_veg text,
distribution text,
remarks text
    );\n', file='fulltext-section-data.sql', append = TRUE)


# for(i in x[sample(1:length(x), size = 10)]) {
for(i in x) {
  print(i)
  # result is a list
  x.parsed <- getAndParseOSD(i)
  # there are some OSDs that may not exist
  if(length(grep('Server Error', unlist(x.parsed))) > 0) 
    l[[i]] <- NULL
  else {
    # append extracted data to our list
    l[[i]] <- extractHzData(x.parsed)
    # get rendered HTML->text and save to file 
    x.text <- ConvertToFullTextRecord(i)
    cat(x.text, file = 'fulltext-data.sql', append = TRUE)
    # split data into sections for fulltext search
    x.sections <- ConvertToFullTextRecord2(x.parsed, series=i)
    cat(x.sections, file = 'fulltext-section-data.sql', append = TRUE)
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




