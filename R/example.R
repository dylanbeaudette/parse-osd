library(stringi)
library(httr)

# get HTML content for a single series
x <- content(GET('http://soilseriesdesc.sc.egov.usda.gov/OSD_Docs/A/AMADOR.html'), 'text')

# parse dry colors
stri_match_all(x, regex='\\(([0-9]?[\\.]?[0-9][Y|R]+)([ ]+?[0-9])/([0-9])\\)(?! moist)')

# parse moist colors
stri_match_all(x, regex='\\(([0-9]?[\\.]?[0-9][Y|R]+)([ ]+?[0-9])/([0-9])\\) moist')


## this doesn't work here, works fine in python
# parse hz designations and depths
stri_match_all(x, regex='^\s*([a-zA-Z0-9]+)\s?\-\-?\-?\s?([0-9\.]+) (in|inches|cm|centimeters)')
