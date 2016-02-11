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

## Updates
* 2016-02-10: HTML contents are converted to text and appended to a file for fulltext searching
