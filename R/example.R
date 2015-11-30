library(stringi)
library(httr)
library(XML)
library(plyr)

source('local_functions.R')


# typos and ?
x.parsed <- getAndParseOSD('vance')
extractHzData(x.parsed)

# extra "----"
x.parsed <- getAndParseOSD('Ravenrock')
extractHzData(x.parsed)

# neutral hues
x.parsed <- getAndParseOSD('Yorkville')
extractHzData(x.parsed)

# error in OSD, 'O' should be '0'
x.parsed <- getAndParseOSD('clear lake')
extractHzData(x.parsed)

# error in OSD, 'O' should be '0'
x.parsed <- getAndParseOSD('iron mountain')
extractHzData(x.parsed)

# errors in OSD: "A1, A3--0 to 19 inches;"
x.parsed <- getAndParseOSD('whitney')
extractHzData(x.parsed)

# "l" and "O" used instead of "1" and "0"
# must fix OSD
x.parsed <- getAndParseOSD('SIRRETTA')
extractHzData(x.parsed)

# can't parse this: (10YR 3/1 moist or dry)
x.parsed <- getAndParseOSD('salinas')
extractHzData(x.parsed)

# error in O horizon narrative
x.parsed <- getAndParseOSD('CROQUIB')
extractHzData(x.parsed)

# false-positives matched in RIC section
# -> fixed in post-processing SQL code
x.parsed <- getAndParseOSD('humeston')
extractHzData(x.parsed)

# variation on type location
x.parsed <- getAndParseOSD('ANAN')
extractHzData(x.parsed)

# multiple mention of "type location" 
x.parsed <- getAndParseOSD('yutan')
extractHzData(x.parsed)

# multiple mention of "type location" 
x.parsed <- getAndParseOSD('filbert')
extractHzData(x.parsed)

# "E and Bt1"
x.parsed <- getAndParseOSD('colonie')
extractHzData(x.parsed)

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

# return NULL
# strange notation: A [A1]--0 to 10 cm (4 inches)
x.parsed <- getAndParseOSD('RAPSON')
extractHzData(x.parsed)

x.parsed <- getAndParseOSD('KILFOIL')
extractHzData(x.parsed)

x.parsed <- getAndParseOSD('MENTZ')
extractHzData(x.parsed)

# non-standard TYPE LOCATION heading 
x.parsed <- getAndParseOSD('ALBUS')
extractHzData(x.parsed)

# no OSD document
x.parsed <- getAndParseOSD('YALE')
extractHzData(x.parsed)




# parsing all of the series data could be done from the SC database...