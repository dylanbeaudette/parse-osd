library(stringi)
library(httr)
library(XML)
library(plyr)

source('local_functions.R')

# some problematic OSDs
x.parsed <- getAndParseOSD('pardee')
extractHzData(x.parsed)

## TODO, still not correct as all colors are moist
x.parsed <- getAndParseOSD('canarsie')
extractHzData(x.parsed)

x.parsed <- getAndParseOSD('capay')
extractHzData(x.parsed)

x.parsed <- getAndParseOSD('academy')
extractHzData(x.parsed)
