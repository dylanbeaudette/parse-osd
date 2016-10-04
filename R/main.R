##
##
## 


## this is likely much faster run on SoilWeb, consider splitting into chunks via gnu parallel
## ~ 166 series / minute = 106 minutes (actual time)
# 1. get / parse data
source('parse-all-series-via-sc-db.R')

## ~ 4 minutes run time
##  
# 2. fill-in missing colors using brute force modeling approach
source('predict-missing-colors.R')

# 3. send to SoilWeb

# 4. re-load data: see sql/ dir in this repo



# stats
x <- read.csv('logfile-2016-10-04.csv', stringsAsFactors = FALSE)
table(x$sections)
