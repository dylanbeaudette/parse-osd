##
## 2015-06-23
## fill-in missing / incorrectly parsed OSD colors using brute-force supervised classification
##

## TODO: save model object for times when an update would suffice and we don't have all of the samples

library(randomForest)


d <- read.csv('parsed-data.csv.gz', stringsAsFactors=TRUE)


## again, this time with RF
mv.rf <- randomForest(moist_value ~ dry_value + dry_chroma + dry_hue, data=d, na.action=na.omit)
mc.rf <- randomForest(moist_chroma ~ dry_value + dry_chroma + dry_hue, data=d, na.action=na.omit)

dv.rf <- randomForest(dry_value ~ moist_value + moist_chroma + moist_hue, data=d, na.action=na.omit)
dc.rf <- randomForest(dry_chroma ~ moist_value + moist_chroma + moist_hue, data=d, na.action=na.omit)

# fill missing data:

# value
d$moist_value[which(is.na(d$moist_value))] <- round(predict(mv.rf, d[which(is.na(d$moist_value)), ]))
d$dry_value[which(is.na(d$dry_value))] <- round(predict(dv.rf, d[which(is.na(d$dry_value)), ]))

# chroma
d$moist_chroma[which(is.na(d$moist_chroma))] <- round(predict(mc.rf, d[which(is.na(d$moist_chroma)), ]))
d$dry_chroma[which(is.na(d$dry_chroma))] <- round(predict(dc.rf, d[which(is.na(d$dry_chroma)), ]))

# convert factors -> character
d$moist_hue <- as.character(d$moist_hue)
d$dry_hue <- as.character(d$dry_hue)

# hue, use moist / dry hue
d$moist_hue[which(is.na(d$moist_hue))] <- d$dry_hue[which(is.na(d$moist_hue))]
d$dry_hue[which(is.na(d$dry_hue))] <- d$moist_hue[which(is.na(d$dry_hue))]

# other factor -> character conversion
d$name <- as.character(d$name)
d$seriesname <- as.character(d$seriesname)

# save result
write.csv(d, file=gzfile('parsed-data-est-colors.csv.gz'), row.names=FALSE)



