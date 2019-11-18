library(Hmisc)

## parsed from OSDs, no cleaning / estimation of missing colors
d <- read.csv('parsed-data.csv.gz', stringsAsFactors=FALSE)

## dump basic summary, skipping last column containing horizon narratives
options(width=160)
sink(file='QC/parsed-hz-data-summary.txt')
Hmisc::describe(d[, -14])
sink()


## parsed from OSDs, no cleaning / estimation of missing colors
s <- read.csv('parsed-site-data.csv.gz', stringsAsFactors=FALSE)

## dump basic summary, skipping last column containing horizon narratives
options(width=160)
sink(file='QC/parsed-site-data-summary.txt')
Hmisc::describe(s)
sink()


## parsed from OSDs, after cleaning
d <- read.csv('parsed-data-est-colors.csv.gz', stringsAsFactors=FALSE)

## dump basic summary, skipping last column containing horizon narratives
options(width=160)
sink(file='QC/cleaned-hz-data-summary.txt')
Hmisc::describe(d[, -14])
sink()
