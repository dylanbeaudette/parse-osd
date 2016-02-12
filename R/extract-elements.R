


## this only works with blocks defined by <p></p>
x.parsed <- getAndParseOSD('cecil') # does work
x.parsed <- getAndParseOSD('drummer') # dosn't work

extractHzData(x.parsed)

extractParaBlock(x.parsed, 'TYPICAL PEDON:')
extractParaBlock(x.parsed, 'TYPE LOCATION:')
extractParaBlock(x.parsed, 'RANGE IN CHARACTERISTICS:')
extractParaBlock(x.parsed, 'COMPETING SERIES:')
extractParaBlock(x.parsed, 'GEOGRAPHIC SETTING:')
extractParaBlock(x.parsed, 'GEOGRAPHICALLY ASSOCIATED SOILS:')

extractParaBlock(x.parsed, 'DRAINAGE AND PERMEABILITY:')
extractParaBlock(x.parsed, 'USE AND VEGETATION:')
extractParaBlock(x.parsed, 'DISTRIBUTION AND EXTENT:')
extractParaBlock(x.parsed, 'REMARKS:')


## another approach, works much better
x.parsed <- getAndParseOSD('drummer')
x.parsed <- getAndParseOSD('cecil')
x.parsed <- getAndParseOSD('amador')
x.parsed <- getAndParseOSD('pierre')

extractSections(x.parsed)

ConvertToFullTextRecord2(x.parsed, series = 'amador')


