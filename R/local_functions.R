
## A helper function that tests whether an object is either NULL _or_ 
## a list of NULLs
is.NullOb <- function(x) is.null(x) | all(sapply(x, is.null))

## Recursively step down into list, removing all such objects 
rmNullObs <- function(x) {
  x <- Filter(Negate(is.NullOb), x)
  lapply(x, function(x) if (is.list(x)) rmNullObs(x) else x)
}

seriesNameToURL <- function(s) {
  base.url <- 'http://soilseriesdesc.sc.egov.usda.gov/OSD_Docs/'
  s <- toupper(s)
  # convert space to _
  s <- gsub(pattern = ' ', replacement = '_', s)
  u <- paste0(base.url, substr(s, 1, 1), '/', s, '.html')
  return(u)
}

getAndParseOSD <- function(s) {
  # make URL
  u <- seriesNameToURL(s)
  
  # get HTML content
  g <- GET(u)
  # convert to list
  x.parsed <- xmlToList(content(g, 'parsed'))
  
  # remove NULL elements
  x.parsed <- rmNullObs(x.parsed$body)
  
  return(x.parsed)
}


extractHzData <- function(x.parsed) {
  options(stringsAsFactors=FALSE)
  
  # where does the typical pedon block start?
  ## TODO: relaxed matching required to catch typos...
  ## this part is the most likely to break
  tp.start <- which(sapply(x.parsed, function(i) length(grep('TY.*\\sPEDON', i, ignore.case = TRUE)) > 0))[1] + 1
  # the last element contains "TYPE LOCATION:" but no horizon data
  tp.stop <- which(sapply(x.parsed, function(i) length(grep('TYPE LOCATION', i, ignore.case = TRUE)) > 0))[1] - 1
  
  ## TODO: bail out here if we cannot define the locations of horizon records
  
  # combine into single string
  # note, this block of text is approximate
  tp <- paste(unlist(x.parsed[tp.start:tp.stop]), collapse = '')
  
  # split lines
  tp <- stri_split_lines(tp)[[1]]
  
  ## REGEX rules
  ## TODO: combine top+bottom with top only rules
  ## ideas: http://stackoverflow.com/questions/15474741/python-regex-optional-capture-group
  # detect horizons with both top and bottom depths
  hz.rule <- "^\\s*([\\^\\'\\/a-zA-Z0-9]+)\\s?--?-?\\s?([0-9.]+) to ([0-9.]+) (in|inches|cm|centimeters)"
  # detect horizons with no bottom depth
  hz.rule.no.bottom <- "^\\s*([\\^\\'\\/a-zA-Z0-9]+)\\s?--?-?\\s?([0-9.]+) (in|inches|cm|centimeters)"
  
  # detect moist and dry colors
  ## TODO: this doesn't work when only moist colors are specified (http://casoilresource.lawr.ucdavis.edu/sde/?series=canarsie)
  ## TODO: these rules will not match neutral colors: N 2.5/
  dry.color.rule <- "\\(([0-9]?[\\.]?[0-9][Y|R]+)([ ]+?[0-9])/([0-9])\\)(?! moist)"
  moist.color.rule <- "\\(([0-9]?[\\.]?[0-9][Y|R]+)([ ]+?[0-9])/([0-9])\\) moist"
  
  # ID actual lines of horizon information
  hz.idx <- unique(c(grep(hz.rule, tp), grep(hz.rule.no.bottom, tp)))
  
  # init empty lists to store hz data and colors
  hz.data <- list()
  dry.colors <- list()
  moist.colors <- list()
  
  # iterate over identified horizons, extracting hz parts
  for(i in seq_along(hz.idx)) {
    this.chunk <- tp[hz.idx[i]]
    
    # parse hz designations and depths, keep first match
    ## hack
    # first try to find horizons with top AND bottom depths
    h <- stri_match(this.chunk, regex=hz.rule)
    # if none, then try searching for only top depths
    if(all(is.na(h))) {
      # this won't have the correct number of elements, adjust manually
      h <- stri_match(this.chunk, regex=hz.rule.no.bottom)
      h <- c(h, h[4]) # move units to 5th element
      h[4] <- NA # add fake missing bottom depth
    }
      
    hz.data[[i]] <- h
    
    # parse FIRST dry color
    dry.colors[[i]] <- stri_match(this.chunk, regex=dry.color.rule)
    
    # parse FIRST moist color
    moist.colors[[i]] <- stri_match(this.chunk, regex=moist.color.rule)
    
  }
  
  # test for no parsed data, must be some funky formatting...
  if(length(hz.data) == 0)
    return(NULL)
  
  # convert to DF
  hz.data <- ldply(hz.data)[2:5]
  dry.colors <- ldply(dry.colors)[2:4]
  moist.colors <- ldply(moist.colors)[2:4]
  
  names(hz.data) <- c('name', 'top', 'bottom', 'units')
  names(dry.colors) <- c('dry_hue', 'dry_value', 'dry_chroma')
  names(moist.colors) <- c('moist_hue', 'moist_value', 'moist_chroma')
  
  # cast to proper data types
  hz.data$top <- as.numeric(hz.data$top)
  hz.data$bottom <- as.numeric(hz.data$bottom)
  
  dry.colors$dry_value <- as.numeric(dry.colors$dry_value)
  dry.colors$dry_chroma <- as.numeric(dry.colors$dry_chroma)
  
  moist.colors$moist_value <- as.numeric(moist.colors$moist_value)
  moist.colors$moist_chroma <- as.numeric(moist.colors$moist_chroma)
  
  ## TODO sanity check / unit reporting 
  # convert in -> cm
  if(hz.data$units[1] %in% c('inches', 'in')) {
    hz.data$top <- round(hz.data$top * 2.54)
    hz.data$bottom <- round(hz.data$bottom * 2.54)
  }
  
  # remove units column
  hz.data$units <- NULL
  
  return(cbind(hz.data, dry.colors, moist.colors))
}



