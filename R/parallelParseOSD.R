library(stringi)
library(httr)
library(plyr)
library(rvest)
library(purrr)
library(furrr)

# functions used here, some of which will go to soilDB
source('local_functions.R')


# load latest SC-database
tf <- tempfile()
download.file(url = 'https://github.com/ncss-tech/SoilTaxonomy/raw/master/databases/SC-database.csv.gz', destfile = tf)
x <- read.csv(tf, stringsAsFactors=FALSE)

# keep only those records that are established or tentative
x <- subset(x, subset= series_status != 'inactive')

# keep just the series names 
x <- x$soilseriesname
names(x) <- x


# init parallel processing, works on macos and windows
plan(multisession)

# ~ 80 sec sequential [100 series]
# ~ 12 sec parallel   [100 series]
# ~ 28 seconds parallel [250 random series]
# system.time(res <- future_map(x[sample(1:length(x), size = 250)], downloadParseSave.safe, .progress=TRUE))

# full set: ~ 41 minutes
system.time(res <- future_map(x, downloadParseSave.safe, .progress=TRUE))


## process horizon data
z <- map(res, pluck, 'result', 'hz')
# remove NULL
idx <- which(! sapply(z, is.null))
z <- z[idx]
# convert to data.frame (~ 15 seconds)
d <- do.call('rbind.fill', z)
# save
write.csv(d, file=gzfile('parsed-data.csv.gz'), row.names=FALSE)

## process site data
z <- map(res, pluck, 'result', 'site')
# remove NULL
idx <- which(! sapply(z, is.null))
z <- z[idx]
# convert to data.frame (~ 15 seconds)
d <- do.call('rbind', z)
# save
write.csv(d, file=gzfile('parsed-site-data.csv.gz'), row.names=FALSE)



## process fulltext
z <- map(res, pluck, 'result', 'fulltext')

# process sections
z <- map(res, pluck, 'result', 'sections')

# memDecompress(res$BATHEL$result$fulltext, type = 'gzip', asChar = TRUE)
# memDecompress(res$BATHEL$result$sections, type = 'gzip', asChar = TRUE)



# stop back-ends
plan(sequential)
