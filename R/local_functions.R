
## temporary hack: storing as a global variable
# values are REGEX that try to accomodate typos
# names are the proper section names

## TODO: 
# consider anchoring all to left-side + optional white-space
# "TYPICAL PEDON" REGEX is too greedy
.sectionData <<- c('TYPICAL PEDON'='^\\s*TYP.*\\sPEDON[:|-]? ', 
                 'TYPE LOCATION'='^\\s*TYP.*\\sLOCATION[:]? ', 
                 'RANGE IN CHARACTERISTICS'='^\\s*RANGE IN CHARACTERISTICS[:]? ', 
                 'COMPETING SERIES'='^\\s*COMPETING SERIES[:]? ', 
                 'GEOGRAPHIC SETTING'='^\\s*GEOGRAPHIC SETTING[:]? ',
                 'GEOGRAPHICALLY ASSOCIATED SOILS'='^\\s*GEOGRAPHICALLY ASSOCIATED SOILS[:]? ',
                 'DRAINAGE AND PERMEABILITY'='^\\s*DRAINAGE AND PERMEABILITY[:]? ',
                 'USE AND VEGETATION'='^\\s*USE AND VEGETATION[:]? ',
                 'DISTRIBUTION AND EXTENT'='^\\s*DISTRIBUTION AND EXTENT[:]? ',
                 'REMARKS'='^\\s?REMARKS[:]? ',
                 'SERIES ESTABLISHED'='^\\s*SERIES ESTABLISHED[:]? ',
                 'ADDITIONAL DATA'='^\\s*ADDITIONAL DATA[:]? '
                 )

# remove blank lines from HTML text
removeBlankLines <- function(chunk) {
  # extract lines and remove blank / NA lines
  chunk.lines <- readLines(textConnection(chunk))
  chunk.lines <- chunk.lines[which(chunk.lines != '')]
  chunk.lines <- chunk.lines[which(!is.na(chunk.lines))]
  return(chunk.lines)
}


## TODO: use a set of titles and regular expressions to deal with typos
# check a line to see if any section titles are in it
checkSections <- function(this.line) {
  res <- sapply(.sectionData, function(st) grepl(st, this.line, ignore.case = TRUE))
  return(which(res))
}

# locate section line numbers
findSectionIndices <- function(chunk.lines) {
  l <- lapply(chunk.lines, checkSections)
  indices <- which(sapply(l, function(i) length(i) > 0))
  # copy over section names
  names(indices) <- sapply(l[indices], function(i) names(i))
  return(indices)
}

# extract sections from lines of OSD
extractSections <- function(chunk.lines, collapseLines=TRUE) {
  # storage
  l <- list()
  
  # locate section lines
  # note: this will give values inclusive of the next section
  section.locations <- findSectionIndices(chunk.lines)
  section.names <- names(section.locations)
    
  # combine chunks into a list
  for(i in 1:(length(section.locations) - 1)) {
    this.name <- section.names[i]
    start.line <- section.locations[i]
    # this stop line overlaps with the start of the next, decrease index by 1
    stop.line <- section.locations[i+1] - 1
    # extract current chunk
    chunk <- chunk.lines[start.line : stop.line]
    # optionally combine lines
    if(collapseLines)
      chunk <- paste(chunk, collapse='')
    # remove section name
    chunk <- gsub(this.name, '', chunk)
    # store
    l[[this.name]] <- chunk
  }
  
  return(l)
}


seriesNameToURL <- function(s) {
  base.url <- 'http://soilseriesdesc.sc.egov.usda.gov/OSD_Docs/'
  s <- toupper(s)
  # convert space to _
  s <- gsub(pattern = ' ', replacement = '_', s)
  u <- paste0(base.url, substr(s, 1, 1), '/', s, '.html')
  return(u)
}


# convert HTML text to fulltext DB table record
ConvertToFullTextRecord <- function(s, s.lines, tablename='osd.osd_fulltext') {
  # collapse to single chunk
  s.text <- paste(s.lines, collapse = '\n')
  # convert into INSERT statement
  # note: single quotes escaped with $$:
  # http://stackoverflow.com/questions/12316953/insert-varchar-with-single-quotes-in-postgresql
  res <- paste0('INSERT INTO ', tablename, " VALUES ($$", s, "$$,$$", s.text, "$$);\n")
  return(res)
}


# convert HTML text to an insert statement with data split by section
ConvertToFullTextRecord2 <- function(s, s.lines, tablename='osd.osd_fulltext2') {
  # split sections to list, section titles hard-coded
  sections <- extractSections(s.lines)
  
  # get names of all sections
  st <- names(.sectionData)
  
  # combine sections with $$ quoting
  blob <- sapply(st, function(i) {paste0('$$', sections[[i]], '$$')})
  res <- paste0('INSERT INTO ', tablename,  ' VALUES ( $$', s, '$$, ', paste(blob, collapse = ', '), ');\n')
  return(res)
}



# get an OSD from HTML record, convert to lines of text (HTML stripped)
getOSD <- function(s) {
  # make URL
  u <- seriesNameToURL(s)
  # get HTML content and strip blank / NA lines
  s.html.text <- html_text(read_html(u))
  s.html.text <- removeBlankLines(s.html.text)
  # done
  return(s.html.text)
}



## TODO: this is wasteful as we don't need to parse the entire OSD, retain sections from previous operation
extractHzData <- function(s.lines) {
  options(stringsAsFactors=FALSE)
  
  # this will not work in the presence of typos
  # new code for splitting blocks by section, lines from each section are not joined
  sections <- extractSections(s.lines, collapseLines = FALSE)
  tp <- sections[['TYPICAL PEDON']] 
  
  
  ## REGEX rules
  # http://regexr.com/
  ## TODO: combine top+bottom with top only rules
  # TODO: allow for OCR errors:
  #       "O" = "0"
  #       "l" = "1"
  ## ideas: http://stackoverflow.com/questions/15474741/python-regex-optional-capture-group
  # detect horizons with both top and bottom depths
  # hz.rule <- "^\\s*?([\\^\\'\\/a-zA-Z0-9]+)\\s?-+?\\s?([O0-9.]+)\\s+?to\\s+?([O0-9.]+)\\s+?(in|inches|cm|centimeters)"
  hz.rule <- "([\\^\\'\\/a-zA-Z0-9]+)\\s*-+\\s*([O0-9.]+)\\s*?to\\s+?([O0-9.]+)\\s+?(in|inches|cm|centimeters)"
  
  # detect horizons with no bottom depth
  hz.rule.no.bottom <- "([\\^\\'\\/a-zA-Z0-9]+)\\s*-+?\\s*([0-9.]+)\\s+?(in|inches|cm|centimeters)"
  
  
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
  dry.is.default <- length(grep('for dry (soil|conditions)', tp, ignore.case = TRUE)) > 0
  moist.is.default <- length(grep('for moist (soil|conditions)', tp, ignore.case = TRUE)) > 0
  
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
  # note that dry/moist may not always be present
  color.rule <- "\\(([0-9]?[\\.]?[0-9]?[Y|R|N]+)([ ]+?[0-9])/([0-9])\\)\\s?(dry|moist|)"
  
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



## DEPRECIATED
# # remove URLS from parsed chunk
# stripURLs <- function(chunk.list) {
#   
#   # get chunk names
#   cn <- names(chunk.list)
#   
#   # remove link targets
#   for(i in seq_along(chunk.list)) {
#     # get current name
#     i.name <- cn[i]
#     # how many sub-elements
#     n <- length(chunk.list[[i]])
#     
#     # if there are more than 1 sub-elements apply recursively
#     if(n > 1)
#       chunk.list[[i]] <- stripURLs(chunk.list[[i]])
#     
#     # if there is a name
#     if(!is.null(i.name)) {
#       # check for link and remove it
#       if(i.name == 'a')
#         chunk.list[[i]][['.attrs']] <- NULL
#     }
#   } 
#   
#   return(chunk.list)
# }

## DEPRECIATED
# # extract blocks defined by <p></p>
# # works: amador, auburn, cecil
# # doesn't work: drummer
# extractParaBlock <- function(x.parsed, block) {
#   idx <- which(sapply(x.parsed, function(i) length(grep(block, i, ignore.case = TRUE)) > 0))[1]
#   chunk.list <- x.parsed[[idx]]
#   chunk.list <- stripURLs(chunk.list)
#   # convert to lines and remove blank or NA lines
#   chunk.lines <- removeBlankLines(chunk.list)
#   # convert back to single chunk of text
#   chunk.text <- paste(chunk.lines, collapse = '')
#   return(chunk.text)
# }

## DEPRECIATED 
# ## A helper function that tests whether an object is either NULL _or_ 
# ## a list of NULLs
# is.NullOb <- function(x) is.null(x) | all(sapply(x, is.null))
# 
# ## Recursively step down into list, removing all such objects 
# rmNullObs <- function(x) {
#   x <- Filter(Negate(is.NullOb), x)
#   lapply(x, function(x) if (is.list(x)) rmNullObs(x) else x)
# }

## 2016-02-14: DEPRECIATED
# getAndParseOSD <- function(s) {
#   # make URL
#   u <- seriesNameToURL(s)
#   
#   # get HTML content
#   g <- GET(u)
#   
#   # convert to list
#   ## 2016-02-13: this isn't working...
#   x.parsed <- xmlToList(content(g, 'parsed'))
#   ## does this result in the same data?  NO
#   # x.parsed <- xmlToList(htmlTreeParse(content(g, 'parsed')))
#   
#   # remove NULL elements
#   x.parsed <- rmNullObs(x.parsed$body)
#   
#   return(x.parsed)
# }
