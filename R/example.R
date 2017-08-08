library(stringi)
library(httr)
library(rvest)
library(plyr)

source('local_functions.R')

testIt <- function(x) {
  res <- getOSD(x)
  l <- list()
  l[['sections']] <- extractSections(res)
  l[['section-indices']] <- findSectionIndices(res)
  l[['hz-data']] <- extractHzData(res)
  return(l)
}


## known working
extractHzData(getOSD('amador'))
extractHzData(getOSD('pentz'))


# typos related to OCR: fixed 2017-08-08
extractHzData(getOSD('rincon'))
testIt('rincon')

# typos related to OCR: fixed 2017-08-08
extractHzData(getOSD('solano'))

# first horizon depths use inconsistent units specification: incorrect conversion applied
extractHzData(getOSD('proper'))

# can't parse (N 3/)
testIt('demas')

# horizons are multi-line records... REGEX can't parse
testIt('HELMER')

# fixed B and N hues
testIt('SOUTHPOINT')

# fixed: 5GY hues
testIt('figgs')

# fixed
# multiple matches in type location
testIt('URLAND')

# fixed
# multiple, exact matches for typical pedon
testIt('MANASTASH')
testIt('KEAA')

# missing "TYPICAL PEDON"
testIt('ARIEL')
testIt('PACKSADDLE')

# no white space, fixed
# "TYPICAL PEDON:"
testIt('dinuba')

# "TYPICAL PEDON;"
testIt('NEISSENBERG')

# funky white space
testIt('ODESSA')

## multiple matches for typical pedon
testIt('CAJON')

## no OSD..
testIt('FUCHES')

# white-space in front of section names: fixed
testIt('BRYMAN')

# missing dry/moist flag
testIt('ADAMSTOWN')
extractSections(x)


testIt('Funkstown')


# section names have no spaces...
testIt('TUSKAHOMA')


# typos and ?
testIt('vance')


# extra "----"
testIt('Ravenrock')


# neutral hues
testIt('Yorkville')


# error in OSD, 'O' should be '0'
testIt('clear lake')


# error in OSD, 'O' should be '0'
testIt('iron mountain')


# errors in OSD: "A1, A3--0 to 19 inches;"
testIt('whitney')


# "l" and "O" used instead of "1" and "0"
# must fix OSD
testIt('SIRRETTA')


# can't parse this: (10YR 3/1 moist or dry)
testIt('salinas')


# error in O horizon narrative
testIt('CROQUIB')


# false-positives matched in RIC section
# -> fixed in post-processing SQL code
testIt('humeston')


# variation on type location
testIt('ANAN')


# multiple mention of "type location" 
testIt('yutan')


# multiple mention of "type location" 
testIt('filbert')


# "E and Bt1"
testIt('colonie')


# some problematic OSDs
testIt('pardee')


## TODO, still not correct as all colors are moist
testIt('canarsie')


testIt('capay')


testIt('academy')


testIt('newot')


testIt('flagspring')


# error in "TYPICAL PEDON" heading
testIt('ACKWATER')


testIt('CASA GRANDE')


# return NULL
# strange notation: A [A1]--0 to 10 cm (4 inches)
testIt('RAPSON')


testIt('KILFOIL')


# "TYPICAL PEDON-"
testIt('MENTZ')


# non-standard TYPE LOCATION heading 
testIt('ALBUS')


# no OSD document
testIt('YALE')





# parsing all of the series data could be done from the SC database...