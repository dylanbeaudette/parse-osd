# parse-osd
Code related to parsing of OSD records. Currently relies on a directory of ALL OSD text files, the bash shell, and python. An R-based version should be much simpler to maintain, and could work directly with the HTML versions of the data. It is a huge pain in the neck to try and get the entire set of OSD text files -> might be simpler to iterate over a list of series names from the SC database and query the HTML directly.

# python
this is the current python implementation, not perfect, but gets 95% of the data I need

# R
this will be the R-based rewrite of the python code

# TODO
1. figure out how to deal with multiple colors
2. combine top+bottom with top only rules, ideas: http://stackoverflow.com/questions/15474741/python-regex-optional-capture-group
3. color matching rules don't work properly when only moist colors are specified (http://casoilresource.lawr.ucdavis.edu/sde/?series=canarsie)
4. how can we match neutral colors: (N 2.5/)
5. how can we extract mixed horizons?: '3E & Bt' ?

