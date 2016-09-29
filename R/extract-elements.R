
x <- getOSD('BRYMAN')
x <- getOSD('amador')

extractHzData(x)

x.fulltext <- ConvertToFullTextRecord('amador', x)
x.sections <- ConvertToFullTextRecord2('amador', x)
