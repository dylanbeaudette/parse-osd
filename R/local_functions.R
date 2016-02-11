
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


# get and convert HTML to text and then fulltext DB table record
ConvertToFullTextRecord <- function(s, tablename='osd.osd_fulltext') {
  # get HTML text content
  u <- seriesNameToURL(s)
  s.html.text <- html_text(read_html(u))
  # strip blank lines
  s.html.text <- readLines(textConnection(s.html.text))
  s.html.text <- s.html.text[s.html.text != '']
  s.html.text <- paste(s.html.text, collapse = '\n')
  # convert into INSERT statement
  # note: single quotes escaped with $$:
  # http://stackoverflow.com/questions/12316953/insert-varchar-with-single-quotes-in-postgresql
  res <- paste0('INSERT INTO ', tablename, " VALUES ($$", s, "$$,$$", s.html.text, "$$);\n")
  return(res)
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
  
  ## NOTE: this limits false-positives, but is thrown-off by typos
  # where does the typical pedon block start?
  # note: we are only keeping the first match
  ## TODO: relaxed matching required to catch typos...
  ## this part is the most likely to break
  tp.start <- which(sapply(x.parsed, function(i) length(grep('TY.*\\sPEDON', i, ignore.case = TRUE)) > 0))[1] + 1
  # the last element contains "TYPE LOCATION:" but no horizon data, may occur more than once in the document
  tp.stop <- which(sapply(x.parsed, function(i) length(grep('(TY.*|PEDON)\\sLOC', i, ignore.case = TRUE)) > 0)) - 1
  
  ## TODO: bail out here if we cannot define the locations of horizon records
  if(is.na(tp.start) | length(tp.stop) < 1)
    return(NULL)
  
  # there could be multiple places in which the type location is mentioned
  if(length(tp.stop) > 1)
    tp.stop <- max(tp.stop)
  
  # combine into single string
  # note, this block of text is approximate
  tp <- paste(unlist(x.parsed[tp.start:tp.stop]), collapse = '')
  
  # split lines
  tp <- stri_split_lines(tp)[[1]]
  
  ## REGEX rules
  ## TODO: combine top+bottom with top only rules
  # TODO: allow for OCR errors:
  #       "O" = "0"
  #       "l" = "1"
  ## ideas: http://stackoverflow.com/questions/15474741/python-regex-optional-capture-group
  # detect horizons with both top and bottom depths
  hz.rule <- "^\\s*([\\^\\'\\/a-zA-Z0-9]+)\\s?-+?\\s?([O0-9.]+) to ([O0-9.]+) (in|inches|cm|centimeters)"
  # detect horizons with no bottom depth
  hz.rule.no.bottom <- "^\\s*([\\^\\'\\/a-zA-Z0-9]+)\\s?-+?\\s?([0-9.]+) (in|inches|cm|centimeters)"
  
  
  ## TODO: this doesn't work when only moist colors are specified (http://casoilresource.lawr.ucdavis.edu/sde/?series=canarsie)
  ## TODO: these rules will not match neutral colors: N 2.5/
  ## TODO: toggle dry/moist assumption:
  ##
  ## Colors are for dry soil unless otherwise stated | Colors are for moist soil unless otherwise stated
  ## 
  ## E1--7 to 12 inches; very dark gray (10YR 3/1) silt loam, 50 percent gray (10YR 5/1) and 50 percent gray (10YR 6/1) dry; moderate thin platy structure parting to weak thin platy; friable, soft; common fine and medium roots throughout; common fine tubular pores; few fine distinct dark yellowish brown (10YR 4/6) friable masses of iron accumulations with sharp boundaries on faces of peds; strongly acid; clear wavy boundary.
  
  ##   A--0 to 6 inches; light gray (10YR 7/2) loam, dark grayish brown (10YR 4/2) moist; moderate coarse subangular blocky structure; slightly hard, friable, slightly sticky and slightly plastic; many very fine roots; many very fine and few fine tubular and many very fine interstitial pores; 10 percent pebbles; strongly acid (pH 5.1); clear wavy boundary. (1 to 8 inches thick)
  ##
  
  ## TODO: test this
  # establist default encoding of colors
  dry.is.default <- length(grep('for dry (soil|conditions)', paste(unlist(x.parsed), collapse=''), ignore.case = TRUE)) > 0
  moist.is.default <- length(grep('for moist (soil|conditions)', paste(unlist(x.parsed), collapse=''), ignore.case = TRUE)) > 0
  
  if(dry.is.default)
    default.moisture.state <- 'dry'
  if(moist.is.default)
    default.moisture.state <- 'moist'
  
  # if neither are specified assume moist conditions
  if((!dry.is.default & !moist.is.default))
    default.moisture.state <- 'moist'
  
  # if both are specified (?)
  if(dry.is.default & moist.is.default)
    default.moisture.state <- 'unknown'
  
  ## TODO: test this
  # get all colors matching our rule, moist and dry and unknown, 5th column is moisture state
  # interpretation is tough when multiple colors / hz are given
  # single rule, with dry/moist state
  color.rule <- "\\(([0-9]?[\\.]?[0-9]?[Y|R|N]+)([ ]+?[0-9])/([0-9])\\)\\s(dry|moist|)"
  
  # detect moist and dry colors
  dry.color.rule <- "\\(([0-9]?[\\.]?[0-9]?[Y|R|N]+)([ ]+?[0-9])/([0-9])\\)(?! moist)"
  moist.color.rule <- "\\(([0-9]?[\\.]?[0-9]?[Y|R|N]+)([ ]+?[0-9])/([0-9])\\) moist"
  
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
    
    # save hz data to list
    hz.data[[i]] <- h
    
#     ########### this works, but not when moisture state logic is reversed
#     # parse FIRST dry color, result is a 1-row matrix
#     dry.colors[[i]] <- stri_match(this.chunk, regex=dry.color.rule)
#     
#     # parse FIRST moist color, result is a 1-row matrix
#     moist.colors[[i]] <- stri_match(this.chunk, regex=moist.color.rule)
#     ###########
    
    
    ## TODO: test this!
    # parse ALL colors, result is a multi-row matrix, 5th column is moisture state
    colors <- stri_match_all(this.chunk, regex=color.rule)[[1]]
    # replace missing moisture state with (parsed) default value
    colors[, 5][which(colors[, 5] == '')] <- default.moisture.state
    
    # exctract dry|moist colors, note that there may be >1 color per state
    dc <- colors[which(colors[, 5] == 'dry'), 1:4, drop=FALSE]
    mc <- colors[which(colors[, 5] == 'moist'), 1:4, drop=FALSE]
    
    # there there was at least 1 match, keep the first 1
    if(nrow(dc) > 0)
      dry.colors[[i]] <- dc[1, ]
    else
      dry.colors[[i]] <- matrix(rep(NA, times=4), nrow = 1)
    
    if(nrow(mc) > 0)
      moist.colors[[i]] <- mc[1, ]
    else
      moist.colors[[i]] <- matrix(rep(NA, times=4), nrow = 1)
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



