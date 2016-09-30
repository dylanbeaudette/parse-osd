
# 1. get / parse data
source('parse-all-series-via-sc-db.R')

# 2. fill-in missing colors using brute force modeling approach
source('predict-missing-colors.R')

# 3. send to SoilWeb

# 4. re-load data