##
##
## 


## 1. get / parse data
# ~ 4-5 hours with single thread
# source('parse-all-series-via-sc-db.R')
# ~ 42 minutes parallel
source('parallelParseOSD.R')


## 2. fill-in missing colors using brute force modeling approach
# ~ 4 minutes run time
source('predict-missing-colors.R')

# 3. send to SoilWeb



# 4. re-load data: see sql/ dir in this repo



# stats
x <- read.csv('logfile-2018-01-05.csv', stringsAsFactors = FALSE)
table(x$sections)
