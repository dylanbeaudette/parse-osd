
library(stringi)
library(httr)
library(plyr)
library(rvest)
library(purrr)
library(furrr)

source('local_functions.R')



## TODO: abstract the for-loop into a set of functions for 
## * getting data
## * processing chunks
## * saving fulltext ---> is this even possible with parallel exec?
##   may have to save into multiple files



# load latest SC-database
tf <- tempfile()
download.file(url = 'https://github.com/ncss-tech/SoilTaxonomy/raw/master/databases/SC-database.csv.gz', destfile = tf)
x <- read.csv(tf, stringsAsFactors=FALSE)

# keep only those records that are established or tentative
x <- subset(x, subset= series_status != 'inactive')

# keep just the series names 
x <- x$soilseriesname
names(x) <- x


# init parallel processing, seems to work ~ 2x speedup
plan(multisession)

# ~ 80 sec sequential [100 series]
# ~ 12 sec parallel   [100 series]
# ~ 28 seconds parallel [250 random series]
# system.time(res <- future_map(x[sample(1:length(x), size = 250)], downloadParseSave.safe, .progress=TRUE))

# full set
system.time(res <- future_map(x, downloadParseSave.safe, .progress=TRUE))


## TODO: iterate over results and save:
# hz data
# site data
# un-compressed fulltext
# un-compressed sections


# memDecompress(res$BATHEL$result$fulltext, type = 'gzip', asChar = TRUE)
# memDecompress(res$BATHEL$result$sections, type = 'gzip', asChar = TRUE)

# single element
# z <- pluck(res[[1]], 1, 1, 'hz')

## extract pieces
z <- map(res, pluck, 'result', 'fulltext')
z <- map(res, pluck, 'result', 'sections')
z <- map(res, pluck, 'result', 'hz')
z <- map(res, pluck, 'result', 'site')

## remove NULL / add series name



# # convert parsed horizon data to DF and save
# d <- ldply(l)
# d$seriesname <- d$.id
# d$.id <- NULL
# write.csv(d, file=gzfile('parsed-data.csv.gz'), row.names=FALSE)
# 
# # convert parsed site data to DF and save
# d <- ldply(sl)
# d$seriesname <- d$.id
# d$.id <- NULL
# write.csv(d, file=gzfile('parsed-site-data.csv.gz'), row.names=FALSE)
# 

# stop back-ends
plan(sequential)
