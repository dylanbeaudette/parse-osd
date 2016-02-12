# parse-osd
Code related to parsing of OSD text/HTML files.

# python
This is the current python implementation, not perfect, but gets 95% of the data I need. Currently relies on a directory of ALL OSD text files, the bash shell, and python. It is a huge pain in the neck to try and get the entire set of OSD text files.

# R
This is an R version of the python implementation, much simpler to debug and doesn't require a directory of OSD text files. It should be a simple task to iterate over a list of series names from the SC database, saving the results to an intermediate file or data structure. Failures have to be handled gracefully. Test REGEX rules here: http://regexr.com/

# TODO
1. figure out how to deal with multiple colors
2. combine top+bottom with top only rules, ideas: http://stackoverflow.com/questions/15474741/python-regex-optional-capture-group
3. test new color-parsing code
4. how can we match neutral colors: (N 2.5/)
5. how can we extract mixed horizons?: '3E & Bt' ?
6. typos are very hard to fix (http://casoilresource.lawr.ucdavis.edu/sde/?series=ACKWATER)
7. typos in Munsell hue may be possible to fix (http://casoilresource.lawr.ucdavis.edu/sde/?series=ACKWATER)
8. develop protocol for figuring out non-parsed records

# OSD Fulltext Searches
Experimental version [here](http://soilmap2-1.lawr.ucdavis.edu/dylan/soilweb/osd-fulltext/index.php).

## Updates
* 2016-02-10: HTML contents are converted to text and appended to a file for fulltext searching, works
* 2016-02-11: chunking the OSDs into sections seems to work

## Examples

### Parsed horizons
```
x.parsed <- getAndParseOSD(i)
extractHzData(x.parsed)

  name top bottom dry_hue dry_value dry_chroma moist_hue moist_value moist_chroma
1   Ap   0     20      NA        NA         NA      10YR           4            4
2  Bt1  20     66      NA        NA         NA       10R           4            8
3  Bt2  66    107      NA        NA         NA       10R           4            8
4   BC 107    127      NA        NA         NA     2.5YR           4            8
5    C 127    203      NA        NA         NA     2.5YR           4            8
```

### Parsed Sections
```
x.parsed <- getAndParseOSD(i)
extractSections(x.parsed)

$`TYPICAL PEDON:`
[1] " Cecil sandy loam--forested. (Colors are for moist soil unless otherwise stated.)Ap--0 to 8 inches; dark yellowish brown (10YR 4/4) sandy loam; weak medium granular structure; very friable; slightly acid; abrupt smooth boundary. (2 to 8 inches thick)Bt1--8 to 26 inches; red (10R 4/8) clay; moderate medium subangular blocky structure; firm; sticky, plastic; common clay films on faces of peds; few fine flakes of mica; strongly acid; gradual wavy boundary.Bt2--26 to 42 inches; red (10R 4/8) clay; few fine prominent yellowish red (5YR 5/8) mottles; moderate medium subangular blocky structure; firm; sticky, plastic; common clay films on faces of peds; few fine flakes of mica; very strongly acid; gradual wavy boundary. (Combined thickness of the Bt horizon is 24 to 50 inches)BC--42 to 50 inches; red (2.5YR 4/8) clay loam; few distinct yellowish red (5YR 5/8) mottles; weak medium subangular blocky structure; friable; few fine flakes of mica; very strongly acid; gradual wavy boundary. (0 to 10 inches thick)C--50 to 80 inches; red (2.5YR 4/8) loam saprolite; common medium distinct pale yellow (2.5Y 7/4) and common distinct brown (7.5YR 5/4) mottles; massive; very friable; few fine flakes of mica; very strongly acid."

$`TYPE LOCATION:`
[1] " Franklin County, North Carolina; about 9.7 miles west of Louisburg on North Carolina Highway 56 to Franklinton, about 4.4 miles south on U.S. Highway 1, about 0.4 mile east on North Carolina Highway 96, about 500 feet north of the road, in a field; Franklinton USGS topographic quadrangle; lat. 36 degrees 02 minutes 24 seconds N. and long. 78 degrees 29 minutes 27 seconds W."

$`RANGE IN CHARACTERISTICS:`
[1] " The Bt horizon is at least 24 to 50 inches thick and extends to 40 inches or more. Depth to bedrock ranges from 6 to 10 feet or more. The soil ranges from very strongly acid to moderately acid in the A horizons and is strongly acid or very strongly acid in the B and C horizons. Limed soils are typically moderately acid or slightly acid in the upper part. Content of coarse fragments range from 0 to 35 percent by volume in the A horizon and 0 to 10 percent by volume in the Bt horizon. Fragments are dominantly gravel or cobble in size. Most pedons have few to common flakes of mica in the Bt horizon and few to many flakes of mica in the BC and C horizons.The A or Ap horizon has hue of 2.5YR to 10YR, value of 3 to 5, and chroma of 2 to 8. A horizons with value of 3 are less than 6 inches thick. The texture is sandy loam, fine sandy loam, or loam in the fine earth fraction. Eroded phases are sandy clay loam, or clay loam in the fine earth fraction.The E horizon, where present, has hue of 7.5YR or 10YR, value of 4 to 6, and chroma of 3 to 8. It is sandy loam, fine sandy loam, or loam in the fine-earth fraction.The BA or BE horizon, where present, has hue of 2.5YR to 10YR, value of 4 to 6, and chroma of 3 to 8. It is sandy clay loam, loam, or clay loam.The Bt horizon averages 35 to 60 percent clay in the control section but may range to 70 percent in some subhorizons. It has hue of 10R or 2.5YR, value of 4 or 5, and chroma of 6 or 8. Hue also ranges to 5YR if evident patterns of mottling are lacking in the Bt and BC horizons. Mottles that are few and random are included. The Bt horizon is clay loam, clay, or sandy clay and contains less than 30 percent silt.The BC horizon has hue of 10R to 5YR, value of 4 or 6, and chroma of 4 to 8. Mottles in shades of yellow or brown are few to common in some pedons. The texture is sandy clay loam, clay loam, or loam.The C horizon is similar in color to the BC horizon or it is variegated. It is loamy saprolite weathered from felsic, igneous and high-grade metamorphic rocks."

$`COMPETING SERIES:`
[1] " These are the Appling, Bethlehem, Georgeville, Herndon, Madison, Nanford, Nankin, Pacolet, Saw, Tarrus, and Wedowee series in the same family. Those in closely related families are the Cataula, Chestatee, Cullen, Hulett, Lloyd, Mayodan, and Mecklenburg series. Appling soils have dominant hue of 7.5YR or yellower or where hue is 5YR it has evident patterns of mottling in a subhorizon of the Bt or BC horizon. Bethlehem soils have soft bedrock at depths of 20 to 40 inches. Cataula soils have a perched water table at 2 to 4 feet, Chestatee soils contain more than 15 percent, by volume, coarse fragments throughout. Cullen soils have more clay in the Bt horizon. Mayodan and Mecklenburg soils have mixed mineralogy and in addition, Mayodan soils formed in Triassic age sediments and Mecklenburg soils formed from basic diabase parent material. Georgeville, Herndon, Nanford, and Tarrus soils formed in Carolina slate and contain more than 30 percent silt. Hulett, Nankin, and Wedowee soils have a Bt horizon with hue of 5YR or yellower. In addition, Nankin soils formed from marine sediments. Lloyd soils have rhodic colors to depths of 40 inches or more. Madison, Pacolet, and Wedowee soils have thinner argillic horizons. Saw soils have hard bedrock at depths of 20 to 40 inches."

$`GEOGRAPHIC SETTING:`
[1] " Cecil soils are on nearly level to steep Piedmont uplands. Slope gradients are 0 to 25 percent, most commonly between 2 and 15 percent. These soils have developed in weathered felsic igneous and high-grade metamorphic rocks. Average annual precipitation is about 48 inches. Mean annual soil temperature is about 59 degrees F."

$`GEOGRAPHICALLY ASSOCIATED SOILS:`
[1] " In addition to the competing Appling, Bethlehem, Cataula, Chestatee, Cullen, Lloyd, Madison, Mecklenburg, Pacolet, Saw, and Wedowee series these are the Durham, Louisburg, Rion, and Worsham series. Durham, Louisburg, and Rion soils have less clay in the Bt horizon. Worsham soils are poorly drained and are around the heads of drains."

$`DRAINAGE AND PERMEABILITY:`
[1] " Well drained; medium to rapid runoff; moderate permeability."

$`USE AND VEGETATION:`
[1] " About half of the total acreage is in cultivation, with theremainder in pasture and forest. Common crops are small grains, corn, cotton, and tobacco."

$`DISTRIBUTION AND EXTENT:`
[1] " The Piedmont of Alabama, Georgia, North Carolina,South Carolina, and Virginia. The series is of large extent, with an area of more than 10 million acres.MLRA SOIL SURVEY REGIONAL OFFICE (MO) RESPONSIBLE: Raleigh, North CarolinaSERIES ESTABLISHED: Cecil County, Maryland; 1899."
```

