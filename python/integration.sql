SET search_path TO osd, public;

-- wrap in a transaction
BEGIN;

-- create new table that contains colors
-- load our parsed OSD data into this table
DROP TABLE osd.osd_colors;
CREATE TABLE osd.osd_colors (
hzname varchar(20),
top numeric,
bottom numeric,
matrix_dry_color_hue varchar(10),
matrix_dry_color_value int,
matrix_dry_color_chroma int,
matrix_wet_color_hue varchar(10),
matrix_wet_color_value int,
matrix_wet_color_chroma int,
series citext
);

\copy osd.osd_colors FROM 'output.csv' CSV

-- just in case convert series name to upper case
UPDATE osd.osd_colors SET series = UPPER(series);


-- index
CREATE INDEX osd_colors_series_idx ON osd_colors (series);


-- create list of distinct series in or records
DROP TABLE osd.osd_on_file;
CREATE TABLE osd.osd_on_file AS
SELECT DISTINCT series as series 
FROM osd.osd_colors 
ORDER BY series;

-- index
CREATE INDEX osd_on_file_series_idx ON osd.osd_on_file (series);

COMMIT;

-- permissions
GRANT SELECT ON osd.osd_colors TO soil;
GRANT SELECT ON osd.osd_on_file TO soil;

-- update stats
VACUUM ANALYZE osd.osd_on_file;
VACUUM ANALYZE osd.osd_colors;

-- -- establish wet ~ dry color model
-- \copy osd_colors to 'colors.csv' CSV HEADER

/*
x <- read.csv(gzfile('colors.csv.gz'))
l.v <- lm(matrix_wet_color_value ~ matrix_dry_color_value, data=x)
l.c <- lm(matrix_wet_color_chroma ~ matrix_dry_color_chroma, data=x)

coef(l.c)
            (Intercept) matrix_dry_color_chroma 
              0.647587                0.802763
coef(l.v)
           (Intercept) matrix_dry_color_value 
            -0.1243945              0.7440088 
*/

-- apply model
UPDATE osd_colors set matrix_wet_color_hue = matrix_dry_color_hue WHERE matrix_wet_color_hue IS NULL;
UPDATE osd_colors set matrix_wet_color_value = round((matrix_dry_color_value * 0.7440088) + (-0.1243945))
WHERE matrix_wet_color_value IS NULL;
UPDATE osd_colors set matrix_wet_color_chroma = round((matrix_dry_color_chroma * 0.802763) + (0.647587 ))
WHERE matrix_wet_color_chroma IS NULL;

--
-- long-term strategy will require more thought / parsing of OSD records
--


-- 
-- QA/QC
-- 

-- 
-- * most are due to errors in the OSD format: check there first
-- 
-- 

set search_path TO osd, public;

-- 1. missing horizons:
CREATE TEMP TABLE missing_hz_check AS 
SELECT series, array_accum(top) as t, array_accum(bottom) as b, count(top) as n
FROM 
(
SELECT series, top, bottom
FROM osd_colors
ORDER BY series, top ASC
) as a
GROUP BY series;

-- get problem OSDs...
CREATE TEMP TABLE problems AS
SELECT series, t AS top, b as BOTTOM, t[n], b[n-1], n from missing_hz_check where t[n] != b[n-1] ;

CREATE TEMP TABLE problems_by_mo AS
SELECT mlraoffice, seriesname 
FROM taxa 
WHERE seriesname IN (SELECT series from problems) ORDER BY mlraoffice;

\copy problems TO 'problem-osds.csv' CSV HEADER
\copy problems_by_mo TO 'problems-by-mo.csv' CSV HEADER

