library(stringi)
library(httr)
library(rvest)
library(plyr)

source('local_functions.R')

## known working
extractHzData(getOSD('amador'))
extractHzData(getOSD('pentz'))


# missing dry/moist flag
x <- getOSD('ADAMSTOWN')
extractHzData(x)

x <- getOSD('Funkstown')
extractHzData(x)

x <- getOSD('TUSKAHOMA')
extractHzData(x)

# typos and ?
x <- getOSD('vance')
extractHzData(x)

# extra "----"
x <- getOSD('Ravenrock')
extractHzData(x)

# neutral hues
x <- getOSD('Yorkville')
extractHzData(x)

# error in OSD, 'O' should be '0'
x <- getOSD('clear lake')
extractHzData(x)

# error in OSD, 'O' should be '0'
x <- getOSD('iron mountain')
extractHzData(x)

# errors in OSD: "A1, A3--0 to 19 inches;"
x <- getOSD('whitney')
extractHzData(x)

# "l" and "O" used instead of "1" and "0"
# must fix OSD
x <- getOSD('SIRRETTA')
extractHzData(x)

# can't parse this: (10YR 3/1 moist or dry)
x <- getOSD('salinas')
extractHzData(x)

# error in O horizon narrative
x <- getOSD('CROQUIB')
extractHzData(x)

# false-positives matched in RIC section
# -> fixed in post-processing SQL code
x <- getOSD('humeston')
extractHzData(x)

# variation on type location
x <- getOSD('ANAN')
extractHzData(x)

# multiple mention of "type location" 
x <- getOSD('yutan')
extractHzData(x)

# multiple mention of "type location" 
x <- getOSD('filbert')
extractHzData(x)

# "E and Bt1"
x <- getOSD('colonie')
extractHzData(x)

# some problematic OSDs
x <- getOSD('pardee')
extractHzData(x)

## TODO, still not correct as all colors are moist
x <- getOSD('canarsie')
extractHzData(x)

x <- getOSD('capay')
extractHzData(x)

x <- getOSD('academy')
extractHzData(x)

x <- getOSD('newot')
extractHzData(x)

x <- getOSD('flagspring')
extractHzData(x)

# error in "TYPICAL PEDON" heading
x <- getOSD('ACKWATER')
extractHzData(x)

x <- getOSD('CASA GRANDE')
extractHzData(x)

# return NULL
# strange notation: A [A1]--0 to 10 cm (4 inches)
x <- getOSD('RAPSON')
extractHzData(x)

x <- getOSD('KILFOIL')
extractHzData(x)

x <- getOSD('MENTZ')
extractHzData(x)

# non-standard TYPE LOCATION heading 
x <- getOSD('ALBUS')
extractHzData(x)

# no OSD document
x <- getOSD('YALE')
extractHzData(x)




# parsing all of the series data could be done from the SC database...