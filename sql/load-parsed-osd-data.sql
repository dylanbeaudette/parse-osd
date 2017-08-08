--
-- load parsed OSD data into SoilWeb
--
-- 2015-06-20: it appears that the "fixed" data from Skye (errors/fixed-2.csv) is no longer needed
--
-- 2015-11-30: set NULL bottom horizons to top + 1
--
-- 2016-10-03: no longer using manual fixes from Skye, removed most manual fixes from bottom of this script
--
-- 2016-10-04: added horizon narrative column
--


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
matrix_dry_color_value numeric,
matrix_dry_color_chroma numeric,
matrix_wet_color_hue varchar(10),
matrix_wet_color_value numeric,
matrix_wet_color_chroma numeric,
texture_class text,
cf_class text,
ph numeric,
ph_class text,
narrative text,
series citext
);

\copy osd.osd_colors FROM 'parsed-data-est-colors.csv' CSV HEADER NULL 'NA'

-- just in case convert series name to upper case
UPDATE osd.osd_colors SET series = UPPER(series);

-- index
CREATE INDEX osd_colors_series_idx ON osd_colors (series);


--
-- 2015-11-30: set NULL bottom horizons to top + 1
--
UPDATE osd.osd_colors SET bottom = top + 1 WHERE bottom IS NULL;

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


--
-- 2016-10-03: working on removing all manual fixes from SQL...
-- 
-- manual fixes
--


-- update index
VACUUM ANALYZE osd.osd_on_file;
VACUUM ANALYZE osd.osd_colors;

-- 
-- QA/QC: this is done manually
-- 
-- \i 'find-errors.sql'
