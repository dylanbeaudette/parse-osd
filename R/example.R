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

x.parsed <- getAndParseOSD('newot')
extractHzData(x.parsed)

x.parsed <- getAndParseOSD('flagspring')
extractHzData(x.parsed)

# error in "TYPICAL PEDON" heading
x.parsed <- getAndParseOSD('ACKWATER')
extractHzData(x.parsed)

x.parsed <- getAndParseOSD('CASA GRANDE')
extractHzData(x.parsed)



# parsing all of the series data could be done from the SC database...